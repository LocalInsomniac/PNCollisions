/// @desc Write the contents of a collison mesh to a buffer.
/// @param {array} mesh The collison mesh to save.
/// @param {buffer} buffer The buffer to write in.
function pnc_mesh_save_buffer(mesh, buffer) {
	// Write header
	buffer_write(buffer, buffer_string, "PNCollisions")
	
	// Write triangles
	var mesh_triangles = mesh[PNCMeshData.TRIANGLES]
	var triangles = array_length(mesh_triangles)
	
	buffer_write(buffer, buffer_u32, triangles)
	
	var i = 0
	
	repeat triangles {
		var triangle = mesh_triangles[i++]
		var j = 0
		
		repeat 12 {
			buffer_write(buffer, buffer_f32, triangle[j++])
		}
	}
	
	// Write frozen collision mesh stuff
	var mesh_grid = mesh[PNCMeshData.GRID]
	
	if mesh_grid == undefined {
		// The collision mesh isn't frozen, just add a zero at the end of the buffer.
		buffer_write(buffer, buffer_u32, 0)
	} else {
		// Write regions
		var mesh_regions = mesh[PNCMeshData.REGIONS]
		var regions = array_length(mesh_regions)
	
		buffer_write(buffer, buffer_u32, regions)
		i = 0
	
		repeat regions {
			var region = mesh_regions[i++]
			var triangles = array_length(region)
			var j = 0
		
			buffer_write(buffer, buffer_u32, triangles)
		
			repeat triangles {
				buffer_write(buffer, buffer_u32, region[i++])
			}
		}
	
		// Write grid
		var width = ds_grid_width(mesh_grid)
		var height = ds_grid_height(mesh_grid)

		buffer_write(buffer, buffer_u32, width)
		buffer_write(buffer, buffer_u32, height)
		i = 0

		repeat width {
			var j = 0

			repeat height {
				buffer_write(buffer, buffer_s32, mesh_grid[# i, j++])
			}

			i++
		}
	
		// Write offset
		buffer_write(buffer, buffer_f32, mesh[PNCMeshData.X_OFFSET])
		buffer_write(buffer, buffer_f32, mesh[PNCMeshData.Y_OFFSET])
	}
}