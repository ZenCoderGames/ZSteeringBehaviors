@tool
extends Node2D

class_name ZAI_Spline

@export var points:PackedVector2Array = PackedVector2Array():
	set(value):
		points = value
		# Ensure control points arrays match size
		while point_in_controls.size() < points.size():
			point_in_controls.append(Vector2.ZERO)
		while point_out_controls.size() < points.size():
			point_out_controls.append(Vector2.ZERO)
		build_spline()
		queue_redraw()
@export var point_in_controls:Array[Vector2] = []
@export var point_out_controls:Array[Vector2] = []
@export var loop:bool = false:  # When true, connects last point back to first point
	set(value):
		loop = value
		if points.size() >= 2:
			build_spline()
			queue_redraw()
@export var lock_control_pairs:bool = false  # When true, control handles stay aligned through the point
@export var thickness:float = 2.0
@export var curve_resolution:int = 20  # Points per segment for smooth curves
@export var lineColor:Color = Color.WHITE

var isActive:bool
var timer:Timer
var spline_curve:Curve2D

func _ready() -> void:
	init()
	
func init()->void:
	build_spline()
	
func build_spline() -> void:
	if points.size() < 2:
		return

	spline_curve = Curve2D.new()
	for i in range(points.size()):
		var in_control:Vector2 = Vector2.ZERO
		var out_control:Vector2 = Vector2.ZERO

		if i < point_in_controls.size():
			in_control = point_in_controls[i]
		if i < point_out_controls.size():
			out_control = point_out_controls[i]

		spline_curve.add_point(points[i], in_control, out_control)

	# If loop is enabled, connect back to the first point
	if loop and points.size() >= 2:
		var first_in_control:Vector2 = Vector2.ZERO
		var first_out_control:Vector2 = Vector2.ZERO

		if point_in_controls.size() > 0:
			first_in_control = point_in_controls[0]
		if point_out_controls.size() > 0:
			first_out_control = point_out_controls[0]

		spline_curve.add_point(points[0], first_in_control, first_out_control)
	
func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	debug_draw()

func debug_draw()->void:
	if points.size() < 2 or spline_curve == null:
		return

	# Get tessellated points from the curve for smooth rendering
	var curve_points:PackedVector2Array = spline_curve.tessellate(5, curve_resolution)

	# Convert to local coordinates
	var local_points:PackedVector2Array = PackedVector2Array()
	for point in curve_points:
		local_points.append(to_local(global_position + point))

	# Draw the spline
	draw_polyline(local_points, lineColor, thickness)
