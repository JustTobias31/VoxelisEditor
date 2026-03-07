extends Node

###### Scene viewer
@onready var tree = $Objects/Tree
var root
var objlist = {}

func create_tree_item(_item, _parent_item):
	var item : TreeItem = tree.create_item(_parent_item)
	item.set_meta("id",_item.id)
	item.set_icon(0, load("res://Main/Editor/Objects/%s/icon.svg" % _item.props.classname.value))
	item.set_icon_max_width(0, 10)
	item.set_text(0, _item.props.name.value)
	return item

func NewObject(obj,parent):
	var item
	if objlist.has(obj.id):
		objlist[obj.id].free()
	
	if parent:
		item = create_tree_item(obj, objlist[parent.id])
	else:
		item = create_tree_item(obj, root)
	objlist[obj.id] = item

###### Properties
@onready var props = $Properties/Tree
var root2
var proplist = {}

func create_prop_item(obj:editor_Main,propname):
	var prop = obj.props[propname]
	var item : TreeItem = props.create_item(root2)
	item.set_text(0, propname)
	match typeof(prop.value):
		TYPE_STRING:
			item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			item.set_text(1, prop.value)
			item.set_editable(1,!prop.locked)
			item.set_meta("obj",obj.id)
			
			if prop.locked:
				item.set_custom_color(1,Color.WEB_GRAY)
		TYPE_VECTOR3:
			item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			item.set_text(1, "Vector3")
			item.set_editable(1,false)
			
			var x : TreeItem = props.create_item(item)
			x.set_text(0, "X")
			x.set_custom_color(0,Color.from_string("ff5555",Color.RED))
			
			x.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			x.set_editable(1,!prop.locked)
			x.set_text(1,str(prop.value.x))
			
			x.set_meta("dimension","x")
			x.set_meta("obj",obj.id)
			x.set_meta("prop",propname)
			
			var y : TreeItem = props.create_item(item)
			y.set_text(0, "Y")
			y.set_custom_color(0,Color.from_string("6aff7c",Color.GREEN))
			
			y.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			y.set_editable(1,!prop.locked)
			y.set_text(1,str(prop.value.y))
			
			y.set_meta("dimension","y")
			y.set_meta("obj",obj.id)
			y.set_meta("prop",propname)
			
			var z : TreeItem = props.create_item(item)
			z.set_text(0, "Z")
			z.set_custom_color(0,Color.from_string("6393ff",Color.BLUE))
			
			z.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			z.set_editable(1,!prop.locked)
			z.set_text(1,str(prop.value.z))
			
			z.set_meta("dimension","z")
			z.set_meta("prop",propname)
			z.set_meta("obj",obj.id)
			
		TYPE_BOOL:
			item.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
			item.set_checked(1,prop.value)
			item.set_editable(1,!prop.locked)
			item.set_meta("obj",obj.id)
		TYPE_COLOR:
			item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			item.set_text(1,prop.value.to_html())
			item.set_custom_bg_color(1,prop.value,true)
			item.set_editable(1,!prop.locked)
			item.set_meta("obj",obj.id)
			
			var x : TreeItem = props.create_item(item)
			x.set_text(0, "R")
			x.set_custom_color(0,Color.from_string("ff5555",Color.RED))
			
			x.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			x.set_editable(1,!prop.locked)
			x.set_text(1,str(floor(prop.value.r*255)))
			
			x.set_meta("dimension","r")
			x.set_meta("obj",obj.id)
			x.set_meta("prop",propname)
			
			var y : TreeItem = props.create_item(item)
			y.set_text(0, "G")
			y.set_custom_color(0,Color.from_string("6aff7c",Color.GREEN))
			
			y.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			y.set_editable(1,!prop.locked)
			y.set_text(1,str(floor(prop.value.g*255)))
			
			y.set_meta("dimension","g")
			y.set_meta("obj",obj.id)
			y.set_meta("prop",propname)
			
			var z : TreeItem = props.create_item(item)
			z.set_text(0, "B")
			z.set_custom_color(0,Color.from_string("6393ff",Color.BLUE))
			
			z.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			z.set_editable(1,!prop.locked)
			z.set_text(1,str(floor(prop.value.b*255)))
			
			z.set_meta("dimension","b")
			z.set_meta("prop",propname)
			z.set_meta("obj",obj.id)
	return item

func render_props(obj):
	props.clear()
	proplist={}
	root2 = props.create_item()
	var objprops = obj.props
	for i in objprops:
		proplist[i]=create_prop_item(obj,i)
		

######################
var clipboard = null
var controls = {
	"copy" = func():
		if Objects.selected:
			clipboard=Objects.selected,
	"paste" = func():
		if Objects.objects.has(clipboard):
			Objects.copy(clipboard),
	"dupe" = func():
		if Objects.selected:
			Objects.copy(Objects.selected),
	"delete" = func():
		if Objects.selected and Objects.objects[Objects.selected].deletable:
			Objects.delete(Objects.selected),
	"new" = func():
		pass
}

