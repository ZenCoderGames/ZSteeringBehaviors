extends ZAI_Behavior

class_name ZAI_Behavior_Containment

@export var containmentZone:ZAI_ContainmentZone =null

var targetPosition:Vector2 = Vector2.ZERO
	
func can_update()->bool:
	return containmentZone!=null
	
func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	var gravityVec:Vector2 = (containmentZone.global_position - parentCharacter.global_position)
	var gravitationalStrength:float = clamp((gravityVec.length() / containmentZone.radius), 0.0, 1.0)
	desired_velocity = gravityVec.normalized() * gravitationalStrength * parentCharacter.max_speed
	targetPosition = parentCharacter.global_position + desired_velocity
	
	desired_velocity += parentCharacter.velocity
	
	return desired_velocity
	
func debug_draw() -> void:
	draw_line(Vector2.ZERO, to_local(targetPosition), debugColor, 2)
