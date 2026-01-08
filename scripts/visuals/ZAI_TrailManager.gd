extends CPUParticles2D

class_name ZAI_TrailManager

@export var stopThreshold:float = 20

var parentCharacter:ZAI_Character

func _ready() -> void:
	# Recursively find parent ZAI_Character if not manually assigned
	if parentCharacter == null:
		var current_node = get_parent()
		while current_node != null:
			if current_node is ZAI_Character:
				parentCharacter = current_node
				break
			current_node = current_node.get_parent()

	if parentCharacter != null:
		color = Color(parentCharacter.self_modulate, 175.0/255.0)

func _process(_delta: float) -> void:
	if parentCharacter != null:
		emitting = parentCharacter.velocity.length()>stopThreshold
