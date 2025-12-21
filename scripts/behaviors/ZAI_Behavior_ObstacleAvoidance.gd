extends ZAI_Behavior

class_name ZAI_Behavior_ObstacleAvoidance

@export var feelerLength:float = 0
@export var feelerWidth:float = 25

@export var debugFeelers:bool = false

var targetPosition:Vector2 = Vector2.ZERO
var rightDirn:Vector2 = Vector2.ZERO
var targetObstacle:ZAI_Obstacle = null

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	#feelerLength = parentCharacter.velocity.length()
	
	var charVelocityNormalized:Vector2 = parentCharacter.velocity.normalized()
	targetPosition = parentCharacter.global_position + charVelocityNormalized * feelerLength
	rightDirn = -parentCharacter.velocity.orthogonal().normalized()
	
	targetObstacle = null
	var obstacles:Array[ZAI_Obstacle] = ZAIManager.get_obstacles()
	obstacles.sort_custom(obstacle_custom_sort)
	for obstacle in obstacles:
		# Create three feeler line segments: center, left, and right
		var center_start:Vector2 = parentCharacter.global_position
		var center_end:Vector2 = targetPosition
		var left_start:Vector2 = parentCharacter.global_position + rightDirn * -feelerWidth
		var left_end:Vector2 = targetPosition + rightDirn * -feelerWidth
		var right_start:Vector2 = parentCharacter.global_position + rightDirn * feelerWidth
		var right_end:Vector2 = targetPosition + rightDirn * feelerWidth

		# Check if any feeler segment intersects the obstacle
		var center_hit:bool = segment_intersects_circle(center_start, center_end, obstacle.global_position, obstacle.radius)
		var left_hit:bool = segment_intersects_circle(left_start, left_end, obstacle.global_position, obstacle.radius)
		var right_hit:bool = segment_intersects_circle(right_start, right_end, obstacle.global_position, obstacle.radius)

		#if center_hit or left_hit or right_hit:
		if center_hit or left_hit or right_hit:
			obstacle.set_active()
			targetObstacle = obstacle

			# Method 1
			desired_velocity = calc_steering_force_01(obstacle) + parentCharacter.velocity

			break
			
	return desired_velocity

### Steering Force
func calc_steering_force_01(obstacle:ZAI_Obstacle)->Vector2:
	var steeringForce:Vector2 = Vector2.ZERO

	# Direction from character to obstacle
	var to_obstacle:Vector2 = obstacle.global_position - parentCharacter.global_position
	var distance:float = to_obstacle.length()

	# Get perpendicular direction for lateral steering
	var lateral_direction:Vector2 = to_obstacle.orthogonal().normalized()
	# Center feeler hit or both - use angle-based logic
	var angle_diff:float = to_obstacle.angle_to(parentCharacter.velocity)
	if angle_diff < 0:
		steeringForce = lateral_direction
	else:
		steeringForce = -lateral_direction

	steeringForce *= parentCharacter.max_force

	# Scale by distance - closer obstacles exert stronger avoidance force
	var strength:float = 1.0 + clamp(distance / (obstacle.radius * 4), 0.0, 1.0)
	steeringForce *= strength

	return steeringForce

func debug_draw() -> void:
	if targetObstacle!=null:
		var desired_velocity = calc_steering_force_01(targetObstacle)
		var local_target:Vector2 = to_local(parentCharacter.global_position + desired_velocity)
		#var local_target:Vector2 = desired_velocity
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
	
	if debugFeelers:
		var center_end:Vector2 = targetPosition
		var left_start:Vector2 = parentCharacter.global_position + rightDirn * -feelerWidth
		var left_end:Vector2 = targetPosition + rightDirn * -feelerWidth
		var right_start:Vector2 = parentCharacter.global_position + rightDirn * feelerWidth
		var right_end:Vector2 = targetPosition + rightDirn * feelerWidth
		draw_line(Vector2.ZERO, to_local(center_end), debugColor, 2)
		draw_line(to_local(left_start), to_local(left_end), debugColor, 2)
		draw_line(to_local(right_start), to_local(right_end), debugColor, 2)

func segment_intersects_circle(p1: Vector2, p2: Vector2, center: Vector2, radius: float) -> bool:
	var seg:Vector2 = p2 - p1
	var t:float = (center - p1).dot(seg) / seg.length_squared()
	t = clamp(t, 0.0, 1.0)

	var closest:Vector2 = p1 + seg * t
	return closest.distance_squared_to(center) <= radius * radius
	
func obstacle_custom_sort(obstacleA:ZAI_Obstacle, obstacleB:ZAI_Obstacle):
	var distToA:float = (parentCharacter.global_position - obstacleA.global_position).length_squared()
	var distToB:float = (parentCharacter.global_position - obstacleB.global_position).length_squared()
	
	return distToA < distToB
