extends ZAI_Behavior

class_name ZAI_Behavior_Seek

@export var use_arrival: bool = true
@export var arrival_radius: float = 100.0
@export var debug_draw: bool = true

var velocity: Vector2 = Vector2.ZERO

func update() -> Vector2:
	var target_position = get_global_mouse_position()
	if debug_draw:
		queue_redraw()
	var offset = target_position - global_position
	var distance = offset.length()
	var direction = offset.normalized()
	var desired_velocity = direction * parentCharacter.max_speed
	
	if distance < arrival_radius:
		var ramped_speed = parentCharacter.max_speed * (distance / arrival_radius)
		var clipped_speed = min (ramped_speed, parentCharacter.max_speed)
		desired_velocity = (clipped_speed / distance) * offset

	return desired_velocity

func _draw() -> void:
	if debug_draw:
		var target_position = get_global_mouse_position()
		var local_target = to_local(target_position)
		draw_arc(local_target, arrival_radius, 0, TAU, 32, Color.YELLOW, 2.0)
