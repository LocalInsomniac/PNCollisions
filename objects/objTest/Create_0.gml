show_debug_overlay(true)
gpu_set_ztestenable(true)
gpu_set_zwriteenable(true)
gpu_set_cullmode(cull_counterclockwise)
randomize()

// Create a vertex format to use for our models
vertex_format_begin()
vertex_format_add_position_3d()
vertex_format_add_texcoord()
vertex_format = vertex_format_end()

// Load frozen mesh
var load = load_vertex_buffer_and_pnc_mesh(choose("mesh.smf", "mesh2.smf"), vertex_format, true)

vertex_buffer = load[0]
mesh = load[1]

// Load unfrozen mesh that we'll use for the slab of doom
load = load_vertex_buffer_and_pnc_mesh("slab_of_doom.smf", vertex_format, false)

vertex_buffer_of_doom = load[0]
mesh_of_doom = load[1]
matrix_of_doom = matrix_build_identity()

// Make a vertex buffer that we'll use for showing where the raycast hits
raycast_buffer = vertex_create_buffer()
vertex_begin(raycast_buffer, vertex_format)
vertex_position_3d(raycast_buffer, -16, 0, 0)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_position_3d(raycast_buffer, 16, 0, 0)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_position_3d(raycast_buffer, 0, -16, 0)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_position_3d(raycast_buffer, 0, 16, 0)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_position_3d(raycast_buffer, 0, 0, -16)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_position_3d(raycast_buffer, 0, 0, 16)
vertex_texcoord(raycast_buffer, 0, 0)
vertex_end(raycast_buffer)
vertex_freeze(raycast_buffer)

// Camera
z = 0
yaw = 0
pitch = 0
raycast = false

var mat = matrix_build_projection_perspective_fov(-45, -16 / 9, 1, 65536)

matrix_set(matrix_projection, mat)
camera_set_proj_mat(view_camera[0], mat)