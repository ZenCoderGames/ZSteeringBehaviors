extends ZAI_Behavior

class_name ZAI_Behavior_Evade

@export var use_leave: bool = true
@export var flee_radius: float = 100.0
@export var prediction_time: float = 1.0
@export var debug_radius: bool = false

var closest_point_on_line: Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var target_position:Vector2 = get_target_pos()
	var fps := Engine.get_frames_per_second()
	var offset:Vector2 = parentCharacter.global_position - target_position
	var distance:float = offset.length()
	var desired_velocity:Vector2 = Vector2.ZERO
	
	target_position += target_char.velocity * fps * prediction_time * delta
	closest_point_on_line = Geometry2D.get_closest_point_to_segment(parentCharacter.global_position, get_target_pos(), target_position)
	var direction:Vector2 = (parentCharacter.global_position - closest_point_on_line).normalized() 

	if distance < flee_radius:
		desired_velocity = direction * parentCharacter.max_speed
		if use_leave:
			var ramped_speed:float = parentCharacter.max_speed * (1.0 - (distance / flee_radius))
			var clipped_speed:float = min (ramped_speed, parentCharacter.max_speed)
			desired_velocity = (clipped_speed / distance) * offset

	return desired_velocity

func debug_draw()->void:
	var flee_vector:Vector2 = parentCharacter.global_position - closest_point_on_line
	var local_target:Vector2 = parentCharacter.global_position + flee_vector
	local_target = to_local(local_target)
	var distance:float = flee_vector.length()
	draw_circle(to_local(closest_point_on_line), 5, debugColor)
	if distance < flee_radius:
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
	if debug_radius:
		draw_arc(Vector2.ZERO, flee_radius, 0, TAU, 32, debugColor, 2.0)
