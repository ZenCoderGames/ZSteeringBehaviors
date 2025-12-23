@tool
extends Node2D

class_name ZAI_ContainmentZone

@export var radius: float = 300
@export var debugColor: Color = Color.WHITE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, debugColor, false, 2.0)
