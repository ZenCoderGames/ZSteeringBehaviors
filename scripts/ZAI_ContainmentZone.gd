@tool
extends Node2D

class_name ZAI_ContainmentZone

enum ZONE_TYPE { CIRCLE, BOX }
@export var type:ZONE_TYPE

@export var radius: float = 300
@export var boxTopLeft:Vector2 = Vector2.ZERO
@export var boxBotRight:Vector2 = Vector2.ZERO
@export var debugColor: Color = Color.WHITE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	if type==ZONE_TYPE.CIRCLE:
		draw_circle(Vector2.ZERO, radius, debugColor, false, 2.0)
	elif type==ZONE_TYPE.BOX:
		var rect:Rect2 = Rect2(boxTopLeft, boxBotRight - boxTopLeft)
		draw_rect(rect, debugColor, false, 2.0)
		draw_circle(rect.get_center(), 5, debugColor, true)
