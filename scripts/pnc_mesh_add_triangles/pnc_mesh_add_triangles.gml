/// @desc Add an array of triangles to the specified collision mesh. Return a boolean telling whether or not it succeeded.
/// @param {array} mesh The collision mesh to modify.
/// @param {array} triangles An array of triangles, where each triangle is [x1, y1, z1, x2, y2, z2, x3, y3, z3].
function pnc_mesh_add_triangles(mesh, triangles) {
	if mesh[PNCMeshData.GRID] != undefined {
		// The mesh is frozen, so we can't add triangles to it.
		return false
	}
	
	var mesh_triangles = mesh[PNCMeshData.TRIANGLES]
	var i = 0
	
	// Push each triangle into the triangles array.
	repeat array_length(triangles) {
		var triangle = triangles[i++]
		
		var x1 = triangle[0]
		var y1 = triangle[1]
		var z1 = triangle[2]
		var x2 = triangle[3]
		var y2 = triangle[4]
		var z2 = triangle[5]
		var x3 = triangle[6]
		var y3 = triangle[7]
		var z3 = triangle[8]
		
		var normals = __pnc_triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3)
		
		array_push(mesh_triangles, [x1, y1, z1, x2, y2, z2, x3, y3, z3, normals[0], normals[1], normals[2]])
	}
	
	return true
}