/// @desc Write the contents of a collison mesh to a file.
/// @param {array} mesh The collison mesh to save.
function pnc_mesh_save(mesh, filename) {
	var buffer = buffer_create(1, buffer_grow, 1)

	pnc_mesh_save_buffer(mesh, buffer)
	buffer_save(buffer, filename)
	buffer_delete(buffer)
}