extends Spatial


func set_material(mat):
	$MeshInstance.set_surface_material(0, mat)
