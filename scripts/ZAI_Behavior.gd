extends Node2D

class_name ZAI_Behavior

@export var weight: float = 1.0
@export var priority: float = 1.0
@export var disable: bool = false
@export var debug: bool = false

var parentCharacter:ZAI_Character

func init(parentChar:ZAI_Character):
	parentCharacter = parentChar
	
func can_update()->bool:
	return !disable
	
func update()->Vector2:
	queue_redraw()
	return Vector2.ZERO

func _draw()->void:
	if parentCharacter!=null and !disable and debug:
		debug_draw()
	
func debug_draw()->void:
	pass
	
func get_target_pos()->Vector2:
	if parentCharacter.target_char!=null:
		return parentCharacter.target_char.global_position
	else:
		return parentCharacter.target_pos
