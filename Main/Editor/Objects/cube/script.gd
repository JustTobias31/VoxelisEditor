extends editor_3D
class_name editor_Cube

func _init():
	super()
	props["color"] = {
		"locked"= false,
		"value"= Color.GRAY,
		"type"= "vec3",
		"handler"= func(val: Color, obj: Node3D):
			obj.get_node("Main").material_override.albedo_color=val
	}
	
	props.name.value="Cube"
	props.classname.value="Cube"
	
	deletable = true
	description = "Cube"
	model=load("res://Main/Editor/Objects/cube/model.tscn").instantiate()
	
