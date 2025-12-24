@tool
extends ZAI_Spline

class_name ZAI_Wall

@export var disable:bool = false
@export var debugPassiveColor:Color = Color.WHITE
@export var debugActiveColor:Color = Color.FIREBRICK

func init() -> void:
	super.init()
	
	if !disable and not Engine.is_editor_hint():
		ZAIManager.register_wall(self)
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func set_active()->void:
	isActive = true
	timer.stop()
	timer.start(0.25)
	await timer.timeout
	isActive = false
