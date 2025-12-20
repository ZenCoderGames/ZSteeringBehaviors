extends Node2D

class_name ZAI_Obstacle

@export var radius:float = 50
@export var debugColor:Color = Color.FIREBRICK

func _ready() -> void:
	ZAIManager.register_obstacle(self)

func _draw() -> void:
	var local_target:Vector2 = to_local(global_position)
	draw_arc(local_target, radius, 0, TAU, 32, debugColor, 2.0)
