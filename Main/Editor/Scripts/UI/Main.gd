extends Node

@onready var tree = $Objects/Tree
var root
var objlist = {}

func create_tree_item(_item, _parent_item):
	var item : TreeItem = tree.create_item(_parent_item)
	item.set_text(0, _item.props.name.value)
	return item

func NewObject(obj, parent):
	var item
	if parent:
		item = create_tree_item(obj, objlist[parent.id])
	else:
		item = create_tree_item(obj, root)
	objlist[obj.id] = item

func _ready() -> void:
	tree.hide_root = true
	root = tree.create_item()
	Objects.created.connect(NewObject)
	Objects.propchanged.connect(func(obj:editor_Main,prop,val):
		if prop == "name":
			objlist[obj.id].set_text(0,val)
	)
	Objects.reselect.connect(func(id):
		tree.deselect_all()
		tree.set_selected(objlist[id],0)
	)
