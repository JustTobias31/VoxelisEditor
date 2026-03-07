extends Camera3D
var speed = 0.1
var sensitivity = 0.005
var camera_pitch = 0
var mousepos = null

func _process(_delta: float) -> void:
	if !current or !get_meta("inputEnabled"):
		return
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	translate(direction * speed)

func _input(event):
	if !current:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * sensitivity
		rotation.x -= event.relative.y * sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed /= 1.1
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				mousepos = get_viewport().get_mouse_position()
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_viewport().warp_mouse(mousepos)
				mousepos = null
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var space_state = get_world_3d().direct_space_state
			var mouse = get_viewport().get_mouse_position()

			var origin = project_ray_origin(mouse)
			var end = origin + project_ray_normal(mouse) * 1000
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			query.collide_with_areas = true
			
			var result = space_state.intersect_ray(query)
			
			if result.has("collider"):
				Objects.select(int(result.collider.get_parent().get_parent().name))
			else:
				Objects.select(null)
		speed = clamp(speed, 0.005, 2)
