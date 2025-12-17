extends Node2D

class_name ZAI_Behavior

@export var weight: float = 1.0
@export var priority: float = 1.0

var parentCharacter:ZAI_Character

func init(parentChar:ZAI_Character):
	parentCharacter = parentChar
	
func update()->Vector2:
	return Vector2.ZERO
