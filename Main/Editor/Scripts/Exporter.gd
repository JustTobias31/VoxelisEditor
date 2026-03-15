extends Panel

const starts = {
	"Config" = 0,
	"Layering" = 1,
	"Rendering" = 2,
	"Finalizing" = 3,
	"Finish" = 4
}

var cfg = {
	"Directory" = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP),
	"Height" = 200,
	"Layers" = 20,
	
	"SizeX" = 1048,
	"SizeY" = 1048,
}
var default = cfg.duplicate()
var starttime = Time.get_unix_time_from_system()
var stop = false
var state = 0

@onready var cam = $"../Main/Viewport/Viewport/Scene/Camera"
@onready var visualizer = $"../Main/Viewport/Viewport/Scene/ExportVisualize"

### UI
func VisualizeSize():
	visualizer.scale=Vector3(cfg.SizeX*0.38,cfg.Height,cfg.SizeY*0.38)
	visualizer.position=Vector3(0,cfg.Height/2,0)

func updateInfos(val,section,full):
	val = float(val)
	
	var value = (val/full)+section
	
	$Section/Config.self_modulate = Color.from_string("89ff81" if value >= starts.Config else "303030", "303030")
	$Section/Layering.self_modulate = Color.from_string("89ff81" if value >= starts.Layering else "303030", "303030")
	$Section/Rendering.self_modulate = Color.from_string("89ff81" if value >= starts.Rendering else "303030", "303030")
	$Section/Finalizing.self_modulate = Color.from_string("89ff81" if value >= starts.Finalizing else "303030", "303030")
	$Section/Finish.self_modulate = Color.from_string("89ff81" if value >= starts.Finish else "303030", "303030")
	
	$Section.value=value
	$Bar.value=val/full
	
	match section:
		1:
			$Bar/Info.text="Generating layers..."
			$Bar/Stats.text=str(val) + " / " + str(full)
		2:
			$Bar/Info.text="Creating images..."
			$Bar/Stats.text=str(val) + " / " + str(full)
		3:
			$Bar/Info.text="Finalizing"
			$Bar/Stats.text="Please wait..."
		4:
			$Bar/Info.text="Finished!"
			$Bar/Stats.text="All images are inside " + cfg.Directory + ". (Took "+str(floor(Time.get_unix_time_from_system()-starttime))+"s)"

func RevertCfg():
	cfg=default.duplicate()
	$Settings/Directory/Value.placeholder_text=str(cfg.Directory)
	$Settings/Height/Value.placeholder_text=str(cfg.Height)
	$Settings/Layers/Value.placeholder_text=str(cfg.Layers)
	$Settings/SizeX/Value.placeholder_text=str(cfg.SizeX)
	$Settings/SizeY/Value.placeholder_text=str(cfg.SizeY)
	UpdateCfg()
	
func UpdateCfg():
	$Settings/Directory/Value.text=str(cfg.Directory)
	$Settings/Height/Value.text=str(int(cfg.Height))
	$Settings/Layers/Value.text=str(int(cfg.Layers))
	$Settings/SizeX/Value.text=str(int(cfg.SizeX))
	$Settings/SizeY/Value.text=str(int(cfg.SizeY))
	
	$Settings/Offset/Value.text="%.1f" % (cfg.Height/cfg.Layers)
	$Settings/Size/Value.text=str(roundi(cfg.SizeX*cfg.SizeY))
	
func Close():
	match state:
		0:
			visible=false
		_:
			state = 0
			stop=true
### Render functions
var slices = {}

func Cleanup():
	$Bar/Info.text="Stopping export..."
	for slicei in slices:
		var slice = slices[slicei]
		for obj in slice:
			obj.queue_free()
			await get_tree().process_frame
	slices.clear()
	for o in Objects.objects:
		var obj : MeshInstance3D = Objects.objects[o].model
		if !obj: continue
		obj.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	visible=false
	$Settings.visible=true
	$Bar.visible=false
	$Close.visible=false

func Layering():
	var offset = cfg.Height/cfg.Layers
	var slicer = MeshSlicer.new()
	
	visualizer.visible=false
	
	state = 1
	
	print(offset)
	
	#cam.set_meta("inputEnabled",false)
	
	cam.add_child(slicer)
	
	for idx in range(0,cfg.Layers+1):
		var i = float(idx) * offset
		
		slices[idx]=[]
		updateInfos(idx,state,float(cfg.Layers))
		
		for o in Objects.objects:
			var obj : MeshInstance3D = Objects.objects[o].model
			if !obj: continue
			obj.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
			var result = slicer.slice_layer(obj.mesh, obj.global_transform, i, i+offset)
			
			var sliced = MeshInstance3D.new()
			sliced.mesh = result
			sliced.material_override = obj.material_override
			
			get_tree().get_root().add_child(sliced)
			slices[idx].append(sliced)
			
			await get_tree().create_timer(0.05).timeout
		if stop:
			await Cleanup()
			break
			
func CreateImages():
	if stop:
		return
	state = 2
	updateInfos(0,state,float(cfg.Layers))
	for idx in range(0,cfg.Layers+1):
		var slice = slices[idx]
		for obj in slice:
			obj.visible=false
			
	for idx in range(0,cfg.Layers+1):
		var slice = slices[idx]
		updateInfos(idx,state,float(cfg.Layers))
		
		for obj in slice:
			obj.visible=true
			
		await get_tree().create_timer(0.05).timeout
		
		for obj in slice:
			obj.visible=false
			
		if stop:
			await Cleanup()
			break

##############################
func _ready() -> void:
	RevertCfg()
	VisualizeSize()
	
	$Settings/Controls/Revert.button_down.connect(func():
		RevertCfg()
	)
	
	$Settings/Controls/Render.button_down.connect(func():
		$Settings.visible=false
		$Bar.visible=true
		$Close.visible=true
		
		stop = false
		
		if stop: return
		await Layering()
		
		if stop: return
		await CreateImages()
	)
	
	$Settings/Controls/Close.button_down.connect(Close)
	$Close.button_down.connect(Close)
	
	visibility_changed.connect(func():
		visualizer.visible=visible
		updateInfos(0,0,1)
	)
	
	
	### Config handling
	
	# Directory
	$Settings/Directory/Directory.button_down.connect(func():
		$Folder.popup_centered()
	)
	$Folder.dir_selected.connect(func(path):
		print(path)
		cfg.Directory = path
		UpdateCfg()
	)
	
	# Layers
	$Settings/Layers/Value.text_submitted.connect(func(text):
		if text.is_valid_float():
			cfg.Layers = clampf(int(text),3,60)
		UpdateCfg()
	)
	$Settings/Height/Value.text_submitted.connect(func(text):
		if text.is_valid_float():
			cfg.Height = clampf(int(text),1,400)
		UpdateCfg()
		VisualizeSize()
	)
	
	# Image size
	$Settings/SizeX/Value.text_submitted.connect(func(text):
		if text.is_valid_float():
			cfg.SizeX = clampi(int(text),270,1048)
		UpdateCfg()
		VisualizeSize()
	)
	$Settings/SizeY/Value.text_submitted.connect(func(text):
		if text.is_valid_float():
			cfg.SizeY = clampi(int(text),270,1048)
		UpdateCfg()
		VisualizeSize()
	)
