/// @desc Apply a matrix to the specified mesh. Return a boolean telling whether or not it succeeded.
function pnc_mesh_set_matrix(mesh, matrix) {
	/* There should be a failsafe for frozen meshes, but since people are only
	   going to be using matrices for moving meshes (which are unfrozen meshes in
	   PNC), I don't think it will be needed. Besides, that extra check will
	   marginally shave off performance, which is never good for 3D collisions. */

	// Create the inverse matrix for use with collisions.
	var m0 = matrix[0]
	var m1 = matrix[1]
	var m2 = matrix[2]
	var m4 = matrix[4]
	var m5 = matrix[5]
	var m6 = matrix[6]
	var m8 = matrix[8]
	var m9 = matrix[9]
	var m10 = matrix[10]
	var m12 = matrix[12]
	var m13 = matrix[13]
	var m14 = matrix[14]

	var inverse_matrix = [
		m5 * m10 - m9 * m6,
		m9 * m2  - m1 * m10,
		m1 * m6  - m5 * m2,
		0,
		m8 * m6  - m4 * m10,
		m0 * m10 - m8 * m2,
		m4 * m2  - m0 * m6,
		0,
		m4 * m9  - m8 * m5,
		m8 * m1  - m0 * m9,
		m0 * m5  - m4 * m1,
		0,
	]
	
	var i0 = inverse_matrix[0]
	var i1 = inverse_matrix[1]
	var i2 = inverse_matrix[2]
	var i4 = inverse_matrix[4]
	var i5 = inverse_matrix[5]
	var i6 = inverse_matrix[6]
	var i8 = inverse_matrix[8]
	var i9 = inverse_matrix[9]
	var i10 = inverse_matrix[10]

	inverse_matrix[@ 12] = -dot_product_3d(m12, m13, m14, i0, i4, i8)
	inverse_matrix[@ 13] = -dot_product_3d(m12, m13, m14, i1, i5, i9)
	inverse_matrix[@ 14] = -dot_product_3d(m12, m13, m14, i2, i6, i10)
	inverse_matrix[@ 15] = m0 * m5 * m10 - m0 * m6 * m9 - m4 * m1 * m10 + m4 * m2 * m9 + m8 * m1 * m6 - m8 * m2 * m5

	var determinant = dot_product_3d(m0, m1, m2, i0, i4, i8)

	if determinant == 0 {
		// The determinant is zero, so we can't use this matrix.
		return false
	}

	determinant = 1 / determinant

	var i = 0

	repeat 16 {
		inverse_matrix[@ i++] *= determinant
	}

	// Apply the matrices to the mesh.
	mesh[@ PNCMeshData.MATRIX] = matrix
	mesh[@ PNCMeshData.INVERSE_MATRIX] = inverse_matrix

	return true
}