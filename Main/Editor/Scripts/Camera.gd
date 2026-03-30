extends Camera3D
var speed = 0.1
var sensitivity = 0.005
var camera_pitch = 0
var mousepos = null

############ Gizmo control
@onready var gizmoModel = $"../Gizmo"
var gizmoType = 1

var gizmoBegin = null
var gizmoCoord = null
var gizmoSize = null

var gizmoSnap = 0.1

var DragStartHit: Vector3
var DragStartPosition: Vector3
var DragStartScale: Vector3

func Ray(exclude,mouse):
	var space_state = get_world_3d().direct_space_state
	var origin = project_ray_origin(mouse)
	var end = origin + project_ray_normal(mouse) * 10000
	
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = exclude
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	if result.has("collider"):
		return result.collider
	

func UpdateGizmo():
	match gizmoType:
		1: # Move
			gizmoModel.get_node("Handles").visible=true
			gizmoModel.get_node("Scale").visible=false
			gizmoModel.get_node("Move").visible=true
			gizmoModel.get_node("Rotate").visible=false
		2: # Scale
			gizmoModel.get_node("Handles").visible=true
			gizmoModel.get_node("Scale").visible=true
			gizmoModel.get_node("Move").visible=false
			gizmoModel.get_node("Rotate").visible=false
		3: # Rotate
			gizmoModel.get_node("Handles").visible=false
			gizmoModel.get_node("Scale").visible=false
			gizmoModel.get_node("Move").visible=false
			gizmoModel.get_node("Rotate").visible=true
	if Objects.selected and Objects.selected in Objects.objects and Objects.objects[Objects.selected].model:
		gizmoModel.global_transform=Objects.objects[Objects.selected].model.global_transform
		gizmoModel.scale=Vector3(50,50,50)
	else:
		gizmoModel.get_node("Handles").visible=false
		gizmoModel.get_node("Scale").visible=false
		gizmoModel.get_node("Move").visible=false
		gizmoModel.get_node("Rotate").visible=false
	
func TranslateGizmo(
	axis: Vector3,
	screen_pos: Vector2,
	camera: Camera3D,
	drag_start_hit: Vector3,
):
	var to_camera = (camera.global_position - drag_start_hit).normalized()
	var plane_normal = axis.cross(to_camera).cross(axis).normalized()
	
	if plane_normal.length() < 0.001:
		plane_normal = to_camera
	
	var plane = Plane(plane_normal, drag_start_hit)
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)
	var hit = plane.intersects_ray(ray_origin, ray_dir)
	
	if hit == null:
		return Vector3(0,0,0)
	
	var motion = (hit - drag_start_hit).dot(axis)
	return axis * motion

func GetAxisVector(coord: String, bass:Basis) -> Vector3:
	match coord:
		"X": return bass.x
		"Y": return bass.y
		"Z": return bass.z
	return bass.x
	
############
func _process(_delta: float) -> void:
	if !current or !get_meta("inputEnabled") or get_viewport().gui_get_focus_owner() is LineEdit:
		return
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (Vector3(input_dir.x, 0, input_dir.y)).normalized()
	translate(direction * speed)
	UpdateGizmo()

