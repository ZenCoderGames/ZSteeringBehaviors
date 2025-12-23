extends ZAI_Behavior

class_name ZAI_Behavior_Wander

@export var strength:float = 0.5
@export var offsetFromCharacter:float = 50
@export var radius:float = 200
@export var debugRadius:bool = false

var targetPosition:Vector2 = Vector2.ZERO
var orientation:float = 0
var circleCenter:Vector2 = Vector2.ZERO
var prevForward:Vector2 = Vector2.ZERO

func init(parentChar:ZAI_Character):
	super.init(parentChar)
	
	orientation = parentCharacter.global_rotation_degrees + randf() * 360

func update(delta: float) -> Vector2:
	super.update(delta)
	
	var desired_velocity:Vector2 = Vector2.ZERO
	
	orientation += randf_range(-1, 1) * strength
	if orientation>=360 or orientation<=-360:
		orientation = 0
	#orientation = 0
	
	var forward:Vector2 = Vector2.RIGHT.rotated(parentCharacter.global_rotation)
	if parentCharacter.velocity.length_squared()>0:
		forward = parentCharacter.velocity.normalized()
		if prevForward.dot(forward)<0.8:
			orientation = parentCharacter.global_rotation_degrees
		prevForward = forward
	
	circleCenter = parentCharacter.global_position + forward * offsetFromCharacter
	
	var randomPointOnCircle:Vector2 = circleCenter
	randomPointOnCircle.x += radius * cos(deg_to_rad(orientation))
	randomPointOnCircle.y += radius * sin(deg_to_rad(orientation))
	
	targetPosition = randomPointOnCircle
	var direction:Vector2 = (targetPosition - parentCharacter.global_position).normalized()
	desired_velocity = direction * parentCharacter.max_speed

	return desired_velocity

func debug_draw() -> void:
	#var local_target:Vector2 = to_local(targetPosition)
	#draw_line(Vector2.ZERO, local_target, debugColor, 2)
	var randomPointOnCircle:Vector2 = circleCenter
	randomPointOnCircle.x += radius * cos(deg_to_rad(orientation))
	randomPointOnCircle.y += radius * sin(deg_to_rad(orientation))
	draw_arc(to_local(randomPointOnCircle), 5, 0, TAU, 32, Color.RED, 2.0)
	if debugRadius:
		draw_arc(to_local(circleCenter), radius, 0, TAU, 32, debugColor, 2.0)
