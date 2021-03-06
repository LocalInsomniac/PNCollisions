/// @desc Cast a ray onto the specified collision mesh, where [x1, y1, z1] is the start and [x2, y2, z2] is the end. Return an array if there is an intersection ([x, y, z, xn, yn, zn]), false if none.
/// @param {array} mesh The collision mesh to raycast in.
function pnc_raycast(mesh, x1, y1, z1, x2, y2, z2) {
	if x1 == x2 and y1 == y2 and z1 == z2 {
		// Point B is the exact same as point A, discard.
		return false
	}
	
	var intersected = false
	var nx
	var ny
	var nz

	var mesh_triangles = mesh[PNCMeshData.TRIANGLES]
	var mesh_grid = mesh[PNCMeshData.GRID]
	var apply_matrix = false
	
	if mesh_grid == undefined { // Unfrozen mesh
		/* Since the mesh is frozen, apply a matrix to it before checking for
		   collisions. (We don't actually do this, just transforming the ray
		   coordinates with an inverse matrix) */
		var mesh_inverse_matrix = mesh[PNCMeshData.INVERSE_MATRIX]
		
		if mesh_inverse_matrix != undefined {
			// Ray start
			var new_point = __pnc_vertex_transform_matrix(x1, y1, z1, mesh_inverse_matrix)
			
			x1 = new_point[0]
			y1 = new_point[1]
			z1 = new_point[2]
			
			// Ray end
			new_point = __pnc_vertex_transform_matrix(x2, y2, z2, mesh_inverse_matrix)
			x2 = new_point[0]
			y2 = new_point[1]
			z2 = new_point[2]
			
			// Also apply the mesh matrix to the final results (if there will be any).
			apply_matrix = true
		}
		
		/* Check for intersections against every single triangle.
		   This can get resource-intensive, and is why pnc_mesh_freeze should be used
		   for static meshes! */
		var i = 0
		
		repeat array_length(mesh_triangles) {
			// Check this triangle for an intersection.
			var triangle = mesh_triangles[i++]

			var tnx = triangle[9]
			var tny = triangle[10]
			var tnz = triangle[11]

			// Find the intersection between the ray and the triangle's plane.
			var dot = dot_product_3d(tnx, tny, tnz, x2 - x1, y2 - y1, z2 - z1)

			if dot == 0 {
				continue
			}

			var tx1 = triangle[0]
			var ty1 = triangle[1]
			var tz1 = triangle[2]

			dot = dot_product_3d(tnx, tny, tnz, tx1 - x1, ty1 - y1, tz1 - z1) / dot

			if dot < 0 or dot > 1 {
				continue
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

			if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
				continue
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

			if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
				continue
			}

			ax = intersect_x - tx3
			ay = intersect_y - ty3
			az = intersect_z - tz3
			bx = tx1 - tx3
			by = ty1 - ty3
			bz = tz1 - tz3

			if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
				continue
			}

			// There is an intersection, apply it for further iterations.
			intersected = true
			x2 = intersect_x
			y2 = intersect_y
			z2 = intersect_z
			nx = tnx
			ny = tny
			nz = tnz
		}
	} else { // Frozen mesh
		// Add every region the line overlaps to the stack.
		var mesh_stack = mesh[PNCMeshData.STACK]
		var width = ds_grid_width(mesh_grid)
		var height = ds_grid_height(mesh_grid)
		var x_offset = mesh[PNCMeshData.X_OFFSET]
		var y_offset = mesh[PNCMeshData.Y_OFFSET]

		// Line coordinates in grid
		var lx1 = floor((x1 - x_offset) / PNC_CELL_SIZE)
		var ly1 = floor((y1 - y_offset) / PNC_CELL_SIZE)
		var lx2 = floor((x2 - x_offset) / PNC_CELL_SIZE)
		var ly2 = floor((y2 - y_offset) / PNC_CELL_SIZE)
		
		// Distance between (lx1, ly1) and (lx2, ly2)
		var dx = abs(lx2 - lx1)
		var dy = abs(ly2 - ly1)
		// Current position
		var xx = lx1
		var yy = ly1
		// Iteration
		var x_step = lx2 > lx1 ? 1 : -1
		var y_step = ly2 > ly1 ? 1 : -1
		var error = dx - dy
		
		dx *= 2
		dy *= 2
		
		repeat 1 + dx + dy {
			if xx >= 0 and xx < width and yy >= 0 and yy < height {
				var cell = mesh_grid[# xx, yy]

				if cell != -1 {
					ds_stack_push(mesh_stack, cell)
				}
			}
			
			if error > 0 {
				xx += x_step
				error -= dy
			} else {
				yy += y_step
				error += dx
			}
		}

		// Check for intersections in every region the ray overlaps.
		var mesh_regions = mesh[PNCMeshData.REGIONS]

		repeat ds_stack_size(mesh_stack) {
			var region = mesh_regions[ds_stack_pop(mesh_stack)]
			var i = 0
			
			repeat array_length(region) {
				// Check this triangle for an intersection.
				var triangle = mesh_triangles[region[i++]]
	
				var tnx = triangle[9]
				var tny = triangle[10]
				var tnz = triangle[11]
	
				// Find the intersection between the ray and the triangle's plane.
				var dot = dot_product_3d(tnx, tny, tnz, x2 - x1, y2 - y1, z2 - z1)

				if dot == 0 {
					continue
				}
	
				var tx1 = triangle[0]
				var ty1 = triangle[1]
				var tz1 = triangle[2]

				dot = dot_product_3d(tnx, tny, tnz, tx1 - x1, ty1 - y1, tz1 - z1) / dot

				if dot < 0 or dot > 1 {
					continue
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

				if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
					continue
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

				if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
					continue
				}

				ax = intersect_x - tx3
				ay = intersect_y - ty3
				az = intersect_z - tz3
				bx = tx1 - tx3
				by = ty1 - ty3
				bz = tz1 - tz3

				if dot_product_3d(tnx, tny, tnz, az * by - ay * bz, ax * bz - az * bx, ay * bx - ax * by) < 0 {
					continue
				}
	
				// There is an intersection, apply it for further iterations.
				intersected = true
				x2 = intersect_x
				y2 = intersect_y
				z2 = intersect_z
				nx = tnx
				ny = tny
				nz = tnz
			}
		}
	}

	if intersected {
		if apply_matrix {
			// The mesh has a matrix transformation, so correct the raycast information.
			var mesh_matrix = mesh[PNCMeshData.MATRIX]
			var real_point = __pnc_vertex_transform_matrix(x2, y2, z2, mesh_matrix)
			
			return [
				real_point[0],
				real_point[1],
				real_point[2],
				dot_product_3d(nx, ny, nz, mesh_matrix[0], mesh_matrix[4], mesh_matrix[8]),
				dot_product_3d(nx, ny, nz, mesh_matrix[1], mesh_matrix[5], mesh_matrix[9]),
				dot_product_3d(nx, ny, nz, mesh_matrix[2], mesh_matrix[6], mesh_matrix[10]),
			]
		}
		
		return [x2, y2, z2, nx, ny, nz]
	}

	return false
}