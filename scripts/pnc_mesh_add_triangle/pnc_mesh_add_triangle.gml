/// @desc Add a single triangle to the specified collision mesh. Return a boolean telling whether or not it succeeded.
/// @param {array} mesh The collision mesh to modify.
function pnc_mesh_add_triangle(mesh, x1, y1, z1, x2, y2, z2, x3, y3, z3) {
	if mesh[PNCMeshData.GRID] != undefined {
		// The mesh is frozen, so we can't add triangles to it.
		return false
	}

	var normals = __pnc_triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3)

	array_push(mesh[PNCMeshData.TRIANGLES], [x1, y1, z1, x2, y2, z2, x3, y3, z3, normals[0], normals[1], normals[2]])

	return true
}