class_name editor_Main

var props = {
		"name" = {
			"locked"=false,
			"value"="Object",
		},
		"classname" = {
			"locked"=true,
			"value"="main",
		},
		"parent" = {
			"locked"=false,
			"value"=null,
		},
	}
var model = null
var description = "Root object that's used by every other object"
var children = []
var deletable = false
var id = 0
var modelasset = null

func clone():
	var c = editor_Main.new()
	c.props = props.duplicate(true)
	c.deletable = deletable
	c.description = description
	c.modelasset = modelasset
	return c
