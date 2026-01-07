extends CPUParticles2D

@export var AI_Char:ZAI_Character
@export var stopThreshold:float = 20

func _ready() -> void:
	color = Color(AI_Char.self_modulate, 175.0/255.0)

func _process(_delta: float) -> void:
	emitting = AI_Char.velocity.length()>stopThreshold
