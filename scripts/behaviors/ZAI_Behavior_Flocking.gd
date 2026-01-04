extends ZAI_Behavior

class_name ZAI_Behavior_Flocking

@export var groupId:int = -1
@export var radius:float = 200
@export var max_seperation_distance:float = 100
@export var seperation_weight:float = 1.0
@export var alignment_weight:float = 1.0
@export var cohesion_weight:float = 1.0

func update(delta: float) -> Vector2:
	super.update(delta)

	var desired_velocity:Vector2 = Vector2.ZERO
	
	var nearbyAIChars:Array[ZAI_Character] = ZAIManager.get_nearby_characters(parentCharacter.global_position, radius, groupId)
	
	# Seperation
	var seperationForce:Vector2 = Vector2.ZERO
	var totalAIChars:int = 0
	for aiChar in nearbyAIChars:
		if aiChar != parentCharacter:
			var diff:Vector2 = parentCharacter.global_position - aiChar.global_position
			var distance:float = diff.length()
			if distance > 0 and distance <= max_seperation_distance:
				var strength:float = 1.0 / (distance * distance)
				seperationForce += diff.normalized() * strength
				totalAIChars += 1

	if totalAIChars > 0:
		seperationForce /= totalAIChars
		seperationForce = seperationForce.normalized() * seperation_weight * parentCharacter.max_speed
	
	# Alignment
	var alignmentForce:Vector2 = Vector2.ZERO
	totalAIChars = 0
	for aiChar in nearbyAIChars:
		if aiChar != parentCharacter:
			alignmentForce += aiChar.velocity
			totalAIChars += 1

	if totalAIChars > 0:
		alignmentForce /= totalAIChars
		alignmentForce = alignmentForce.normalized() * alignment_weight * parentCharacter.max_speed

	# Cohesion
	var cohesionForce:Vector2 = Vector2.ZERO
	totalAIChars = 0
	var average_position = Vector2.ZERO
	for aiChar in nearbyAIChars:
		if aiChar != parentCharacter:
			average_position += aiChar.global_position
			totalAIChars += 1

	if totalAIChars > 0:
		average_position /= totalAIChars
		var approachVector:Vector2 = average_position - parentCharacter.global_position
		cohesionForce = approachVector.normalized() * cohesion_weight * parentCharacter.max_speed

	desired_velocity = (seperationForce + alignmentForce + cohesionForce)

	return desired_velocity

func debug_draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, debugColor, 2.0)
