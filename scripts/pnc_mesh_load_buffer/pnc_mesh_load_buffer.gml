/// @desc Read the contents of a collison mesh from a buffer. Return a new collision mesh if successful, false otherwise.
/// @param {buffer} buffer The buffer to read from.
function pnc_mesh_load_buffer(buffer) {
	// Read header
	if buffer_read(buffer, buffer_string) != "PNCollisions" {
		// The header is invalid, discard.
		return false
	}

	// Read triangles
	var mesh_triangles = []
	var triangles = buffer_read(buffer, buffer_u32)
	
	repeat triangles {
		var triangle = []
		var i = 0
		
		repeat 12 {
			triangle[@ i++] = buffer_read(buffer, buffer_f32)
		}
		
		array_push(mesh_triangles, triangle)
	}
	
	// Read frozen collision mesh stuff
	var regions = buffer_read(buffer, buffer_u32)
	
	if regions == 0 {
		// The collision mesh isn't frozen, return a regular collision mesh.
		return [
			mesh_triangles, // triangles
			undefined, // regions
			undefined, // grid
			undefined, // x offset
			undefined, // y offset
			undefined, // matrix
			undefined, // inverse matrix
			undefined, // stack
		]
	} else {
		// Read regions
		var mesh_regions = []
		var i = 0
		
		repeat regions {
			var region = []
			var j = 0
			
			repeat buffer_read(buffer, buffer_u32) {
				region[@ j++] = buffer_read(buffer, buffer_u32)
			}
			
			mesh_regions[@ i++] = region
		}
		
		// Read grid
		var width = buffer_read(buffer, buffer_u32)
		var height = buffer_read(buffer, buffer_u32)
		var mesh_grid = ds_grid_create(width, height)
		var i = 0
		
		repeat width {
			var j = 0
			
			repeat height {
				mesh_grid[# i, j++] = buffer_read(buffer, buffer_s32)
			}
			
			i++
		}
		
		// Read offset
		var mesh_x_offset = buffer_read(buffer, buffer_f32)
		var mesh_y_offset = buffer_read(buffer, buffer_f32)
		
		return [
			mesh_triangles, // triangles
			mesh_regions, // regions
			mesh_grid, // grid
			mesh_x_offset, // x offset
			mesh_y_offset, // y offset
			undefined, // matrix
			undefined, // inverse matrix
			ds_stack_create(), // stack
		]
	}
}