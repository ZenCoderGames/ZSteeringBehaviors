@tool
extends EditorPlugin

var edited_spline:ZAI_Spline = null
var selected_point:int = -1  # Currently selected point (shows handles)
var dragging_point:int = -1
var dragging_handle_in:int = -1
var dragging_handle_out:int = -1
var handle_size:float = 8.0
var control_handle_size:float = 6.0

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	edited_spline = null

func draw_dashed_line(control: Control, from: Vector2, to: Vector2, color: Color, width: float, dash_length: float) -> void:
	var direction:Vector2 = to - from
	var length:float = direction.length()
	if length < 0.1:
		return

	var normalized:Vector2 = direction.normalized()
	var distance:float = 0.0
	var drawing:bool = true

	while distance < length:
		var segment_start:Vector2 = from + normalized * distance
		distance += dash_length
		var segment_end:Vector2 = from + normalized * min(distance, length)

		if drawing:
			control.draw_line(segment_start, segment_end, color, width)

		drawing = !drawing

func find_closest_curve_segment(click_pos: Vector2) -> Dictionary:
	var result:Dictionary = {}

	if edited_spline == null or edited_spline.spline_curve == null:
		return result

	var curve:Curve2D = edited_spline.spline_curve

	# Use Curve2D's built-in method to get closest offset
	var closest_offset:float = curve.get_closest_offset(click_pos)
	var closest_point:Vector2 = curve.sample_baked(closest_offset)

	# Check distance threshold
	var distance:float = click_pos.distance_to(closest_point)
	if distance > 20.0:  # 20 pixels threshold
		return result

	# Find which control point segment the closest point belongs to
	# by sampling the curve and checking distances to control points
	var num_segments:int = edited_spline.points.size() - 1
	# If loop is enabled, add one more segment (closing segment)
	if edited_spline.loop:
		num_segments += 1

	var segment_index:int = 0
	var min_segment_dist:float = INF

	# For each segment, check if the closest_point is closer to this segment's midpoint
	for i in range(num_segments):
		var point_a:Vector2 = edited_spline.points[i]
		var point_b:Vector2

		# Handle the closing segment for loops
		if i == edited_spline.points.size() - 1 and edited_spline.loop:
			point_b = edited_spline.points[0]
		else:
			point_b = edited_spline.points[i + 1]

		# Calculate distance from closest_point to the line segment between control points
		# This gives us a rough idea of which segment the point belongs to
		var segment_vec:Vector2 = point_b - point_a
		var t:float = (closest_point - point_a).dot(segment_vec) / segment_vec.length_squared()
		t = clamp(t, 0.0, 1.0)

		var nearest_on_line:Vector2 = point_a + segment_vec * t
		var dist:float = closest_point.distance_to(nearest_on_line)

		if dist < min_segment_dist:
			min_segment_dist = dist
			segment_index = i

	result["segment_index"] = segment_index
	result["position"] = closest_point
	result["offset"] = closest_offset
	return result

func _handles(object: Object) -> bool:
	return object is ZAI_Spline

func _edit(object: Object) -> void:
	if object is ZAI_Spline:
		edited_spline = object as ZAI_Spline
	else:
		edited_spline = null

func _make_visible(visible: bool) -> void:
	if not visible:
		edited_spline = null

