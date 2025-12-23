@tool
extends Node2D

class_name ZAI_Wall

@export var points:PackedVector2Array = PackedVector2Array():
	set(value):
		points = value
		build_spline()
		queue_redraw()
@export var thickness:float = 2.0
@export var curve_resolution:int = 20  # Points per segment for smooth curves
@export var disable:bool = false
@export var debugPassiveColor:Color = Color.WHITE
@export var debugActiveColor:Color = Color.FIREBRICK

var isActive:bool
var timer:Timer
var spline_curve:Curve2D

func _ready() -> void:
	build_spline()
	if !disable and not Engine.is_editor_hint():
		ZAIManager.register_wall(self)
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func build_spline() -> void:
	if points.size() < 2:
		return

	spline_curve = Curve2D.new()
	for point in points:
		spline_curve.add_point(point)
	
func _process(_delta: float) -> void:
	queue_redraw()
	
func set_active()->void:
	isActive = true
	timer.stop()
	timer.start(0.25)
	await timer.timeout
	isActive = false
	
func _draw() -> void:
	if points.size() < 2 or spline_curve == null:
		return

	# Get tessellated points from the curve for smooth rendering
	var curve_points:PackedVector2Array = spline_curve.tessellate(5, curve_resolution)

	# Convert to local coordinates
	var local_points:PackedVector2Array = PackedVector2Array()
	for point in curve_points:
		local_points.append(to_local(global_position + point))

	# Draw the spline
	var color:Color = debugActiveColor if isActive else debugPassiveColor
	draw_polyline(local_points, color, thickness)
