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
	var v1 = x2 - x1
	var v2 = y2 - y1
	var v3 = z2 - z1
	var v4 = x3 - x1
	var v5 = y3 - y1
	var v6 = z3 - z1

	var normals = [
		v2 * v6 - v3 * v5,
		v3 * v4 - v1 * v6,
		v1 * v5 - v2 * v4,
	]

	var d = sqrt(sqr(normals[0]) + sqr(normals[1]) + sqr(normals[2]))
	
	normals[0] /= d
	normals[1] /= d
	normals[2] /= d
	
	return normals
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
	return [
		matrix[12] + dot_product_3d(x, y, z, matrix[0], matrix[4], matrix[8]),
		matrix[13] + dot_product_3d(x, y, z, matrix[1], matrix[5], matrix[9]),
		matrix[14] + dot_product_3d(x, y, z, matrix[2], matrix[6], matrix[10]),
	]
}

/// @desc Check for an intersection between a 3D line and triangle. Return an array ([x, y, z, nx, ny, nz]) or false if not intersecting.
function __pnc_line_overlaps_triangle(line, triangle) {
	var x1 = line[0]
	var y1 = line[1]
	var z1 = line[2]
	var x2 = line[3]
	var y2 = line[4]
	var z2 = line[5]
	
	var tnx = triangle[9]
	var tny = triangle[10]
	var tnz = triangle[11]
	
	// Find the intersection between the ray and the triangle's plane.
	var dot = dot_product_3d(tnx, tny, tnz, x2 - x1, y2 - y1, z2 - z1)

	if dot == 0 {
		return false
	}
	
	var tx1 = triangle[0]
	var ty1 = triangle[1]
	var tz1 = triangle[2]

	dot = dot_product_3d(tnx, tny, tnz, tx1 - x1, ty1 - y1, tz1 - z1) / dot

	if dot <= 0 or dot >= 1 {
		return false
	}

	var intersect_x = lerp(x1, x2, dot)
	var intersect_y = lerp(y1, y2, dot)
	var intersect_z = lerp(z1, z2, dot)

	// Check if the intersection is inside the triangle.
	var tx2 = triangle[3]
	var ty2 = triangle[4]
	var tz2 = triangle[5]
	
	var ax = intersect_x - tx1
	var ay = intersect_y - ty1
	var az = intersect_z - tz1
	var bx = tx2 - tx1
	var by = ty2 - ty1
	var bz = tz2 - tz1

	if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) <= 0 {
		return false
	}

	var tx3 = triangle[6]
	var ty3 = triangle[7]
	var tz3 = triangle[8]

	ax = intersect_x - tx2
	ay = intersect_y - ty2
	az = intersect_z - tz2
	bx = tx3 - tx2
	by = ty3 - ty2
	bz = tz3 - tz2

	if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) <= 0 {
		return false
	}

	ax = intersect_x - tx3
	ay = intersect_y - ty3
	az = intersect_z - tz3
	bx = tx1 - tx3
	by = ty1 - ty3
	bz = tz1 - tz3

	if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) <= 0 {
		return false
	}
	
	return [intersect_x, intersect_y, intersect_z, tnx, tny, tnz]
}