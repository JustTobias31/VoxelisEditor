extends Node

var objects = {}

func info(path):
	var obj = load(path + "/script.gd").new()
	return obj

func create(obj,parent=null):
	var uid = randi_range(0,99999999)
	if obj.model:
		get_tree().get_root().add_child.call_deferred(obj.model)
	if parent:
		objects[parent].children.append(uid)
		objects[uid].parent=parent
	for i in obj.props:
		var v = obj.props[i]
		if v.has("handler") :
			v.handler.call(v.value, obj.model)
	objects[uid]=obj
	return uid

func _ready() -> void:
	create(editor_Cube.new())
