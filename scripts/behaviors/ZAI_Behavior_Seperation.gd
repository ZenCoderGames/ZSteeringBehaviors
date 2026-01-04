extends ZAI_Behavior

class_name ZAI_Behavior_Seperation

@export var groupId:int = -1
@export var radius:float = 200
@export var max_seperation_distance:float = 100

func update(delta: float) -> Vector2:
	super.update(delta)

	var desired_velocity:Vector2 = Vector2.ZERO
	
	var nearbyAIChars:Array[ZAI_Character] = ZAIManager.get_nearby_characters(parentCharacter.global_position, radius, groupId)
	
	var totalAIChars:int = 0
	for aiChar in nearbyAIChars:
		if aiChar != parentCharacter:
			var diff:Vector2 = parentCharacter.global_position - aiChar.global_position
			var distance:float = diff.length()
			if distance > 0 and distance <= max_seperation_distance:
				var strength:float = 1.0 / (distance * distance)
				desired_velocity += diff.normalized() * strength
				totalAIChars += 1

	# Calculate Average
	if totalAIChars > 0:
		desired_velocity /= totalAIChars
		desired_velocity = desired_velocity.normalized() * parentCharacter.max_speed

	return desired_velocity

func debug_draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, debugColor, 2.0)
