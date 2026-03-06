extends Node

var objindex = [
	editor_Main,
	editor_3D,
	editor_Cube
]
var objects = {}
var selected = 0

signal created
signal propchanged
signal reselect

#######################################
func parent(obj : editor_Main, p : editor_Main):
	p.children.append(obj.id)
	obj.props.parent.value=p

func create(obj : editor_Main, p : editor_Main=null):
	var uid = randi_range(0,99999999)
	var model : Node3D = obj.model
	obj.id=uid
	obj.description=null
	objects[uid]=obj
	
	if obj.model:
		obj.model.name=str(uid)
		get_tree().get_root().add_child.call_deferred(obj.model)
	if p:
		setProperty(obj,"parent",p)
	for i in obj.props:
		var v = obj.props[i]
		if v.has("handler"):
			v.handler.call(v.value, obj.model)
	
	created.emit(obj,p)
	
	return uid
	
func setProperty(obj : editor_Main, key, value):
	var prop = obj.props[key]
	prop.value=value
	if key == "parent":
		objects[value.id].children.append(obj.id)
	if prop.has("handler"):
		prop.handler.call(value,obj.model)
	propchanged.emit(obj,key,value)

func select(id):
	if selected != 0:
		objects[selected].model.get_node("Main").material_overlay.set_shader_parameter("highlight", false)
	if id:
		selected = id
		objects[selected].model.get_node("Main").material_overlay.set_shader_parameter("highlight", true)
	else:
		selected = 0
	reselect.emit(id)
#######################################

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	var scene = objects[create(editor_3D.new())]
	setProperty(scene,"name","Scene")
	
	var scenefloor = objects[create(editor_Cube.new(),scene)]
	setProperty(scenefloor,"size",Vector3(100,1,100))
	setProperty(scenefloor,"color",Color.SLATE_GRAY)
	setProperty(scenefloor,"name","Floor")
	
	var cube = objects[create(editor_Cube.new(),scene)]
	setProperty(cube,"position",Vector3(0,5.5,0))
	
