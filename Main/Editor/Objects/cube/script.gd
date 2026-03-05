extends editor_3D
class_name editor_Cube

func _init():
	super()
	description = "Cube"
	color = Color.ORANGE_RED
	model=load("res://Main/Editor/Objects/cube/model.tscn").instantiate()
