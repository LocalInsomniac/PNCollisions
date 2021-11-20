/// @desc Create a collision mesh and return its handle.
function pnc_mesh_create() {
	return [
		[], // triangles
		undefined, // regions
		undefined, // grid
		undefined, // x offset
		undefined, // y offset
		undefined, // matrix
		undefined, // inverse matrix
		undefined, // stack
	]
}