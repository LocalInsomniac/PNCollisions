#macro __PNC_VERSION "1.1.2"
#macro __PNC_DATE "2021-11-20"

enum PNCMeshData {
	TRIANGLES,
	REGIONS,
	GRID,
	X_OFFSET,
	Y_OFFSET,
	MATRIX,
	INVERSE_MATRIX,
	STACK,
}

/// @desc Generate normals from a 3D triangle. Return an array ([nx, ny, nz]).
function __pnc_triangle_normal(x1, y1, z1, x2, y2, z2, x3, y3, z3) {
	// Get the position of B and C relative to A.
	var bx = x2 - x1
	var by = y2 - y1
	var bz = z2 - z1
	var cx = x3 - x1
	var cy = y3 - y1
	var cz = z3 - z1

    // Get the normal of the triangle by using the normalized cross product.
	var cpx = by * cz - cy * bz
	var cpy = bz * cx - cz * bx
	var cpz = bx * cy - cx * by
	var d = sqrt(sqr(cpx) + sqr(cpy) + sqr(cpz))
	
	cpx /= d
	cpy /= d
	cpz /= d
	
	return [cpx, cpy, cpz]
}

/// @desc Check for an intersection between two 2D lines. Return a boolean.
function __pnc_lines_intersect(x1, y1, x2, y2, x3, y3, x4, y4) {
	// https://www.gmlscripts.com/script/lines_intersect
    var ux = x2 - x1
    var uy = y2 - y1
    var vx = x4 - x3
    var vy = y4 - y3
    var wx = x1 - x3
    var wy = y1 - y3
    var ud = vy * ux - vx * uy

    if ud != 0 {
        var ua = (vx * wy - vy * wx) / ud
        var ub = (ux * wy - uy * wx) / ud

        if ua < 0 or ua > 1 or ub < 0 or ub > 1 {
			return false
		}
    }

	return true
}

/// @desc Transform a 3D vertex using a matrix. Return an array ([x, y, z]).
function __pnc_vertex_transform_matrix(x, y, z, matrix) {
	gml_pragma("forceinline")

	return [
		matrix[12] + dot_product_3d(x, y, z, matrix[0], matrix[4], matrix[8]),
		matrix[13] + dot_product_3d(x, y, z, matrix[1], matrix[5], matrix[9]),
		matrix[14] + dot_product_3d(x, y, z, matrix[2], matrix[6], matrix[10]),
	]
}

// Startup
show_debug_message("PNCollisions " + __PNC_VERSION + " by Can't Sleep (" + __PNC_DATE + ")")