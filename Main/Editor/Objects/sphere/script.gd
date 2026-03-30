extends editor_3D
class_name editor_Sphere

func _init():
	super()
	props["color"] = {
		"locked"= false,
		"value"= Color.GRAY,
		"handler"= func(val: Color, obj: Node3D):
			obj.material_override.albedo_color=val
	}
	
	props.visible.locked=false
	props.name.value="Sphere"
	props.classname.value="Sphere"
	
	icon = load("res://Main/Editor/Objects/sphere/icon.svg")
	
	deletable = true
	description = "Wedge"
	modelasset=load("res://Main/Editor/Objects/sphere/model.tscn")
	
