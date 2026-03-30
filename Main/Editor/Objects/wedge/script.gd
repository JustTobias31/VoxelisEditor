extends editor_3D
class_name editor_Wedge

func _init():
	super()
	props["color"] = {
		"locked"= false,
		"value"= Color.GRAY,
		"handler"= func(val: Color, obj: Node3D):
			obj.material_override.albedo_color=val
	}
	
	props["left_to_right"] = {
		"locked"= false,
		"value"= 0.0,
		"handler"= func(val, obj: Node3D):
			obj.mesh.left_to_right=clamp(val,0,1)
	}
	
	props.visible.locked=false
	props.name.value="Wedge"
	props.classname.value="Wedge"
	
	icon = load("res://Main/Editor/Objects/wedge/icon.svg")
	
	deletable = true
	description = "Wedge"
	modelasset=load("res://Main/Editor/Objects/wedge/model.tscn")
	
