extends Node

var objects = {}
var selected = 0
var index = {
	"Main":editor_Main,
	"3D":editor_3D,
	"Cube":editor_Cube,
	"Wedge":editor_Wedge,
	"Sphere":editor_Sphere,
}
var history = UndoRedo.new()

signal created
signal propchanged
signal reselect
signal deleted

#######################################
func create(obj : editor_Main, p : editor_Main=null, uid : int=0,usehistory:bool=true):
	uid = uid if uid != 0 else randi_range(0,99999999)
	
	var make = func():
		obj.id=uid
		obj.description=null
		objects[uid]=obj
		
		if obj.modelasset:
			obj.model=obj.modelasset.instantiate()
			obj.model.name=str(uid)
			get_tree().get_root().get_node("/root/Ui/Main/Viewport/Viewport/Scene").add_child.call_deferred(obj.model)
		if p:
			setProperty(obj,"parent",p,false)
		for i in obj.props:
			var v = obj.props[i]
			if v.has("handler"):
				v.handler.call(v.value, obj.model)
				
		created.emit(obj,p)
		print("create ",uid)
	
	if usehistory:
		history.create_action(str(obj.id)+" create")
		history.add_do_method(make)
		history.add_undo_method(func():
			delete(uid,false)
		)
		history.commit_action()
	else:
		make.call()
	
	return uid
	
func setProperty(obj : editor_Main, key, value,usehistory:bool=true):
	var prop = obj.props[key]
	var edit = func(val):
		prop.value=val
		if key == "parent":
			if val and val is editor_Main and val.id in objects:
				objects[val.id].children.append(obj.id)
		if prop.has("handler"):
			prop.handler.call(val,obj.model)
			
		propchanged.emit(obj,key,val)
		print("prop edit ",obj.id, "; ", key)
	
	if usehistory:
		var oldval = prop.value
		
		history.create_action(str(obj.id)+" edit "+key)
		history.add_do_method(func():
			edit.call(value)
		)
		history.add_undo_method(func():
			edit.call(oldval)
		)
		history.commit_action()
	else:
		edit.call(value)

func select(id = null):
	if selected and selected in objects and objects[selected].model:
		objects[selected].model.material_overlay.set_shader_parameter("highlight", false)
	if id and id in objects:
		selected = id
		if objects[selected].model:
			objects[selected].model.material_overlay.set_shader_parameter("highlight", true)
	else:
		selected = null
	reselect.emit(selected)
	print("select ",id)
	
func copy(objid):
	var obj : editor_Main = objects[objid].clone()
	var uid = randi_range(0,99999999)
	var p = objects[objid].props.parent.value
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
	if p:
		setProperty(obj,"parent",p)
	created.emit(obj,p)
	print("cloned ",objid, "; ", uid)
	
	return uid

func delete(objid,usehistory:bool=true):
	var del = func():
		if !objects[objid].deletable:
			return false
		var vparent = objects[objid].props.parent.value
		if vparent and objects.has(vparent.id):
			objects[vparent.id].children.erase(objid)
		for child_id in objects[objid].children.duplicate():
			delete(child_id,false)
			
		if selected == objid:
			select()
		if objects[objid].model:
			objects[objid].model.queue_free()
		deleted.emit(objects[objid],objid)
		objects.erase(objid)
		print("deleted ",objid)
		
	if objects[objid]:
		if usehistory:
			var obj = index[objects[objid].props.classname.value]
			var props = objects[objid].props
			
			history.create_action(str(objid)+" delete")
			history.add_do_method(del)
			history.add_undo_method(func():
				var object = obj.new()
				create(object,props.parent.value,objid,false)
				for i in props:
					var v = props[i]
					setProperty(object,i,v.value,false)
			)
			history.commit_action()
		else:
			del.call()
		
	
#######################################

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	await Save.Load("res://default.ves")
	Save.unsaved=false
	
