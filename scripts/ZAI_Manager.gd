extends Node2D

class_name ZAI_Manager

@export var fps:int = 30

var characters:Array[ZAI_Character]
var obstacles:Array[ZAI_Obstacle]
var walls:Array[ZAI_Wall]
var paths:Array[ZAI_Path]
var is_paused:bool = false
var framestep_requested:bool = false

func _ready() -> void:
	Engine.max_fps = fps

func _process(delta: float) -> void:
	if is_paused:
		return
		
	for character in characters:
		if !character.disable:
			character.update(delta)
		
	# Handle framestep: pause again after one physics frame
	if framestep_requested:
		framestep_requested = false
		set_paused(true)
	
func register_character(character:ZAI_Character):
	characters.append(character)

func register_obstacle(obstacle:ZAI_Obstacle):
	obstacles.append(obstacle)

func get_obstacles()->Array[ZAI_Obstacle]:
	return obstacles

func register_wall(wall:ZAI_Wall):
	walls.append(wall)

func get_walls()->Array[ZAI_Wall]:
	return walls
	
func register_path(path:ZAI_Path):
	paths.append(path)

func get_paths()->Array[ZAI_Path]:
	return paths
	
func set_paused(val:bool) -> void:
	is_paused = val
	Engine.time_scale = 0.0 if is_paused else 1.0

func _input(event: InputEvent) -> void:
	if event.is_action_released("framestep_forward"):
		set_paused(false)
		framestep_requested = true

	if event.is_action_released("pause_game"):
		set_paused(true)
		
	if event.is_action_released("resume_game"):
		set_paused(false)
