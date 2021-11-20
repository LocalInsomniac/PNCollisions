/// @desc Read the contents of a collison mesh from a file. Return a new collision mesh if successful, false otherwise.
/// @param {string} filename The collison mesh file to load.
function pnc_mesh_load(filename) {
	if not file_exists(filename) {
		return false
	}
	
	var buffer = buffer_load(filename)
	var mesh = pnc_mesh_load_buffer(buffer)

	buffer_delete(buffer)
	
	return mesh
}