extends Node2D

class_name ZAI_Manager

@export var fps:int = 60

func _ready() -> void:
	Engine.max_fps = fps
