extends ZAI_Behavior

class_name ZAI_Behavior_PathFollowing

@export var path:ZAI_Path
@export var distanceThreshold:float = 50

var targetPosition:Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)

	var desired_velocity:Vector2 = Vector2.ZERO

	if path == null or path.points.size() < 2 or path.spline_curve == null:
		return desired_velocity

	# Get tessellated path points
	var path_points:PackedVector2Array = path.spline_curve.tessellate(5, path.curve_resolution)

	if path_points.size() < 2:
		return desired_velocity

	# Find closest point on the path and its segment index
	var closest_result:Dictionary = get_closest_point_with_segment(parentCharacter.global_position)
	var closest_point:Vector2 = closest_result["point"]
	var segment_index:int = closest_result["segment_index"]

	# Calculate distance from character to path centerline

	# Check if character is within the path width
	#var half_width:float = path.width / 2 

	# Outside path - steer in direction of path flow (towards next point)
	var next_index:int = min(segment_index + 1, path_points.size() - 1)
	if next_index==path_points.size()-1:
		next_index = 0
	var next_point:Vector2 = path.global_position + path_points[next_index]
	var distance_to_next_point:float = parentCharacter.global_position.distance_to(next_point)
	if distance_to_next_point <= distanceThreshold:
		closest_point = next_point
		next_index = min(next_index + 1, path_points.size() - 1)
		if next_index==path_points.size()-1:
			next_index = 0
		next_point = path.global_position + path_points[next_index]

	var returnToZoneDirection:Vector2 = (closest_point - parentCharacter.global_position)
	var flowDirection:Vector2 = (next_point - parentCharacter.global_position)
	desired_velocity = (returnToZoneDirection + flowDirection).normalized() * parentCharacter.max_speed
	
	targetPosition = parentCharacter.global_position + desired_velocity
	
	return desired_velocity

func debug_draw() -> void:
	var local_target:Vector2 = to_local(targetPosition)
	draw_line(Vector2.ZERO, local_target, debugColor, 2)

func get_closest_point_with_segment(point: Vector2) -> Dictionary:
	var result:Dictionary = {"point": path.global_position, "segment_index": 0}

	if path.spline_curve == null or path.points.size() < 2:
		return result

	# Get tessellated path segments
	var path_points:PackedVector2Array = path.spline_curve.tessellate(5, path.curve_resolution)

	var closest_point:Vector2 = path.global_position + path_points[0]
	var min_distance:float = point.distance_squared_to(closest_point)
	var closest_segment:int = 0

	# Check each segment for closest point
	for i in range(path_points.size() - 1):
		var seg_start:Vector2 = path.global_position + path_points[i]
		var seg_end:Vector2 = path.global_position + path_points[i + 1]

		var seg:Vector2 = seg_end - seg_start
		var t:float = (point - seg_start).dot(seg) / seg.length_squared()
		t = clamp(t, 0.0, 1.0)

		var point_on_seg:Vector2 = seg_start + seg * t
		var dist:float = point.distance_squared_to(point_on_seg)

		if dist < min_distance:
			min_distance = dist
			closest_point = point_on_seg
			closest_segment = i

	result["point"] = closest_point
	result["segment_index"] = closest_segment
	return result
