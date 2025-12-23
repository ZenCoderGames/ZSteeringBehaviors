extends ZAI_Behavior

class_name ZAI_Behavior_WallAvoidance

@export var feelerLength:float = 0
@export var feelerAngle:float = 20
@export var feelerWidth:float = 25

@export var debugFeelers:bool = false

var targetPosition_01:Vector2 = Vector2.ZERO
var targetPosition_02:Vector2 = Vector2.ZERO
var targetPosition_03:Vector2 = Vector2.ZERO
var rightDirn:Vector2 = Vector2.ZERO
var targetWall:ZAI_Wall = null

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	#feelerLength = parentCharacter.velocity.length()
	
	var charVelocityNormalized:Vector2 = parentCharacter.velocity.normalized()
	rightDirn = -parentCharacter.velocity.orthogonal().normalized()

	# Create three feeler line segments: center, left, and right
	targetPosition_01 = parentCharacter.global_position + charVelocityNormalized * feelerLength
	var leftVec:Vector2 = (targetPosition_01-parentCharacter.global_position).rotated(deg_to_rad(-20)).normalized()
	targetPosition_02 = parentCharacter.global_position + leftVec * feelerLength
	var rightVec:Vector2 = (targetPosition_01-parentCharacter.global_position).rotated(deg_to_rad(20)).normalized()
	targetPosition_03 = parentCharacter.global_position + rightVec * feelerLength

	targetWall = null
	var walls:Array[ZAI_Wall] = ZAIManager.get_walls()
	for wall in walls:
		# Skip walls with insufficient points
		if wall.points.size() < 2:
			continue

		# Check if any feeler segment intersects the wall
		var center_hit:bool = segment_intersects_wall(parentCharacter.global_position, targetPosition_01, wall)
		var left_hit:bool = segment_intersects_wall(parentCharacter.global_position, targetPosition_02, wall)
		var right_hit:bool = segment_intersects_wall(parentCharacter.global_position, targetPosition_03, wall)

		if center_hit or left_hit or right_hit:
			wall.set_active()
			targetWall = wall

			# Method 1
			desired_velocity = calc_steering_force_01(wall)
			#ZAIManager.set_paused(true)
			
	return desired_velocity

### Steering Force
func calc_steering_force_01(wall:ZAI_Wall)->Vector2:
	var steeringForce:Vector2 = Vector2.ZERO

	# Find closest point on wall to character
	var closest_point:Vector2 = get_closest_point_on_wall(wall, parentCharacter.global_position)

	# Direction from character to closest point on wall
	var to_wall:Vector2 = closest_point - parentCharacter.global_position
	var distance:float = to_wall.length()

	var reflected_direction:Vector2 = to_wall.bounce(to_wall.normalized()).normalized()
	steeringForce = reflected_direction
	
	var strength:float = 1.0 + clamp(distance / (feelerLength * 4), 0.0, 1.0)
	steeringForce *= strength
	
	steeringForce *= parentCharacter.max_speed

	return steeringForce

func debug_draw() -> void:
	if targetWall != null:
		var desired_velocity = calc_steering_force_01(targetWall)
		var local_target:Vector2 = to_local(parentCharacter.global_position + desired_velocity)
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
	
	if debugFeelers:
		draw_line(Vector2.ZERO, to_local(targetPosition_01), debugColor, 2)
		draw_line(Vector2.ZERO, to_local(targetPosition_02), debugColor, 2)
		draw_line(Vector2.ZERO, to_local(targetPosition_03), debugColor, 2)

func segment_intersects_wall(feeler_start: Vector2, feeler_end: Vector2, wall: ZAI_Wall) -> bool:
	if wall.spline_curve == null or wall.points.size() < 2:
		return false

	# Get tessellated wall segments
	var wall_points:PackedVector2Array = wall.spline_curve.tessellate(5, wall.curve_resolution)

	# Check intersection against each wall segment
	for i in range(wall_points.size() - 1):
		var wall_seg_start:Vector2 = wall.global_position + wall_points[i]
		var wall_seg_end:Vector2 = wall.global_position + wall_points[i + 1]

		if segments_intersect(feeler_start, feeler_end, wall_seg_start, wall_seg_end):
			return true

	return false

func segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	# Line segment intersection test using cross products
	var d1:Vector2 = p2 - p1
	var d2:Vector2 = p4 - p3
	var d3:Vector2 = p3 - p1

	var cross_d1_d2:float = d1.x * d2.y - d1.y * d2.x

	# Parallel or coincident lines
	if abs(cross_d1_d2) < 0.0001:
		return false

	var t1:float = (d3.x * d2.y - d3.y * d2.x) / cross_d1_d2
	var t2:float = (d3.x * d1.y - d3.y * d1.x) / cross_d1_d2

	# Check if intersection point is within both segments
	return t1 >= 0.0 and t1 <= 1.0 and t2 >= 0.0 and t2 <= 1.0

func get_closest_point_on_wall(wall: ZAI_Wall, point: Vector2) -> Vector2:
	if wall.spline_curve == null or wall.points.size() < 2:
		return wall.global_position

	# Get tessellated wall segments
	var wall_points:PackedVector2Array = wall.spline_curve.tessellate(5, wall.curve_resolution)

	var closest_point:Vector2 = wall.global_position + wall_points[0]
	var min_distance:float = point.distance_squared_to(closest_point)

	# Check each segment for closest point
	for i in range(wall_points.size() - 1):
		var seg_start:Vector2 = wall.global_position + wall_points[i]
		var seg_end:Vector2 = wall.global_position + wall_points[i + 1]

		var seg:Vector2 = seg_end - seg_start
		var t:float = (point - seg_start).dot(seg) / seg.length_squared()
		t = clamp(t, 0.0, 1.0)

		var point_on_seg:Vector2 = seg_start + seg * t
		var dist:float = point.distance_squared_to(point_on_seg)

		if dist < min_distance:
			min_distance = dist
			closest_point = point_on_seg

	return closest_point
