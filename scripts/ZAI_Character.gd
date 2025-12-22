extends Node2D

class_name ZAI_Character

@export var max_speed: float = 200.0
@export var max_force: float = 500.0
@export var mass: float = 1.0
@export var rotation_speed: float = 8.0
@export var facingRecalcThreshold: float = 0.0
@export var disable: bool = false
@export var debug: bool = false

@export var behaviorList:Array[ZAI_Behavior]

var velocity:Vector2 = Vector2.ZERO

func _ready() -> void:
	behaviorList.sort_custom(func(a, b): return a.priority > b.priority)
	for behavior in behaviorList:
		behavior.init(self)

func _process(delta: float) -> void:
	if !disable:
		accumulate_forces_and_update(delta)
		queue_redraw()

func accumulate_forces_and_update(delta: float) -> void:
	var accumulatedForce = Vector2.ZERO
	
	if behaviorList.size()>0:
		var atleastOneBehaviorWasActive:bool = false
		for behavior in behaviorList:
			if behavior.can_update():
				var desired_velocity:Vector2 = behavior.update(delta) * behavior.weight
				if desired_velocity.length_squared()>0:
					accumulatedForce += (desired_velocity - velocity)
					atleastOneBehaviorWasActive = true
					if accumulatedForce.length() >= max_force:
						break
		
		if atleastOneBehaviorWasActive==false:
			return
		
		var steering_force:Vector2 = accumulatedForce.limit_length(max_force)
		
		# Apply force with mass: F = ma, so a = F/m
		var acceleration_vector:Vector2 = steering_force / mass
		velocity += acceleration_vector
		velocity = velocity.limit_length(max_speed)
		
		global_position += velocity * delta
		
		# Rotate towards velocity direction
		if velocity.length_squared()>facingRecalcThreshold:
			global_rotation = lerp_angle(global_rotation, velocity.angle(), rotation_speed * delta)
			#rotation = velocity.angle()

func _draw() -> void:
	if debug:
		var local_target:Vector2 = to_local(global_position + velocity)
		draw_line(Vector2.ZERO, local_target, Color.LIME_GREEN, 2)
