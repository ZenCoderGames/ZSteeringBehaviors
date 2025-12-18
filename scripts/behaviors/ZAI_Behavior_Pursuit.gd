extends ZAI_Behavior

class_name ZAI_Behavior_Pursuit

@export var use_arrival: bool = true
@export var arrival_radius: float = 100.0
@export var prediction_time: float = 1.0
@export var offset: Vector2 = Vector2.ZERO
@export var offsetRecalcThreshold: float = 50.0
@export var debug_arrival: bool = false

var previous_target_position: Vector2 = Vector2.ZERO
var stored_offset_target_position: Vector2 = Vector2.ZERO
var has_previous_targetpos_been_set: bool = false

func can_update()->bool:
	if !super.can_update():
		return false
	
	return target_char!=null

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var target_position = get_target_pos()
	var fps := Engine.get_frames_per_second()
	target_position += target_char.velocity * fps * prediction_time * delta
	var distFromPrevTargetPos = (target_position - previous_target_position).length()
	if !has_previous_targetpos_been_set or distFromPrevTargetPos > offsetRecalcThreshold:
		previous_target_position = target_position
		has_previous_targetpos_been_set = true
		var directionToPrevTargetPos = (target_position - parentCharacter.global_position).normalized()	
		stored_offset_target_position = target_position + offset.y * directionToPrevTargetPos + offset.x * directionToPrevTargetPos.orthogonal()
	var approachVector = stored_offset_target_position - parentCharacter.global_position
	var distance = approachVector.length()
	var direction = approachVector.normalized()
	var desired_velocity = direction * parentCharacter.max_speed
	
	if use_arrival and distance < arrival_radius:
		var ramped_speed = parentCharacter.max_speed * (distance / arrival_radius)
		var clipped_speed = min (ramped_speed, parentCharacter.max_speed)
		desired_velocity = (clipped_speed / distance) * approachVector

	return desired_velocity

func debug_draw() -> void:
	var local_target = to_local(stored_offset_target_position)
	draw_circle(local_target, 5, debugColor)
	draw_line(Vector2.ZERO, local_target, debugColor, 2)
	if debug_arrival:
		draw_arc(local_target, arrival_radius, 0, TAU, 32, debugColor, 2.0)
