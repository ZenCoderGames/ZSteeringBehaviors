extends Node2D

class_name ZAI_Manager

@export var fps:int = 30

var obstacles:Array[ZAI_Obstacle]

func _ready() -> void:
	Engine.max_fps = fps

func register_obstacle(obstacle:ZAI_Obstacle):
	obstacles.append(obstacle)

func get_obstacles()->Array[ZAI_Obstacle]:
	return obstacles