func toolbar():
	###
	### Transform
	### Controls
	$Toolbar/Contents/copy.button_down.connect(controls.copy)
	$Toolbar/Contents/paste.button_down.connect(controls.paste)
	$Toolbar/Contents/duplicate.button_down.connect(controls.dupe)
	$Toolbar/Contents/delete.button_down.connect(controls.delete)
	### Object
	$Toolbar/Contents/Add.button_down.connect(controls.new)
	$Toolbar/Contents/cube.button_down.connect(func():
		Objects.create(editor_Cube.new())
	)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("editor_Copy",false,true):
		controls.copy.call()
	elif event.is_action_pressed("editor_Paste",false,true):
		controls.paste.call()
	elif event.is_action_pressed("editor_Delete",false,true):
		controls.delete.call()
	elif event.is_action_pressed("editor_Duplicate",false,true):
		controls.dupe.call()
	

func _ready() -> void:
	toolbar()
	###### Scene viewer
	tree.hide_root = true
	root = tree.create_item()
	Objects.created.connect(NewObject)
	Objects.propchanged.connect(func(obj:editor_Main,prop,val):
		if prop == "name":
			objlist[obj.id].set_text(0,val)
		elif prop == "parent":
			NewObject(obj,val)
		elif prop == "visible":
			objlist[obj.id].set_custom_color(0,Color.WHITE if val else Color.WEB_GRAY)
	)
	Objects.reselect.connect(func(id):
		tree.deselect_all()
		if id:
			tree.set_selected(objlist[id],0)
	)
	Objects.deleted.connect(func(obj,id):
		objlist[obj.id].free()
	)
	tree.cell_selected.connect(func():
		if tree.get_selected().get_meta("id") and Objects.objects[tree.get_selected().get_meta("id")] and Objects.selected != tree.get_selected().get_meta("id"):
			Objects.select(tree.get_selected().get_meta("id"))
	)
	###### Property viewer
	props.hide_root = true
	root2 = props.create_item()
	Objects.reselect.connect(func(id):
		if id:
			render_props(Objects.objects[id])
		else:
			props.clear()
	)
	props.item_edited.connect(func():
		var edited:TreeItem = props.get_edited()
		var obj:editor_Main = Objects.objects[edited.get_meta("obj")]
		if edited.has_meta("dimension"):
			if edited.get_text(1).is_valid_float():
				var prop = edited.get_meta("prop")
				var vector = obj.props[prop].value
				match edited.get_meta("dimension"):
					"x":
						Objects.setProperty(obj,prop,Vector3(float(edited.get_text(1)),vector.y,vector.z))
					"y":
						Objects.setProperty(obj,prop,Vector3(vector.x,float(edited.get_text(1)),vector.z))
					"z":
						Objects.setProperty(obj,prop,Vector3(vector.x,vector.y,float(edited.get_text(1))))
					"r":
						Objects.setProperty(obj,prop, Color8(
							int(edited.get_text(1)),
							vector.g*255,
							vector.b*255
						))
						proplist[prop].set_text(1,str(obj.props[prop].value.to_html()))
						proplist[prop].set_custom_bg_color(1,obj.props[prop].value,true)
					"g":
						Objects.setProperty(obj,prop, Color8(
							vector.r*255,
							int(edited.get_text(1)),
							vector.b*255
						))
						proplist[prop].set_text(1,str(obj.props[prop].value.to_html()))
						proplist[prop].set_custom_bg_color(1,obj.props[prop].value,true)
					"b":
						Objects.setProperty(obj,prop, Color8(
							vector.r*255,
							vector.g*255,
							int(edited.get_text(1))
						))
						proplist[prop].set_text(1,str(obj.props[prop].value.to_html()))
						proplist[prop].set_custom_bg_color(1,obj.props[prop].value,true)
			else:
				if typeof(obj.props[edited.get_meta("prop")].value) == TYPE_COLOR:
					edited.set_text(1,str(floor(obj.props[edited.get_meta("prop")].value[edited.get_meta("dimension")]*255)))
				else:
					edited.set_text(1,str(obj.props[edited.get_meta("prop")].value[edited.get_meta("dimension")]))
		else:
			var prop = edited.get_text(0)
			var current = obj.props[prop].value
			match typeof(current):
				TYPE_BOOL:
					var new = edited.is_checked(1)
					if typeof(new) != TYPE_BOOL: 
						edited.set_checked(1,current)
						return
					Objects.setProperty(obj,prop,new)
				TYPE_FLOAT:
					var new = edited.get_text(1)
					if !new.is_valid_float():
						edited.set_text(1,str(current))
						return
					Objects.setProperty(obj,prop,float(new))
				TYPE_COLOR:
					var new = edited.get_text(1)
					if !new.is_valid_html_color():
						edited.set_text(1,str(current.to_html()))
						return
					Objects.setProperty(obj,prop,Color.from_string(new,Color.WHITE))
					edited.set_custom_bg_color(1,obj.props[prop].value,true)
	)
	
