/// @desc Destroy a collision mesh. Return true.
/// @param {array} mesh The collision mesh to destroy.
function pnc_mesh_destroy(mesh) {
	var mesh_grid = mesh[PNCMeshData.GRID]
	
	if mesh_grid != undefined {
		ds_grid_destroy(mesh_grid)
	}
	
	var mesh_stack = mesh[PNCMeshData.STACK]
	
	if mesh_stack != undefined {
		ds_stack_destroy(mesh_stack)
	}
	
	return true
}