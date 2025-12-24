@tool
extends ZAI_Spline

class_name ZAI_Path

@export var width:float = 30
@export var disable:bool = false

func init() -> void:
	super.init()
	
	if !disable and not Engine.is_editor_hint():
		ZAIManager.register_path(self)
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func set_active()->void:
	isActive = true
	timer.stop()
	timer.start(0.25)
	await timer.timeout
	isActive = false

func debug_draw()->void:
	if points.size() < 2 or spline_curve == null:
		return

	# Get tessellated points from the curve for smooth rendering
	var curve_points:PackedVector2Array = spline_curve.tessellate(5, curve_resolution)

	if curve_points.size() < 2:
		return

	# Create offset points on both sides of the path
	var left_points:PackedVector2Array = PackedVector2Array()
	var right_points:PackedVector2Array = PackedVector2Array()

	var half_width:float = width / 2.0

	for i in range(curve_points.size()):
		var current:Vector2 = curve_points[i]
		var normal:Vector2 = Vector2.ZERO

		# Calculate tangent direction based on neighboring points
		if i == 0:
			# First point - use direction to next point
			var tangent:Vector2 = (curve_points[i + 1] - current).normalized()
			normal = Vector2(-tangent.y, tangent.x)  # Perpendicular
		elif i == curve_points.size() - 1:
			# Last point - use direction from previous point
			var tangent:Vector2 = (current - curve_points[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)  # Perpendicular
		else:
			# Middle points - average of both directions for smoother corners
			var tangent1:Vector2 = (current - curve_points[i - 1]).normalized()
			var tangent2:Vector2 = (curve_points[i + 1] - current).normalized()
			var avg_tangent:Vector2 = (tangent1 + tangent2).normalized()
			normal = Vector2(-avg_tangent.y, avg_tangent.x)  # Perpendicular

		# Create offset points
		left_points.append(current + normal * half_width)
		right_points.append(current - normal * half_width)

	# Draw as individual quads between segments to avoid self-intersection
	var color:Color = lineColor
	color.a = 0.3  # Semi-transparent fill

	for i in range(left_points.size() - 1):
		var quad:PackedVector2Array = PackedVector2Array()
		quad.append(to_local(global_position + left_points[i]))
		quad.append(to_local(global_position + left_points[i + 1]))
		quad.append(to_local(global_position + right_points[i + 1]))
		quad.append(to_local(global_position + right_points[i]))

		draw_colored_polygon(quad, color)

	# Draw outline
	var left_local:PackedVector2Array = PackedVector2Array()
	var right_local:PackedVector2Array = PackedVector2Array()
	for point in left_points:
		left_local.append(to_local(global_position + point))
	for point in right_points:
		right_local.append(to_local(global_position + point))

	draw_polyline(left_local, lineColor, thickness)
	draw_polyline(right_local, lineColor, thickness)

	# Draw centerline with direction arrows
	var center_local:PackedVector2Array = PackedVector2Array()
	for point in curve_points:
		center_local.append(to_local(global_position + point))

	# Draw centerline
	draw_polyline(center_local, Color(lineColor.r, lineColor.g, lineColor.b, 0.6), thickness * 0.5)

	# Draw direction arrows at intervals
	var arrow_interval:int = max(1, curve_points.size() / 8)  # ~8 arrows along the path
	for i in range(0, curve_points.size() - 1, arrow_interval):
		var current:Vector2 = curve_points[i]
		var next:Vector2 = curve_points[min(i + 1, curve_points.size() - 1)]

		var direction:Vector2 = (next - current).normalized()
		var arrow_pos:Vector2 = current
		var arrow_size:float = width * 0.5

		# Draw arrow head
		var arrow_tip:Vector2 = arrow_pos + direction * arrow_size
		var arrow_left:Vector2 = arrow_pos + direction.rotated(deg_to_rad(90)) * arrow_size * 0.5
		var arrow_right:Vector2 = arrow_pos + direction.rotated(deg_to_rad(-90)) * arrow_size * 0.5

		var arrow_color:Color = Color(lineColor.r, lineColor.g, lineColor.b, 0.8)
		draw_line(to_local(global_position + arrow_tip), to_local(global_position + arrow_left), arrow_color, thickness * 1.5)
		draw_line(to_local(global_position + arrow_tip), to_local(global_position + arrow_right), arrow_color, thickness * 1.5)
