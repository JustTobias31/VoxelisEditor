extends Node
class_name MeshSlicer

func slice_layer(mesh: Mesh, mesh_global_transform: Transform3D, y_min: float, y_max: float, cross_section_material: Material = null) -> ArrayMesh:   
	var combiner = CSGCombiner3D.new()
	var obj_csg = CSGMesh3D.new()
	obj_csg.mesh = mesh
	obj_csg.global_transform = mesh_global_transform  # place mesh in world space
	
	var bottom_csg = CSGMesh3D.new()
	bottom_csg.mesh = BoxMesh.new()
	if cross_section_material:
		bottom_csg.mesh.material = cross_section_material
	
	var top_csg = CSGMesh3D.new()
	top_csg.mesh = BoxMesh.new()
	if cross_section_material:
		top_csg.mesh.material = cross_section_material
	
	add_child(combiner)
	combiner.add_child(obj_csg)
	combiner.add_child(bottom_csg)
	combiner.add_child(top_csg)
	
	# Mesh bounds in world space
	var max_at = Vector3(-INF, -INF, -INF)
	var min_at = Vector3(INF, INF, INF)
	for v in mesh.get_faces():
		var world_v = mesh_global_transform * v
		max_at = max_at.max(world_v)
		min_at = min_at.min(world_v)
	
	var mesh_size = max_at - min_at
	var big = max(mesh_size.x, mesh_size.z) * 2.0
	var slab_thickness = 1000.0
	
	# Slicers positioned in world space Y
	bottom_csg.global_position = Vector3(0, y_min - slab_thickness / 2.0, 0)
	bottom_csg.mesh.size = Vector3(big, slab_thickness, big)
	bottom_csg.operation = CSGShape3D.OPERATION_SUBTRACTION
	
	top_csg.global_position = Vector3(0, y_max + slab_thickness / 2.0, 0)
	top_csg.mesh.size = Vector3(big, slab_thickness, big)
	top_csg.operation = CSGShape3D.OPERATION_SUBTRACTION
	
	combiner._update_shape()
	var meshes = combiner.get_meshes()
	var out_mesh = ArrayMesh.new()
	if meshes and meshes.size() > 1:
		out_mesh = meshes[1]
	
	combiner.queue_free()
	return out_mesh
