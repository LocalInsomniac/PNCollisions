/// @desc Create a collision mesh and return its handle.
function pnc_mesh_create() {
	return [
		[], // triangles
		undefined, // regions
		undefined, // grid
		0, // x offset
		0, // y offset
		undefined, // matrix
		undefined, // inverse matrix
	]
}