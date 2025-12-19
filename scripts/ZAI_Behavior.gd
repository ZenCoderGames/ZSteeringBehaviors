extends Node2D

class_name ZAI_Behavior

@export var weight: float = 1.0
@export var priority: float = 1.0
@export var disable: bool = false
@export var debug: bool = false
@export var debugColor: Color = Color.WHITE

@export var target_char:ZAI_Character
var target_pos:Vector2 = Vector2.ZERO

var parentCharacter:ZAI_Character

func init(parentChar:ZAI_Character):
	parentCharacter = parentChar
	
func can_update()->bool:
	return !disable
	
func update(_delta: float)->Vector2:
	queue_redraw()
	return Vector2.ZERO

func _draw()->void:
	if parentCharacter!=null and !disable and debug:
		debug_draw()

func debug_draw()->void:
	pass
	
func get_target_pos()->Vector2:
	if target_char!=null:
		return target_char.global_position
	else:
		return target_pos

func set_target_pos(pos:Vector2)->void:
	target_pos = pos
