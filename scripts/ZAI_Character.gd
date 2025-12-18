extends Node2D

class_name ZAI_Character

@export var max_speed: float = 200.0
@export var max_force: float = 500.0
@export var mass: float = 1.0
@export var disable: bool = false
@export var debug_draw: bool = false

@export var behaviorList:Array[ZAI_Behavior]

var velocity:Vector2 = Vector2.ZERO

func _ready() -> void:
	behaviorList.sort_custom(func(a, b): return a.priority > b.priority)
	for behavior in behaviorList:
		behavior.init(self)

func _process(delta: float) -> void:
	if !disable:
		accumulate_forces_and_update(delta)

func accumulate_forces_and_update(delta: float) -> void:
	var desired_velocity = Vector2.ZERO
	
	if behaviorList.size()>0:
		var atleastOneBehaviorWasActive:bool = false
		for behavior in behaviorList:
			if behavior.can_update():
				desired_velocity += behavior.update(delta) * behavior.weight
				atleastOneBehaviorWasActive = true
		
		if atleastOneBehaviorWasActive==false:
			return
		
		var steering_force = (desired_velocity - velocity).limit_length(max_force)
		
		# Apply force with mass: F = ma, so a = F/m
		var acceleration_vector = steering_force / mass
		velocity += acceleration_vector
		velocity = velocity.limit_length(max_speed)

		global_position += velocity * delta

		# Rotate towards velocity direction
		if velocity.length_squared()>0:
			rotation = velocity.angle()
