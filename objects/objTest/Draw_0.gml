var mat = matrix_build_lookat(x, y, z, x + dcos(yaw), y - dsin(yaw), z + dtan(pitch), 0, 0, 1)

matrix_set(matrix_view, mat)
camera_set_view_mat(view_camera[0], mat)

// Draw static mesh
draw_set_color(c_white)
vertex_submit(vertex_buffer, pr_trianglelist, -1)

// Draw slab of doom
matrix_set(matrix_world, matrix_of_doom)
vertex_submit(vertex_buffer_of_doom, pr_trianglelist, -1)

// Draw raycast, if successful
draw_set_color(c_red)

if raycast != false {
	matrix_set(matrix_world, matrix_build(raycast[0], raycast[1], raycast[2], 0, 0, 0, 1, 1, 1))
	vertex_submit(raycast_buffer, pr_linelist, -1)
}

matrix_set(matrix_world, matrix_build_identity())