@tool
extends EditorPlugin

var edited_spline:ZAI_Spline = null
var dragging_point:int = -1
var handle_size:float = 8.0

func _enter_tree() -> void:
	pass

func _exit_tree() -> void:
	edited_spline = null

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

	# Draw handles for each point
	for i in range(edited_spline.points.size()):
		var point_pos:Vector2 = canvas_transform * edited_spline.points[i]

		# Draw handle circle
		var color:Color = Color.CYAN if dragging_point == i else Color.WHITE
		viewport_control.draw_circle(point_pos, handle_size, color)
		viewport_control.draw_arc(point_pos, handle_size, 0, TAU, 32, Color.BLACK, 1.0)

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if edited_spline == null:
		return false

	var canvas_transform:Transform2D = edited_spline.get_viewport_transform() * edited_spline.get_global_transform()

	if event is InputEventMouseButton:
		var mb:InputEventMouseButton = event as InputEventMouseButton

		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				# Check if clicking on a handle
				for i in range(edited_spline.points.size()):
					var point_pos:Vector2 = canvas_transform * edited_spline.points[i]
					if mb.position.distance_to(point_pos) < handle_size * 1.5:
						dragging_point = i
						update_overlays()
						return true
			else:
				# Release
				if dragging_point != -1:
					dragging_point = -1
					update_overlays()
					return true

	elif event is InputEventMouseMotion:
		if dragging_point != -1:
			var mm:InputEventMouseMotion = event as InputEventMouseMotion

			# Convert screen position to local wall position
			var global_pos:Vector2 = canvas_transform.affine_inverse() * mm.position

			# Update the point
			var new_points:PackedVector2Array = edited_spline.points.duplicate()
			new_points[dragging_point] = global_pos
			edited_spline.points = new_points

			update_overlays()
			return true

	return false
