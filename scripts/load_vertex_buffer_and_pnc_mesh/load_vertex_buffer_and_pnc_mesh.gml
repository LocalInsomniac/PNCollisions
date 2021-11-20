function load_vertex_buffer_and_pnc_mesh(file, vertex_format, freeze_mesh) {
	var model = buffer_load(file)
	var tricount = (buffer_get_size(model) / 40) / 3
	var triangles = []

	var vertex_buffer = vertex_create_buffer()
	vertex_begin(vertex_buffer, vertex_format)

	repeat tricount {
		var triangle = []
	
		repeat 3 {
			var tx = buffer_read(model, buffer_f32)
			var ty = buffer_read(model, buffer_f32)
			var tz = buffer_read(model, buffer_f32)
		
			vertex_position_3d(vertex_buffer, tx, ty, tz)
			array_push(triangle, tx, ty, tz)
		
			repeat 3 {
				buffer_read(model, buffer_f32)
			}
		
			var u = buffer_read(model, buffer_f32)
			var v = buffer_read(model, buffer_f32)
		
			vertex_texcoord(vertex_buffer, u, v)
		
			repeat 8 {
				buffer_read(model, buffer_u8)
			}
		}
	
		array_push(triangles, triangle)
	}

	vertex_end(vertex_buffer)
	vertex_freeze(vertex_buffer)
	buffer_delete(model)
	
	var mesh = pnc_mesh_create()
	pnc_mesh_add_triangles(mesh, triangles)
	
	if freeze_mesh {
		pnc_mesh_freeze(mesh)
	}
	
	return [vertex_buffer, mesh]
}