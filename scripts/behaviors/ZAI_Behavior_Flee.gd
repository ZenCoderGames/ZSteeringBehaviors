extends ZAI_Behavior

class_name ZAI_Behavior_Flee

@export var use_leave: bool = true
@export var flee_radius: float = 100.0
@export var debug_radius: bool = false

var velocity: Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var target_position = get_target_pos()
	var offset = global_position - target_position
	var distance = offset.length()
	var direction = offset.normalized()
	var desired_velocity = Vector2.ZERO
	
	if distance < flee_radius:
		desired_velocity = direction * parentCharacter.max_speed
		if use_leave:
			var ramped_speed = parentCharacter.max_speed * (1.0 - (distance / flee_radius))
			var clipped_speed = min (ramped_speed, parentCharacter.max_speed)
			desired_velocity = (clipped_speed / distance) * offset

	return desired_velocity

func debug_draw()->void:
	var target_position = get_target_pos()
	var local_target = global_position - target_position
	local_target = to_local(global_position + local_target)
	var offset = global_position - target_position
	var distance = offset.length()
	if distance < flee_radius:
		draw_line(Vector2.ZERO, local_target, debugColor, 2)
	if debug_radius:
		draw_arc(Vector2.ZERO, flee_radius, 0, TAU, 32, debugColor, 2.0)
