@tool
extends ZAI_Spline

class_name ZAI_Path

@export var width:float = 30
@export var disable:bool = false

# Track problematic points that cause triangulation errors
var problematic_point_indices:Array[int] = []

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

func is_quad_valid(quad: PackedVector2Array) -> bool:
	if quad.size() != 4:
		return false

	# Check for degenerate quads (very small area or self-intersecting)
	# Calculate area using shoelace formula
	var area: float = 0.0
	for i in range(4):
		var j: int = (i + 1) % 4
		area += quad[i].x * quad[j].y
		area -= quad[j].x * quad[i].y
	area = abs(area / 2.0)

	# Reject if area is too small (degenerate)
	if area < 0.1:
		return false

	# Check for self-intersection by testing if edges cross
	# Edge 0-1 vs Edge 2-3 and Edge 1-2 vs Edge 3-0
	if segments_intersect(quad[0], quad[1], quad[2], quad[3]):
		return false
	if segments_intersect(quad[1], quad[2], quad[3], quad[0]):
		return false

	return true

func segments_intersect(a1: Vector2, a2: Vector2, b1: Vector2, b2: Vector2) -> bool:
	var d: float = (a2.x - a1.x) * (b2.y - b1.y) - (a2.y - a1.y) * (b2.x - b1.x)
	if abs(d) < 0.0001:
		return false  # Parallel or collinear

	var t: float = ((b1.x - a1.x) * (b2.y - b1.y) - (b1.y - a1.y) * (b2.x - b1.x)) / d
	var u: float = ((b1.x - a1.x) * (a2.y - a1.y) - (b1.y - a1.y) * (a2.x - a1.x)) / d

	return t >= 0.0 and t <= 1.0 and u >= 0.0 and u <= 1.0

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
		var is_first:bool = (i == 0)
		var is_last:bool = (i == curve_points.size() - 1)

		# For loops, the first and last points are duplicates, so handle specially
		if loop and is_first:
			# First point in a loop - average tangent from wrap-around
			var tangent1:Vector2 = (current - curve_points[curve_points.size() - 2]).normalized()
			var tangent2:Vector2 = (curve_points[i + 1] - current).normalized()
			var avg_tangent:Vector2 = (tangent1 + tangent2).normalized()
			normal = Vector2(-avg_tangent.y, avg_tangent.x)  # Perpendicular
		elif loop and is_last:
			# Last point in a loop is a duplicate of first - skip normal calculation
			# We'll use the first point's offset instead
			normal = Vector2.ZERO  # Placeholder, will copy from first point
		elif is_first:
			# First point (non-loop) - use direction to next point
			var tangent:Vector2 = (curve_points[i + 1] - current).normalized()
			normal = Vector2(-tangent.y, tangent.x)  # Perpendicular
		elif is_last:
			# Last point (non-loop) - use direction from previous point
			var tangent:Vector2 = (current - curve_points[i - 1]).normalized()
			normal = Vector2(-tangent.y, tangent.x)  # Perpendicular
		else:
			# Middle points - average of both directions for smoother corners
			var tangent1:Vector2 = (current - curve_points[i - 1]).normalized()
			var tangent2:Vector2 = (curve_points[i + 1] - current).normalized()
			var avg_tangent:Vector2 = (tangent1 + tangent2).normalized()
			normal = Vector2(-avg_tangent.y, avg_tangent.x)  # Perpendicular

		# Create offset points
		if loop and is_last:
			# For loop's last point (duplicate of first), use first point's offset
			left_points.append(left_points[0])
			right_points.append(right_points[0])
		else:
			left_points.append(current + normal * half_width)
			right_points.append(current - normal * half_width)

	# Draw as individual quads between segments to avoid self-intersection
	var color:Color = lineColor
	color.a = 0.3  # Semi-transparent fill

	# Clear previous problematic points tracking
	problematic_point_indices.clear()

	for i in range(left_points.size() - 1):
		var quad:PackedVector2Array = PackedVector2Array()
		quad.append(to_local(global_position + left_points[i]))
		quad.append(to_local(global_position + left_points[i + 1]))
		quad.append(to_local(global_position + right_points[i + 1]))
		quad.append(to_local(global_position + right_points[i]))

		# Validate quad before drawing to prevent triangulation errors
		if is_quad_valid(quad):
			draw_colored_polygon(quad, color)
		else:
			# Track this as a problematic segment
			# Map curve_points index back to original points
			var points_per_segment: float = float(curve_points.size()) / float(max(1, points.size() - 1))
			var approx_point_idx: int = int(float(i) / points_per_segment)

			# Mark both points of this segment as potentially problematic
			if approx_point_idx >= 0 and approx_point_idx < points.size():
				if not problematic_point_indices.has(approx_point_idx):
					problematic_point_indices.append(approx_point_idx)
			if approx_point_idx + 1 >= 0 and approx_point_idx + 1 < points.size():
				if not problematic_point_indices.has(approx_point_idx + 1):
					problematic_point_indices.append(approx_point_idx + 1)

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

	if Engine.is_editor_hint():
		# Draw direction arrows at intervals
		var arrow_interval:int = max(1, curve_points.size() / 8)  # ~8 arrows along the path
		for i in range(0, curve_points.size() - 1, arrow_interval):
			var current:Vector2 = curve_points[i]
			var next:Vector2 = curve_points[min(i + 1, curve_points.size() - 1)]

			var direction:Vector2 = (next - current).normalized()
			var arrow_pos:Vector2 = current
			var arrow_size:float = width * 0.25

			# Draw arrow head
			var arrow_tip:Vector2 = arrow_pos + direction * arrow_size
			var arrow_left:Vector2 = arrow_pos + direction.rotated(deg_to_rad(90)) * arrow_size * 0.5
			var arrow_right:Vector2 = arrow_pos + direction.rotated(deg_to_rad(-90)) * arrow_size * 0.5

			var arrow_color:Color = Color(lineColor.r, lineColor.g, lineColor.b, 0.8)
			draw_line(to_local(global_position + arrow_tip), to_local(global_position + arrow_left), arrow_color, thickness * 1.5)
			draw_line(to_local(global_position + arrow_tip), to_local(global_position + arrow_right), arrow_color, thickness * 1.5)
