extends editor_Main
class_name editor_3D

func _init():
	props["position"] = {
		"locked"= false,
		"value"= Vector3(0, 10, 0),
		"type"= "vec3",
		"handler"= func(val: Vector3, obj: Node3D):
			obj.position = val
	}
	props["size"] = {
		"locked"= false,
		"value"= Vector3(10, 10, 10),
		"type"= "vec3",
		"handler"= func(val: Vector3, obj: Node3D):
			obj.scale = val
	}
	props["visible"] = {
		"locked"= false,
		"value"= true,
		"type"= "bool",
		"handler"= func(val: bool, obj: Node3D):
			obj.visible = val
	}

	description = "Any object that can get rendered in the 3D space"
	color = Color.RED
