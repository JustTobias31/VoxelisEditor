extends Node

var objects = {}
var selected = 0

#######################################
func create(obj : editor_Main,parent=null):
	var uid = randi_range(0,99999999)
	var model : Node3D = obj.model
	if obj.model:
		obj.model.name=str(uid)
		get_tree().get_root().add_child.call_deferred(obj.model)
	if parent:
		objects[parent].children.append(uid)
		objects[uid].parent=parent
	for i in obj.props:
		var v = obj.props[i]
		if v.has("handler"):
			v.handler.call(v.value, obj.model)
	objects[uid]=obj
	obj.description=null
	return uid
	
func setProperty(obj : editor_Main, key, value):
	var prop = obj.props[key]
	prop.value=value
	prop.handler.call(value,obj.model)

func select(id):
	if selected != 0:
		objects[selected].model.get_node("Main").material_overlay.set_shader_parameter("highlight", false)
	if id:
		selected = id
		objects[selected].model.get_node("Main").material_overlay.set_shader_parameter("highlight", true)
	else:
		selected = 0
#######################################
func _ready() -> void:
	var scenefloor = objects[create(editor_Cube.new())]
	setProperty(scenefloor,"size",Vector3(100,1,100))
	setProperty(scenefloor,"color",Color.SLATE_GRAY)
	
	create(editor_Cube.new())
	
