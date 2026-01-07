@tool
extends Node2D

class_name ZAI_Obstacle

@export var radius:float = 50
@export var disable:bool = false
@export var debug:bool = false
@export var debugShowActive:bool = false
@export var debugPassiveColor:Color = Color.WHITE
@export var debugActiveColor:Color = Color.FIREBRICK

var isActive:bool
var timer:Timer

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if !disable:
		ZAIManager.register_obstacle(self)
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
	
func _process(_delta: float) -> void:
	queue_redraw()
	
func set_active()->void:
	isActive = true
	timer.stop()
	timer.start(0.25)
	await timer.timeout
	isActive = false
	
func _draw() -> void:
	if debug:
		var local_target:Vector2 = to_local(global_position)
		if debugShowActive:
			if isActive:
				draw_arc(local_target, radius, 0, TAU, 32, debugActiveColor, 2.0)
			else:
				draw_arc(local_target, radius, 0, TAU, 32, debugPassiveColor, 2.0)
		else:
			draw_arc(local_target, radius, 0, TAU, 32, debugPassiveColor, 2.0)
