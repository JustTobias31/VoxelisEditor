extends Camera3D
var speed = 0.1
var sensitivity = 0.005
var camera_pitch = 0
var mousepos = null


func _process(_delta: float) -> void:
	if !current:
		return
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	translate(direction * speed)

func _input(event):
	if !current:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * sensitivity
		camera_pitch -= event.relative.y * sensitivity
		camera_pitch = clamp(camera_pitch, deg_to_rad(-90), deg_to_rad(90))
		rotation.x = camera_pitch
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
		speed = clamp(speed, 0.005, 2)
