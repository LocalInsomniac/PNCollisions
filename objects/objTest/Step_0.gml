if keyboard_check_pressed(ord("R")) {
	vertex_delete_buffer(vertex_buffer)
	vertex_delete_buffer(raycast_buffer)
	vertex_delete_buffer(vertex_buffer_of_doom)
	vertex_format_delete(vertex_format)
	pnc_mesh_destroy(mesh)
	pnc_mesh_destroy(mesh_of_doom)
	game_restart()
	
	exit
}

// Apply a matrix to the slab of doom
var timer = current_time * 0.05

matrix_of_doom = matrix_build(0, 0, abs(lengthdir_y(64, timer)), 0, 0, timer, 1, 1, 1)
pnc_mesh_set_matrix(mesh_of_doom, matrix_of_doom)

// Mouselook
if window_has_focus() {
	var mx = display_mouse_get_x()
	var my = display_mouse_get_y()
	var gw = window_get_x() + window_get_width() * 0.5
	var gh = window_get_y() + window_get_height() * 0.5

	yaw -= (mx - gw) / 5
	pitch = clamp(pitch - (my - gh) / 5, -89.5, 89.5)
	display_mouse_set(gw, gh)
}

// Movement code by YAL
var key_x = (keyboard_check(ord("W")) - keyboard_check(ord("S")))
var key_y = keyboard_check(ord("D")) - keyboard_check(ord("A"))
var key_z = keyboard_check(ord("X")) - keyboard_check(ord("Z"))
var key_l = point_distance(0, 0, key_x, key_y)

var speed_x = key_x * 6
var speed_y = key_y * 6
var speed_z = key_z * 6

var fast_modifier = 1 + keyboard_check(vk_control) // length of moving vector

// Normalize vector to prevent faster diagonal movement
if key_l > 1 {
	key_x /= key_l
	key_y /= key_l
	key_l = 1
}

x += fast_modifier * (lengthdir_x(lengthdir_x(speed_x, yaw), pitch) + lengthdir_x(speed_y, yaw - 90))
y += fast_modifier * (lengthdir_x(lengthdir_y(speed_x, yaw), pitch) + lengthdir_y(speed_y, yaw - 90))
z -= fast_modifier * (lengthdir_y(speed_x, pitch) + speed_z)

// Raycast
if mouse_check_button(mb_left) {
	var pitch_factor = dcos(pitch)
	var x2 = x + lengthdir_x(65536, yaw) * pitch_factor
	var y2 = y + lengthdir_y(65536, yaw) * pitch_factor
	var z2 = z - lengthdir_y(65536, pitch)
	
	raycast = pnc_raycast(mesh, x, y, z, x2, y2, z2)
	
	var raycast_of_doom = pnc_raycast(mesh_of_doom, x, y, z, x2, y2, z2)
	
	if raycast_of_doom != false and (raycast == false or point_distance_3d(x, y, z, raycast_of_doom[0], raycast_of_doom[1], raycast_of_doom[2]) < point_distance_3d(x, y, z, raycast[0], raycast[1], raycast[2])) {
		/* The slab of doom's intersection is either the only one we have or is
		   closer than the static mesh's, so use it as the result. */
		raycast = raycast_of_doom
	}
}