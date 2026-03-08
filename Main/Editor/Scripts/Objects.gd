extends Node

var objects = {}
var selected = 0

signal created
signal propchanged
signal reselect
signal deleted

#######################################
func parent(obj : editor_Main, p : editor_Main):
	p.children.append(obj.id)
	obj.props.parent.value=p

func create(obj : editor_Main, p : editor_Main=null):
	var uid = randi_range(0,99999999)
	obj.id=uid
	obj.description=null
	objects[uid]=obj
	
	if obj.modelasset:
		obj.model=obj.modelasset.instantiate()
		obj.model.name=str(uid)
		get_tree().get_root().get_node("/root/Ui/Main/Viewport/Viewport/Scene").add_child.call_deferred(obj.model)
	if p:
		setProperty(obj,"parent",p)
	for i in obj.props:
		var v = obj.props[i]
		if v.has("handler"):
			v.handler.call(v.value, obj.model)
	
	created.emit(obj,p)
	print(get_tree().get_root().get_children())
	
	return uid
	
func setProperty(obj : editor_Main, key, value):
	var prop = obj.props[key]
	prop.value=value
	if key == "parent":
		objects[value.id].children.append(obj.id)
	if prop.has("handler"):
		prop.handler.call(value,obj.model)
	propchanged.emit(obj,key,value)

func select(id = null):
	if selected != 0 and objects[selected].model:
		objects[selected].model.material_overlay.set_shader_parameter("highlight", false)
	if id:
		selected = id
		if objects[selected].model:
			objects[selected].model.material_overlay.set_shader_parameter("highlight", true)
	else:
		selected = 0
	reselect.emit(id)
	
func copy(objid):
	var obj : editor_Main = objects[objid].clone()
	var uid = randi_range(0,99999999)
	var p = objects[objid].props.parent.value
	obj.id=uid
	obj.description=null
	objects[uid]=obj
	
	if obj.modelasset:
		obj.model=obj.modelasset.instantiate()
		get_tree().get_root().get_node("/root/Ui/Main/Viewport/Viewport/Scene").add_child.call_deferred(obj.model)
	if p:
		setProperty(obj,"parent",p)
	for i in obj.props:
		var v = obj.props[i]
		if v.has("handler"):
			v.handler.call(v.value, obj.model)
	if p:
		setProperty(obj,"parent",p)
	created.emit(obj,p)
	
	return uid

func delete(objid):
	if objects[objid]:
		if !objects[objid].deletable:
			return false
		if selected == objid:
			select()
		if objects[objid].model:
			objects[objid].model.queue_free()
		deleted.emit(objects[objid],objid)
		objects.erase(objid)
	
#######################################

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	
	var scenefloor = objects[create(editor_Cube.new())]
	setProperty(scenefloor,"size",Vector3(100,1,100))
	setProperty(scenefloor,"color",Color.SLATE_GRAY)
	setProperty(scenefloor,"name","Floor")
	