func _input(event):
	if !current or !get_meta("inputEnabled"):
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * sensitivity
		rotation.x -= event.relative.y * sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
	elif event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_WHEEL_UP: ## Increase speed
			speed *= 1.1
			speed = clamp(speed, 0.005, 2)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN: ## Decrease speed
			speed /= 1.1
			speed = clamp(speed, 0.005, 2)
		elif event.button_index == MOUSE_BUTTON_RIGHT: ## Lock camera
			if event.pressed:
				mousepos = get_viewport().get_mouse_position()
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_viewport().warp_mouse(mousepos)
				mousepos = null
				
		#### Gizmo and select logic
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var result
			if !Objects.selected:
				result = Ray([gizmoModel],event.position)
				if result:
					Objects.select(int(result.get_parent().name))
					UpdateGizmo()
				return
				
			var exclude = []
			for obj in Objects.objects:
				obj = Objects.objects[obj]
				if obj.model:
					exclude.append(obj.model.get_node("Ray").get_rid())
			 
			result = Ray(exclude,event.position) # Gizmos finder
			exclude = null
			
			if !result:
				result = Ray([gizmoModel],event.position) # Object finder
				if !result:
					Objects.select(null)
					UpdateGizmo()
					return
				Objects.select(int(result.get_parent().name))
				UpdateGizmo()
			elif result.get_parent().get_parent().get_parent()==gizmoModel:
				gizmoBegin = event.position
				
				var selected = Objects.objects[Objects.selected]
				var selectedModel = selected.model
				
				gizmoCoord = GetAxisVector(result.get_parent().name,selectedModel.global_basis.orthonormalized())
				
				DragStartPosition = selectedModel.global_position
				DragStartScale = selectedModel.scale
				
				var toCam = (global_position - selectedModel.global_position).normalized()
				var planeNormal = gizmoCoord.cross(toCam).cross(gizmoCoord).normalized()
				var plane = Plane(planeNormal, selectedModel.global_position)
				
				DragStartHit = plane.intersects_ray(
					project_ray_origin(event.position),
					project_ray_normal(event.position)
				)
			else:
				Objects.select(null)
				UpdateGizmo()
		elif !event.pressed and gizmoCoord: ## Stop gizmo movement
			var selobj = Objects.objects[Objects.selected]
			Objects.setProperty(selobj, "size", selobj.model.scale)
			Objects.setProperty(selobj, "position", selobj.model.position)
			
			gizmoBegin=null
			gizmoCoord=null
			gizmoSize=null
			
	elif event is InputEventMouseMotion and gizmoCoord: ## Apply gizmo transform
		match gizmoType:
			1:
				var selobj = Objects.objects[Objects.selected]
				var model:Node3D = selobj.model
				var out = TranslateGizmo(
					gizmoCoord,
					event.position,
					self,
					DragStartHit,
				)
				var newpos = DragStartPosition +  out
				model.global_position = Vector3(snapped(newpos.x,gizmoSnap),snapped(newpos.y,gizmoSnap),snapped(newpos.z,gizmoSnap))
				
			2:
				var selobj = Objects.objects[Objects.selected]
				var model:Node3D = selobj.model
				var out = TranslateGizmo(
					gizmoCoord,
					event.position,
					self,
					DragStartHit,
				)
				var motion = out.dot(gizmoCoord)
				var localAxis = model.global_basis.orthonormalized().inverse() * gizmoCoord
				var newscale = DragStartScale + localAxis.abs() * motion
				var bass = model.global_basis.orthonormalized()
				
				if Input.is_key_pressed(KEY_SHIFT):
					match gizmoCoord:
						bass.x:
							model.scale = Vector3(snapped(newscale.x,gizmoSnap),snapped(newscale.y,gizmoSnap),snapped(newscale.x,gizmoSnap)).clamp(Vector3(0.001,0.001,0.001),Vector3(500,500,500))
						bass.y:
							model.scale = Vector3(snapped(newscale.y,gizmoSnap),snapped(newscale.y,gizmoSnap),snapped(newscale.y,gizmoSnap)).clamp(Vector3(0.001,0.001,0.001),Vector3(500,500,500))
						bass.z:
							model.scale = Vector3(snapped(model.scale.x,gizmoSnap),snapped(newscale.z,gizmoSnap),snapped(newscale.z,gizmoSnap)).clamp(Vector3(0.001,0.001,0.001),Vector3(500,500,500))
				else:
					model.scale = Vector3(snapped(newscale.x,gizmoSnap),snapped(newscale.y,gizmoSnap),snapped(newscale.z,gizmoSnap)).clamp(Vector3(0.001,0.001,0.001),Vector3(500,500,500))
				
				