func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	if edited_spline == null or edited_spline.points.size() == 0:
		return

	var canvas_transform:Transform2D = edited_spline.get_viewport_transform() * edited_spline.get_global_transform()

	# Draw Bezier control handles
	for i in range(edited_spline.points.size()):
		var point_pos:Vector2 = canvas_transform * edited_spline.points[i]
		var is_point_selected:bool = (selected_point == i)

		# Check if this point causes triangulation errors (for ZAI_Path)
		var is_problematic:bool = false
		if edited_spline is ZAI_Path:
			var path:ZAI_Path = edited_spline as ZAI_Path
			if path.problematic_point_indices.has(i):
				is_problematic = true

		# Only show control handles for the selected point
		if is_point_selected:
			var in_handle_pos:Vector2 = Vector2.ZERO
			var out_handle_pos:Vector2 = Vector2.ZERO
			var has_in_handle:bool = false
			var has_out_handle:bool = false

			# Draw in control handle (affects curve from PREVIOUS point)
			if i < edited_spline.point_in_controls.size():
				var in_control:Vector2 = edited_spline.point_in_controls[i]
				# If control is zero, show default handle position
				var handle_offset:Vector2 = in_control if in_control.length_squared() > 0.01 else Vector2(-30, 0)
				in_handle_pos = canvas_transform * (edited_spline.points[i] + handle_offset)
				has_in_handle = true
				var in_color:Color
				if is_problematic:
					in_color = Color.RED if dragging_handle_in == i else Color(1.0, 0.5, 0.5)
				else:
					in_color = Color.GREEN if dragging_handle_in == i else Color(0.5, 1.0, 0.5, 0.5 if in_control.length_squared() < 0.01 else 1.0)
				# Draw dashed line for "in" control to distinguish from "out"
				var line_color:Color = Color.RED if is_problematic else Color(0.0, 1.0, 0.0, 0.4)
				draw_dashed_line(viewport_control, point_pos, in_handle_pos, line_color, 1.0, 4.0)
				viewport_control.draw_circle(in_handle_pos, control_handle_size, in_color)
				viewport_control.draw_arc(in_handle_pos, control_handle_size, 0, TAU, 16, Color.BLACK, 1.0)

			# Draw out control handle (affects curve to NEXT point)
			if i < edited_spline.point_out_controls.size():
				var out_control:Vector2 = edited_spline.point_out_controls[i]
				# If control is zero, show default handle position
				var handle_offset:Vector2 = out_control if out_control.length_squared() > 0.01 else Vector2(30, 0)
				out_handle_pos = canvas_transform * (edited_spline.points[i] + handle_offset)
				has_out_handle = true
				var out_color:Color
				if is_problematic:
					out_color = Color.RED if dragging_handle_out == i else Color(1.0, 0.5, 0.5)
				else:
					out_color = Color.MAGENTA if dragging_handle_out == i else Color(1.0, 0.5, 1.0, 0.5 if out_control.length_squared() < 0.01 else 1.0)
				# Draw solid line for "out" control
				var out_line_color:Color = Color.RED if is_problematic else Color(1.0, 0.0, 1.0, 0.4)
				viewport_control.draw_line(point_pos, out_handle_pos, out_line_color, 2.0)
				viewport_control.draw_circle(out_handle_pos, control_handle_size, out_color)
				viewport_control.draw_arc(out_handle_pos, control_handle_size, 0, TAU, 16, Color.BLACK, 1.0)

			# If control pairs are locked, draw a connection line between handles
			if edited_spline.lock_control_pairs and has_in_handle and has_out_handle:
				viewport_control.draw_line(in_handle_pos, out_handle_pos, Color(1.0, 1.0, 0.0, 0.3), 1.5)

		# Draw main point handle (red if problematic, cyan if selected, white otherwise)
		var color:Color = Color.RED if is_problematic else (Color.CYAN if is_point_selected else Color.WHITE)

		viewport_control.draw_circle(point_pos, handle_size, color)
		viewport_control.draw_arc(point_pos, handle_size, 0, TAU, 32, Color.BLACK, 1.0)

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if edited_spline == null:
		return false

	var canvas_transform:Transform2D = edited_spline.get_viewport_transform() * edited_spline.get_global_transform()

	# Handle Delete key
	if event is InputEventKey:
		var key:InputEventKey = event as InputEventKey
		if key.pressed and key.keycode == KEY_DELETE and selected_point != -1:
			# Remove the selected point
			if selected_point < edited_spline.points.size():
				# Create new arrays without the selected point
				var new_points:PackedVector2Array = PackedVector2Array()
				for i in range(edited_spline.points.size()):
					if i != selected_point:
						new_points.append(edited_spline.points[i])

				# Remove corresponding control points
				if selected_point < edited_spline.point_in_controls.size():
					edited_spline.point_in_controls.remove_at(selected_point)
				if selected_point < edited_spline.point_out_controls.size():
					edited_spline.point_out_controls.remove_at(selected_point)

				# Update points (this will trigger rebuild)
				edited_spline.points = new_points

				# Deselect
				selected_point = -1
				update_overlays()
				return true

	if event is InputEventMouseButton:
		var mb:InputEventMouseButton = event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				# Alt+Click to insert new point on curve
				if mb.alt_pressed and edited_spline.spline_curve != null and edited_spline.points.size() >= 2:
					var click_pos:Vector2 = canvas_transform.affine_inverse() * mb.position
					var insert_result:Dictionary = find_closest_curve_segment(click_pos)

					if insert_result.has("segment_index") and insert_result.has("position") and insert_result.has("offset"):
						var segment_idx:int = insert_result["segment_index"]
						var new_point:Vector2 = insert_result["position"]
						var curve_offset:float = insert_result["offset"]

						# Calculate initial handle directions from curve tangent
						var curve:Curve2D = edited_spline.spline_curve
						var tangent:Vector2 = curve.sample_baked_with_rotation(curve_offset).x  # Get tangent direction

						# Determine next point index (handle loop closing segment)
						var next_idx:int = segment_idx + 1
						if edited_spline.loop and segment_idx == edited_spline.points.size() - 1:
							next_idx = 0

						# If tangent is zero, calculate from neighboring points
						if tangent.length_squared() < 0.01:
							var prev_point:Vector2 = edited_spline.points[segment_idx]
							var next_point:Vector2 = edited_spline.points[next_idx]
							tangent = (next_point - prev_point).normalized()

						# Calculate handle length (about 1/3 distance to neighbors)
						var prev_point:Vector2 = edited_spline.points[segment_idx]
						var next_point:Vector2 = edited_spline.points[next_idx]
						var handle_length:float = min(
							(new_point - prev_point).length(),
							(next_point - new_point).length()
						) * 0.33

						# Set handles along the tangent
						var in_handle:Vector2 = -tangent.normalized() * handle_length
						var out_handle:Vector2 = tangent.normalized() * handle_length

						# Insert new point after segment_idx
						var new_points:PackedVector2Array = PackedVector2Array()
						var insert_index:int = segment_idx + 1

						# Special case: if this is the closing segment in a loop, append at the end
						if edited_spline.loop and segment_idx == edited_spline.points.size() - 1:
							# Append to end
							for i in range(edited_spline.points.size()):
								new_points.append(edited_spline.points[i])
							new_points.append(new_point)
							insert_index = edited_spline.points.size()
						else:
							# Insert after segment_idx
							for i in range(edited_spline.points.size()):
								new_points.append(edited_spline.points[i])
								if i == segment_idx:
									new_points.append(new_point)

						# Insert calculated control points at the correct position
						edited_spline.point_in_controls.insert(insert_index, in_handle)
						edited_spline.point_out_controls.insert(insert_index, out_handle)

						# Update points
						edited_spline.points = new_points

						# Select the newly created point
						selected_point = insert_index
						update_overlays()
						return true

				var clicked_something:bool = false

				# Check if clicking on control handles of the selected point first
				if selected_point != -1 and selected_point < edited_spline.points.size():
					# Check in control handle
					if selected_point < edited_spline.point_in_controls.size():
						var in_control:Vector2 = edited_spline.point_in_controls[selected_point]
						var handle_offset:Vector2 = in_control if in_control.length_squared() > 0.01 else Vector2(-30, 0)
						var in_handle_pos:Vector2 = canvas_transform * (edited_spline.points[selected_point] + handle_offset)
						if mb.position.distance_to(in_handle_pos) < control_handle_size * 1.5:
							dragging_handle_in = selected_point
							update_overlays()
							return true

					# Check out control handle
					if selected_point < edited_spline.point_out_controls.size():
						var out_control:Vector2 = edited_spline.point_out_controls[selected_point]
						var handle_offset:Vector2 = out_control if out_control.length_squared() > 0.01 else Vector2(30, 0)
						var out_handle_pos:Vector2 = canvas_transform * (edited_spline.points[selected_point] + handle_offset)
						if mb.position.distance_to(out_handle_pos) < control_handle_size * 1.5:
							dragging_handle_out = selected_point
							update_overlays()
							return true

				# Check if clicking on a main point
				for i in range(edited_spline.points.size()):
					var point_pos:Vector2 = canvas_transform * edited_spline.points[i]
					if mb.position.distance_to(point_pos) < handle_size * 1.5:
						# Select this point
						selected_point = i
						dragging_point = i
						clicked_something = true
						update_overlays()
						return true

				# Clicked outside - deselect
				if not clicked_something:
					selected_point = -1
					update_overlays()
					return true
			else:
				# Release
				if dragging_point != -1 or dragging_handle_in != -1 or dragging_handle_out != -1:
					dragging_point = -1
					dragging_handle_in = -1
					dragging_handle_out = -1
					update_overlays()
					return true

	elif event is InputEventMouseMotion:
		var mm:InputEventMouseMotion = event as InputEventMouseMotion
		var local_pos:Vector2 = canvas_transform.affine_inverse() * mm.position

		if dragging_point != -1:
			# Update main point
			var new_points:PackedVector2Array = edited_spline.points.duplicate()
			new_points[dragging_point] = local_pos
			edited_spline.points = new_points
			update_overlays()
			return true

		elif dragging_handle_in != -1:
			# Update in control handle
			var control_offset:Vector2 = local_pos - edited_spline.points[dragging_handle_in]
			edited_spline.point_in_controls[dragging_handle_in] = control_offset

			# If control pairs are locked, update the opposite handle to maintain alignment
			if edited_spline.lock_control_pairs and dragging_handle_in < edited_spline.point_out_controls.size():
				var current_out:Vector2 = edited_spline.point_out_controls[dragging_handle_in]
				var out_length:float = current_out.length()

				# Keep the out handle's length but align it opposite to the in handle
				if control_offset.length_squared() > 0.01:
					var new_out_direction:Vector2 = -control_offset.normalized()
					edited_spline.point_out_controls[dragging_handle_in] = new_out_direction * out_length

			edited_spline.build_spline()
			edited_spline.queue_redraw()
			update_overlays()
			return true

		elif dragging_handle_out != -1:
			# Update out control handle
			var control_offset:Vector2 = local_pos - edited_spline.points[dragging_handle_out]
			edited_spline.point_out_controls[dragging_handle_out] = control_offset

			# If control pairs are locked, update the opposite handle to maintain alignment
			if edited_spline.lock_control_pairs and dragging_handle_out < edited_spline.point_in_controls.size():
				var current_in:Vector2 = edited_spline.point_in_controls[dragging_handle_out]
				var in_length:float = current_in.length()

				# Keep the in handle's length but align it opposite to the out handle
				if control_offset.length_squared() > 0.01:
					var new_in_direction:Vector2 = -control_offset.normalized()
					edited_spline.point_in_controls[dragging_handle_out] = new_in_direction * in_length

			edited_spline.build_spline()
			edited_spline.queue_redraw()
			update_overlays()
			return true

	return false
