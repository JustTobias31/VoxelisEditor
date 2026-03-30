extends Node

###### Scene viewer
@onready var tree = $Objects/Tree
var root
var objlist = {}
var toasts = 0

func create_tree_item(_item, _parent_item):
	var item : TreeItem = tree.create_item(_parent_item)
	item.set_meta("id",_item.id)
	item.set_icon(0, _item.icon)
	item.set_icon_max_width(0, 10)
	item.set_text(0, _item.props.name.value)
	return item

func NewObject(obj,parent):
	var item
	if objlist.has(obj.id) and objlist[obj.id]:
		objlist[obj.id].free()
		objlist.erase(obj.id)
	
	if parent:
		item = create_tree_item(obj, objlist[parent.id])
	else:
		item = create_tree_item(obj, root)
	objlist[obj.id] = item

func ShowToast(text):
	toasts += 1
	print(text)
	var tween = get_tree().create_tween()
	var toast = $"../Toast".duplicate(DuplicateFlags.DUPLICATE_DEFAULT)
	
	$"..".add_child(toast)
	toast.visible=true
	toast.get_node("Title").text=text
	
	tween.tween_property(toast,"position",Vector2(toast.position.x,650-70*toasts),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(toast.get_node("Time"),"value",0,3)
	tween.chain().tween_property(toast,"position",Vector2(toast.position.x,700),0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func():
		toasts -= 1
		toast.queue_free()
	)
	tween.play()

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
		TYPE_FLOAT:
			item.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			item.set_text(1, str(snapped(prop.value,0.01)))
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
			x.set_text(1,str(snapped(prop.value.x,0.01)))
			
			x.set_meta("dimension","x")
			x.set_meta("obj",obj.id)
			x.set_meta("prop",propname)
			
			var y : TreeItem = props.create_item(item)
			y.set_text(0, "Y")
			y.set_custom_color(0,Color.from_string("6aff7c",Color.GREEN))
			
			y.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			y.set_editable(1,!prop.locked)
			y.set_text(1,str(snapped(prop.value.y,0.01)))
			
			y.set_meta("dimension","y")
			y.set_meta("obj",obj.id)
			y.set_meta("prop",propname)
			
			var z : TreeItem = props.create_item(item)
			z.set_text(0, "Z")
			z.set_custom_color(0,Color.from_string("6393ff",Color.BLUE))
			
			z.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			z.set_editable(1,!prop.locked)
			z.set_text(1,str(snapped(prop.value.z,0.01)))
			
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

func ShowDropdown(button:Button,type:String):
	for i in $Dropdown.get_children():
		i.visible=false
	$Dropdown.get_node(type).visible=true
	$Dropdown.visible=true
	$Dropdown.position=Vector2(button.position.x,$Dropdown.position.y)
	

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
@onready var exportui = $"../Export"
@onready var camera = $Viewport/Viewport/Scene/Camera
func LoadPath(path):
	var out = Save.Load(path, true)
	if out is String:
		ShowToast("Load failed ("+out+").")
		return
	
	for i in Objects.objects:
		Objects.delete(i)
	await get_tree().create_timer(0.5).timeout
	
	Save.Load(path)
	Save.unsaved = false
	ShowToast("Project loaded successfuly!")

func toolbar():
	###
	$Toolbar/Contents/File.button_down.connect(func(): ShowDropdown($Toolbar/Contents/File,"File") )
	$Toolbar/Contents/Edit.button_down.connect(func(): $wip.popup_centered())
	$Toolbar/Contents/Export.button_down.connect(func():
		exportui.visible=true
	)
	
	
	### Gizmos
	$Toolbar/Contents/move.button_down.connect(func(): camera.gizmoType = 1)
	$Toolbar/Contents/scale.button_down.connect(func(): camera.gizmoType = 2)
	$Toolbar/Contents/Snap.text_submitted.connect(func(txt:String):
		if txt.is_valid_float():
			var val = snapped(clamp(float(txt),0.01,5),0.01)
			camera.gizmoSnap=val
		$Toolbar/Contents/Snap.text=str(snapped(camera.gizmoSnap,0.01))
	)
	$Toolbar/Contents/Snap.text=str(snapped(camera.gizmoSnap,0.01))
	
	$Toolbar/Contents/rotate.button_down.connect(func(): $wip.popup_centered())
	$Toolbar/Contents/SnapRot.text_submitted.connect(func(_txt:String):
		$wip.popup_centered()
	)
	### Controls
	$Toolbar/Contents/copy.button_down.connect(controls.copy)
	$Toolbar/Contents/paste.button_down.connect(controls.paste)
	$Toolbar/Contents/duplicate.button_down.connect(controls.dupe)
	$Toolbar/Contents/delete.button_down.connect(controls.delete)
	### History
	$Toolbar/Contents/undo.button_down.connect(func(): Objects.history.undo() )
	$Toolbar/Contents/redo.button_down.connect(func(): Objects.history.redo() )
	### Object
	$Toolbar/Contents/Add.button_down.connect(func(): $wip.popup_centered())
	
	$Toolbar/Contents/cube.button_down.connect(func(): Objects.create(editor_Cube.new()) )
	$Toolbar/Contents/wedge.button_down.connect(func(): Objects.create(editor_Wedge.new()) )
	$Toolbar/Contents/sphere.button_down.connect(func(): Objects.create(editor_Sphere.new()) )

func Dropdown():
	### File
	# Load
	$Dropdown/File/New.button_down.connect(func():
		$Dropdown.visible=false
		if $loadconfirm.visible: return
		if Save.unsaved:
			$loadconfirm.set_meta("path","res://default.ves")
			$loadconfirm.popup_centered()
		else:
			LoadPath("res://default.ves")
	)
	$Dropdown/File/Autosave.button_down.connect(func():
		$Dropdown.visible=false
		if $loadconfirm.visible: return
		if Save.unsaved:
			$loadconfirm.set_meta("path","user://autosave.ves")
			$loadconfirm.popup_centered()
		else:
			LoadPath("user://autosave.ves")
	)
	$Dropdown/File/Load.button_down.connect(func():
		$Dropdown.visible=false
		if $loadconfirm.visible: return
		
		if Save.unsaved:
			$loadconfirm.remove_meta("path")
			$loadconfirm.popup_centered()
		else:
			$load.popup_centered()
	)
	
	
	$loadconfirm.confirmed.connect(func():
		if $loadconfirm.has_meta("path"):
			LoadPath($loadconfirm.get_meta("path"))
		else:
			$load.popup_centered()
	)
	
	$load.file_selected.connect(func(path):
		LoadPath(path)
	)
	
	# Save
	$Dropdown/File/Save.button_down.connect(func():
		if $loadconfirm.visible: return
		$save.popup_centered()
	)
	
	$save.file_selected.connect(func(path):
		var out = Save.Save(path)
		if out == true:
			ShowToast("Project saved successfuly!")
		else:
			ShowToast("Save failed ("+out+").")
	)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and $Dropdown.visible:
		await get_tree().process_frame
		$Dropdown.visible=false
	
	elif event.is_action_pressed("editor_Copy",false,true):
		controls.copy.call()
	elif event.is_action_pressed("editor_Paste",false,true):
		controls.paste.call()
	elif event.is_action_pressed("editor_Delete",false,true):
		controls.delete.call()
	elif event.is_action_pressed("editor_Duplicate",false,true):
		controls.dupe.call()
	elif event.is_action_pressed("gizmo_Move",false,true):
		camera.gizmoType = 1
	elif event.is_action_pressed("gizmo_Size",false,true):
		camera.gizmoType = 2
	elif event.is_action_pressed("editor_Undo",false,true):
		Objects.history.undo()
	elif event.is_action_pressed("editor_Redo",false,true):
		Objects.history.redo()

func _ready() -> void:
	toolbar()
	Dropdown()
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
		if id and objlist.has(id):
			tree.set_selected(objlist[id],0)
	)
	Objects.deleted.connect(func(obj, id):
		if objlist.has(obj.id) and is_instance_valid(objlist[obj.id]):
			objlist[obj.id].free()
			objlist.erase(obj.id)
		for child_id in objlist.keys():
			if not is_instance_valid(objlist[child_id]):
				objlist.erase(child_id)
	)
	tree.cell_selected.connect(func():
		if tree.get_selected().get_meta("id") and Objects.objects[tree.get_selected().get_meta("id")] and Objects.selected != tree.get_selected().get_meta("id"):
			Objects.select(tree.get_selected().get_meta("id"))
	)
	###### Property viewer
	props.hide_root = true
	props.clip_contents=true
	
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
				TYPE_STRING:
					var new = edited.get_text(1)
					Objects.setProperty(obj,prop,new)
	)
	
