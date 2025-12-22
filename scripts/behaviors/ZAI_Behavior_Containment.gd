extends ZAI_Behavior

class_name ZAI_Behavior_Containment

@export var radius:float = 100
@export var centerPos:Vector2 = Vector2.ZERO
@export var centerNode:Node2D = null
@export var debugForce:bool = false

var targetPosition:Vector2 = Vector2.ZERO

func init(parentChar:ZAI_Character):
	super.init(parentChar)
	
	if centerNode!=null:
		centerPos = centerNode.global_position
	
func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	var gravityVec:Vector2 = (centerPos - parentCharacter.global_position)
	var gravitationalStrength:float = clamp((gravityVec.length() / radius), 0.0, 1.0)
	desired_velocity = gravityVec.normalized() * gravitationalStrength * parentCharacter.max_speed + parentCharacter.velocity
	
	targetPosition = parentCharacter.global_position + desired_velocity
	
	return desired_velocity
	
func debug_draw() -> void:
	draw_arc(to_local(centerPos), radius, 0, TAU, 32, debugColor, 2.0)
	if debugForce:
		draw_line(Vector2.ZERO, to_local(targetPosition), debugColor, 2)
