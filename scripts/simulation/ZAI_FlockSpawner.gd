extends Node2D

class_name ZAI_FlockSpawner

@export var flockPrefab:PackedScene
@export var color:Color = Color.WHITE
@export var totalUnitCount:int = 5
@export var seekTarget:ZAI_Character
@export var fleeTarget:ZAI_Character
@export var groupId:int = -1

func _ready() -> void:
	for i in range(totalUnitCount):
		var flockUnit:ZAI_Character = flockPrefab.instantiate()
		flockUnit.self_modulate = color
		flockUnit.groupId = groupId
		add_child(flockUnit)

		# find the child AI_Seek Component and assign its target
		if seekTarget!=null:
			var seekBehavior:ZAI_Behavior_Seek = flockUnit.get_behavior_of_type(ZAI_Behavior_Seek)
			if seekBehavior!=null:
				seekBehavior.target_char = seekTarget

		# find the child AI_Flee Component and assign its target
		if fleeTarget!=null:
			var fleeBehavior:ZAI_Behavior_Flee = flockUnit.get_behavior_of_type(ZAI_Behavior_Flee)
			if fleeBehavior!=null:
				fleeBehavior.target_char = fleeTarget

		if groupId!=-1:
			var flockBehavior:ZAI_Behavior_Flocking = flockUnit.get_behavior_of_type(ZAI_Behavior_Flocking)
			if flockBehavior!=null:
				flockBehavior.groupId = groupId
				
		for child in flockUnit.get_children():
			if child is CPUParticles2D:
				var newColor:Color = Color(color.r, color.g, color.b, (175.0/255.0))
				child.color = newColor
