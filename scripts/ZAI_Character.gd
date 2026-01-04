extends Node2D

class_name ZAI_Character

@export var groupId: int = 0
@export var max_speed: float = 200.0
@export var max_force: float = 500.0
@export var mass: float = 1.0
@export var useSmoothRotation:bool = false
@export var rotation_speed: float = 8.0
@export var disable: bool = false
@export var debug: bool = false

enum FORCE_COMBINATION_TYPES { WEIGHTED_SUM, NO_OVERFLOW, ONLY_PRIORITIZED }
@export var forceCombinationType:FORCE_COMBINATION_TYPES = FORCE_COMBINATION_TYPES.WEIGHTED_SUM

@export var behaviorList:Array[ZAI_Behavior]

var prevVelocity:Vector2 = Vector2.ZERO
var velocity:Vector2 = Vector2.ZERO

signal OnWallCollision

func _ready() -> void:
	ZAIManager.register_character(self)
	
	if behaviorList.size()>1:
		behaviorList.sort_custom(func(a, b): return a.priority > b.priority)
	for behavior in behaviorList:
		behavior.init(self)

func update(delta: float) -> void:
	accumulate_forces_and_update(delta)
	queue_redraw()
	
func accumulate_forces_and_update(delta: float) -> void:
	prevVelocity = velocity
	
	var accumulatedForce = Vector2.ZERO
	
	if behaviorList.size()>0:
		for behavior in behaviorList:
			if behavior.can_update():
				var desired_velocity:Vector2 = behavior.update(delta) * behavior.weight
				if desired_velocity.length_squared()>0:
					accumulatedForce += desired_velocity
					#accumulatedForce += (desired_velocity - velocity)
					if forceCombinationType == FORCE_COMBINATION_TYPES.NO_OVERFLOW:
						if accumulatedForce.length() >= max_force:
							break
					elif forceCombinationType == FORCE_COMBINATION_TYPES.ONLY_PRIORITIZED:
						break

		accumulatedForce -= velocity

		var steering_force:Vector2 = (accumulatedForce).limit_length(max_force)

		#if steering_force.length()==0:
		#	return
		
		# Apply force with mass: F = ma, so a = F/m
		var acceleration_vector:Vector2 = steering_force / mass
		velocity += acceleration_vector
		velocity = velocity.limit_length(max_speed)
		
		global_position += velocity * delta
		
		# Rotate towards velocity direction
		if useSmoothRotation:
			global_rotation = lerp_angle(global_rotation, velocity.angle(), rotation_speed * delta)
		else:
			global_rotation = velocity.angle()

func _draw() -> void:
	if debug:
		draw_line(Vector2.ZERO, to_local(global_position + velocity), Color.LIME_GREEN, 2)
		draw_line(Vector2.ZERO, to_local(global_position + prevVelocity), Color.INDIAN_RED, 2)

# HELPERS
func get_behavior_of_type(behaviorType:Script) -> ZAI_Behavior:
	for behavior in behaviorList:
		if behavior.get_script() == behaviorType:
			return behavior
	return null
