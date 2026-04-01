extends Node

var version = 1

var unsaved = false
var loading = false

var history = []
var pointer = 0

func Save(path):
	var cfg = ConfigFile.new()
	for uid in Objects.objects:
		var obj = Objects.objects[uid]
		for prop in obj.props:
			var val = obj.props[prop].value
			
			match typeof(val):
				TYPE_NIL:
					pass
				TYPE_VECTOR3:
					cfg.set_value(str(uid),prop,str(typeof(val))+"/"+str(snapped(val.x,0.01))+"_"+str(snapped(val.y,0.01))+"_"+str(snapped(val.z,0.01)))
				TYPE_BOOL:
					cfg.set_value(str(uid),prop,str(TYPE_BOOL)+"/" + str(1 if val else 0))
				TYPE_COLOR:
					cfg.set_value(str(uid),prop,str(typeof(val))+"/"+str(snapped(val.r,0.01))+"_"+str(snapped(val.g,0.01))+"_"+str(snapped(val.b,0.01)))
				_:
					cfg.set_value(str(uid),prop,str(typeof(val))+"/"+str(val))
		cfg.set_value(str(uid),"classname",obj.props.classname.value)
	
	cfg.set_value("meta","sum",checksum(cfg))
	
	cfg.set_value("meta","ver",version)
	cfg.set_value("meta","created",int(Time.get_unix_time_from_system()))
	
	if OS.has_environment("USERNAME"):
		cfg.set_value("meta","owner",OS.get_environment("USERNAME"))
	else:
		cfg.set_value("meta","owner","Anonymous")
	
	cfg.save(path)
	
	unsaved=false
	return true


func Load(path, dry_run = false):
	var cfg = ConfigFile.new()
	cfg.load(path)
	
	if cfg.get_value("meta","ver") != version:
		return "Version mismatch"
	
	var sum = cfg.get_value("meta","sum")
	cfg.erase_section("meta")
	var newsum = checksum(cfg)
	if sum != newsum:
		OS.alert("yk that this isnt roblox and i can do anything i want with your computer","what ru trying to do?")
		return "dont try it"
	
	if dry_run:
		return true 
	loading = true
	Objects.history.clear_history()
	for uid in cfg.get_sections():
		if uid == "meta":
			continue
		Objects.create(Objects.index[cfg.get_value(uid,"classname")].new(), null, int(uid))
		await get_tree().process_frame
		
	for uid in cfg.get_sections():
		if uid == "meta":
			continue
		var obj = Objects.objects[int(uid)]
		for prop in cfg.get_section_keys(uid):
			await get_tree().process_frame
			if prop != "classname":
				var val:String = cfg.get_value(uid,prop)
				var type = val.split("/",false,1)
				val = type.get(1)
				type = type.get(0)
				if !type.is_valid_int():
					return "Invalid type"
				type = int(type)
				match type:
					TYPE_BOOL:
						Objects.setProperty(obj,prop,int(val) == 1,false)
					TYPE_VECTOR3:
						var v3 = val.split("_")
						v3=Vector3(float(v3[0]),float(v3[1]),float(v3[2]))
						if typeof(v3) != TYPE_VECTOR3:
							return "Set property failed"
						Objects.setProperty(obj,prop,v3,false)
					TYPE_COLOR:
						var v3 = val.split("_")
						v3 = Color(float(v3[0]),float(v3[1]),float(v3[2]))
						if typeof(v3) != TYPE_COLOR:
							return "Set property failed"
						Objects.setProperty(obj,prop,v3,false)
					TYPE_NIL:
						pass
					_:
						Objects.setProperty(obj,prop,type_convert(val,type),false)
	Objects.history.clear_history()
	loading=false
	return true

func checksum(cfg: ConfigFile):
	var s=0;for x in cfg.get_sections():if x!="meta":for k in cfg.get_section_keys(x):var v=str(cfg.get_value(x,k));for i in v.length():s+=v.unicode_at(i)*(i+1)*(x.unicode_at(0)+k.unicode_at(0));return s^0xDEADBEEF

func _ready():
	Objects.propchanged.connect(func(_a,_b,_c):unsaved=true)
	Objects.deleted.connect(func(_a,_b):unsaved=true)
	Objects.created.connect(func(_a,_b):unsaved=true)
	
	while true:
		await get_tree().create_timer(5*60).timeout
		
		var autoout = Save("user://autosave.ves")
		if autoout != true:
			$"../Ui/Main".ShowToast("Autosave failed ("+autoout+").")
		else:
			$"../Ui/Main".ShowToast("Autosave completed!")
		
	
