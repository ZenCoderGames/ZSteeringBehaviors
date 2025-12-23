extends ZAI_Behavior

class_name ZAI_Behavior_Containment

@export var containmentZone:ZAI_ContainmentZone =null

var targetPosition:Vector2 = Vector2.ZERO
	
func can_update()->bool:
	return containmentZone!=null
	
func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	if containmentZone.type==ZAI_ContainmentZone.ZONE_TYPE.CIRCLE:
		var gravityVec:Vector2 = (containmentZone.global_position - parentCharacter.global_position)
		var gravitationalStrength:float = clamp((gravityVec.length() / containmentZone.radius), 0.0, 1.0)
		desired_velocity = gravityVec.normalized() * gravitationalStrength
	elif containmentZone.type==ZAI_ContainmentZone.ZONE_TYPE.BOX:
		var boxRect:Rect2 = Rect2(containmentZone.global_position + containmentZone.boxTopLeft, containmentZone.boxBotRight - containmentZone.boxTopLeft)
		var boxCenter:Vector2 = boxRect.get_center()
		var gravitationalStrength:Vector2 = Vector2.ZERO
		gravitationalStrength.x = abs(parentCharacter.global_position.x - boxCenter.x)/(boxRect.size.x/2)
		gravitationalStrength.y = abs(parentCharacter.global_position.y - boxCenter.y)/(boxRect.size.y/2)
		var gravityVec:Vector2 = Vector2.ZERO
		gravityVec.x = boxCenter.x - parentCharacter.global_position.x
		gravityVec.y = boxCenter.y - parentCharacter.global_position.y
		desired_velocity = gravityVec.normalized() * gravitationalStrength.length()

	desired_velocity *= parentCharacter.max_speed
	targetPosition = parentCharacter.global_position + desired_velocity
	desired_velocity += parentCharacter.velocity
	
	return desired_velocity
	
func debug_draw() -> void:
	draw_line(Vector2.ZERO, to_local(targetPosition), debugColor, 2)
