extends ZAI_Behavior

class_name ZAI_Behavior_Evade

@export var use_leave: bool = true
@export var flee_radius: float = 100.0
@export var prediction_time: float = 1.0
@export var debug_radius: bool = false

var closest_point_on_line: Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var target_position = get_target_pos()
	var fps := Engine.get_frames_per_second()
	var offset = parentCharacter.global_position - target_position
	var distance = offset.length()
	var desired_velocity = Vector2.ZERO
	
	target_position += target_char.velocity * fps * prediction_time * delta
	var targetVelVector:Vector2 = target_position - get_target_pos()
	var targetVelDirn = targetVelVector.normalized()

	# Find direction perpendicular to the line, pointing toward the AI character
	var target_to_character = parentCharacter.global_position - get_target_pos()
	var projection_length = target_to_character.dot(targetVelDirn)
	closest_point_on_line = get_target_pos() + targetVelDirn * projection_length
	var direction = (parentCharacter.global_position - closest_point_on_line).normalized() 
	
	if distance < flee_radius:
		desired_velocity = direction * parentCharacter.max_speed
		if use_leave:
			var ramped_speed = parentCharacter.max_speed * (1.0 - (distance / flee_radius))
			var clipped_speed = min (ramped_speed, parentCharacter.max_speed)
			desired_velocity = (clipped_speed / distance) * offset

	return desired_velocity

func debug_draw()->void:
	var flee_vector = parentCharacter.global_position - closest_point_on_line
	var local_target = parentCharacter.global_position + flee_vector
	local_target = to_local(local_target)
	var distance = flee_vector.length()
	if distance < flee_radius:
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
	if debug_radius:
		draw_arc(Vector2.ZERO, flee_radius, 0, TAU, 32, debugColor, 2.0)
