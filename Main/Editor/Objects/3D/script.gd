extends editor_Main
class_name editor_3D

func _init():
	props["position"] = {
		"locked"= false,
		"value"= Vector3(0, 0, 0),
		"handler"= func(val: Vector3, obj: Node3D):
			if obj:
				obj.position = val
	}
	props["size"] = {
		"locked"= false,
		"value"= Vector3(10, 10, 10),
		"handler"= func(val: Vector3, obj: Node3D):
			if obj:
				obj.scale = val
	}
	props["visible"] = {
		"locked"= true,
		"value"= true,
		"handler"= func(val: bool, obj: Node3D):
			if obj:
				obj.visible = val
	}
	
	props.parent.handler=func(val:editor_Main, obj:Node):
		if obj and val and val.model:
			obj.reparent.call_deferred(val.model)
	props.name.value="3D"
	props.classname.value="3D"
	
	description = "Any object that can get rendered in the 3D space"
