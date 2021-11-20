/// @desc Freeze a collision mesh, which will make it read-only. A frozen collision mesh is faster than an unfrozen one since it is grid-based. Return a boolean telling whether or not it succeeded.
function pnc_mesh_freeze(mesh) {
	var mesh_triangles = mesh[PNCMeshData.TRIANGLES]
	var triangles = array_length(mesh_triangles)
	
	if mesh[PNCMeshData.GRID] != undefined or not triangles {
		// The mesh is already frozen or it doesn't have any triangles.
		return false
	}
	
	var x1 = undefined
	var y1
	var x2
	var y2
	
	var i = 0
	
	// Calculate grid boundaries
	repeat triangles {
		var triangle = mesh_triangles[i++]
		
		var tx1 = triangle[0]
		var ty1 = triangle[1]
		var tx2 = triangle[3]
		var ty2 = triangle[4]
		var tx3 = triangle[6]
		var ty3 = triangle[7]
		
		if x1 == undefined {
			x1 = min(tx1, tx2, tx3)
			y1 = min(ty1, ty2, ty3)
			x2 = max(tx1, tx2, tx3)
			y2 = max(ty1, ty2, ty3)
		} else {
			x1 = min(x1, tx1, tx2, tx3)
			y1 = min(y1, ty1, ty2, ty3)
			x2 = max(x1, tx1, tx2, tx3)
			y2 = max(x1, ty1, ty2, ty3)
		}
	}
	
	// Create grid and add triangles to it
	var mesh_regions = []
	var mesh_grid = ds_grid_create(ceil((x2 - x1) / PNC_CELL_SIZE), ceil((y2 - y1) / PNC_CELL_SIZE))
	var grid_height = ds_grid_height(mesh_grid)
	var i = 0
	
	repeat ds_grid_width(mesh_grid) {
		var j = 0
		
		repeat grid_height {
			/* Try to create a region for each new grid cell.
			   If there are no triangles in this region, the cell will redirect to -1,
			   meaning it's empty and can be skipped to save performance. */
			var region = []
			var rx1 = x1 + i * PNC_CELL_SIZE
			var ry1 = y1 + j * PNC_CELL_SIZE
			var rx2 = rx1 + PNC_CELL_SIZE
			var ry2 = ry1 + PNC_CELL_SIZE
			var k = 0
			
			repeat triangles {
				var triangle = mesh_triangles[k]
				
				var tx1 = triangle[0]
				var ty1 = triangle[1]
				var tx2 = triangle[3]
				var ty2 = triangle[4]
				var tx3 = triangle[6]
				var ty3 = triangle[7]

				/* Check if this triangle is within the region.
				   (Please don't use rectangle_in_triangle for 3d triangles!) */
				if point_in_rectangle(tx1, ty1, rx1, ry1, rx2, ry2)
				   or point_in_rectangle(tx2, ty2, rx1, ry1, rx2, ry2)
				   or point_in_rectangle(tx3, ty3, rx1, ry1, rx2, ry2)
				   or __pnc_lines_intersect(tx1, ty1, tx2, ty2, rx1, ry1, rx2, ry1)
				   or __pnc_lines_intersect(tx1, ty1, tx2, ty2, rx2, ry1, rx2, ry2)
				   or __pnc_lines_intersect(tx1, ty1, tx2, ty2, rx2, ry2, rx1, ry2)
				   or __pnc_lines_intersect(tx1, ty1, tx2, ty2, rx1, ry2, rx1, ry1)
				   or __pnc_lines_intersect(tx2, ty2, tx3, ty3, rx1, ry1, rx2, ry1)
				   or __pnc_lines_intersect(tx2, ty2, tx3, ty3, rx2, ry1, rx2, ry2)
				   or __pnc_lines_intersect(tx2, ty2, tx3, ty3, rx2, ry2, rx1, ry2)
				   or __pnc_lines_intersect(tx2, ty2, tx3, ty3, rx1, ry2, rx1, ry1)
				   or __pnc_lines_intersect(tx3, ty3, tx1, ty1, rx1, ry1, rx2, ry1)
				   or __pnc_lines_intersect(tx3, ty3, tx1, ty1, rx2, ry1, rx2, ry2)
				   or __pnc_lines_intersect(tx3, ty3, tx1, ty1, rx2, ry2, rx1, ry2)
				   or __pnc_lines_intersect(tx3, ty3, tx1, ty1, rx1, ry2, rx1, ry1)
				{
					array_push(region, k)
				}
				
				k++
			}
			
			if array_length(region) {
				mesh_grid[# i, j] = array_length(mesh_regions)
				array_push(mesh_regions, region)
			} else {
				mesh_grid[# i, j] = -1
			}
			
			j++
		}
		
		i++
	}
	
	mesh[@ PNCMeshData.REGIONS] = mesh_regions
	mesh[@ PNCMeshData.GRID] = mesh_grid
	mesh[@ PNCMeshData.X_OFFSET] = x1
	mesh[@ PNCMeshData.Y_OFFSET] = y1
	mesh[@ PNCMeshData.STACK] = ds_stack_create()
	
	return true
}