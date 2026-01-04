extends ZAI_Behavior

class_name ZAI_Behavior_Cohesion

@export var groupId:int = -1
@export var radius:float = 100

var target_position: Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	super.update(delta)

	var desired_velocity:Vector2 = Vector2.ZERO
	
	var nearbyAIChars:Array[ZAI_Character] = ZAIManager.get_nearby_characters(parentCharacter.global_position, radius, groupId)
	
	var totalAIChars:int = 0
	var average_position = Vector2.ZERO
	for aiChar in nearbyAIChars:
		if aiChar != parentCharacter:
			average_position += aiChar.global_position
			totalAIChars += 1
		
	# Calculate Average
	if totalAIChars > 0:
		average_position /= totalAIChars
		var approachVector:Vector2 = average_position - parentCharacter.global_position
		desired_velocity = approachVector.normalized() * parentCharacter.max_speed
	
	target_position = average_position
		
	#desired_velocity = Vector2.ZERO

	return desired_velocity

func debug_draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, debugColor, 2.0)
	draw_arc(to_local(target_position), 5, 0, TAU, 32, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, to_local(target_position), debugColor, 2.0)
