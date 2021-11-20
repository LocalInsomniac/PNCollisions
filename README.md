# PNCollisions
PNCollisions is a compact 3D raycasting library for GameMaker Studio 2.3.

3D collision in PNCollisions consists of two types of collision meshes; regular and frozen.

Regular meshes can have matrices applied to them, but are unoptimized since every triangle is checked during collisions. They should generally be used for things like moving objects (lifts, elevators, platforms, etc.).

Frozen meshes are divided into regions so that collisions use as few triangles as possible, making it faster than regular meshes. Since they are static and unreliable for matrix transformed collisions, you cannot add triangles nor apply matrices to them.

When using a collision checking function, you can specify which mesh should be used for colliding. This means that you can write your own code that masks out unneeded meshes and, if your level consists of multiple meshes, compare each mesh's intersection to get the closest result.

This library is currently barebones and only can be used to cast rays onto collision meshes. A test project is included for quick benchmarking.

# Functions
## Collision meshes
`pnc_mesh_create()` - Creates a new collision mesh, which is basically an array containing mesh data. This returns that array which you can get values from using the `PNCMeshData` enumerator.

`pnc_mesh_destroy(mesh)` - Destroys the specified collision mesh, freeing the data structures it uses in order for it to be safely garbage-collected.

`pnc_mesh_add_triangle(mesh, x1, y1, z1, x2, y2, z2, x3, y3, z3)` - Adds a single triangle to a collision mesh that isn't frozen. Returns `true` if successful, `false` if not.

`pnc_mesh_add_triangles(mesh, triangles)` - Adds multiple triangles to a collision mesh that isn't frozen. The `triangles` array should consist of triangle arrays `[x1, y1, z1, x2, y2, z2, x3, y3, z3]`. Returns `true` if successful, `false` if not.

`pnc_mesh_set_matrix(mesh, matrix)` - Sets the matrix of a collision mesh that isn't frozen. Returns `true` if successful, `false` if the calculated inverse matrix's determinant is zero.

`pnc_mesh_freeze(mesh)` - Freezes a regular collision mesh, which makes it read-only. This means that you can no longer add triangles or apply matrices to it. A frozen collision mesh becomes subdivided into regions, which makes collisions faster. Returns `true` if successful, `false` if the mesh is already frozen or doesn't include any triangles.

`pnc_mesh_save_buffer(mesh, buffer)` - Writes the contents of a collision mesh into a buffer.

`pnc_mesh_save(mesh, filename)` - Writes the contents of a collision mesh into a file.

`pnc_mesh_load_buffer(buffer)` - Reads the contents of a collision mesh from a buffer. Returns a new collision mesh if successful, `false` otherwise.

`pnc_mesh_load(filename)` - Reads the contents of a collision mesh from a file. Returns a new collision mesh if successful, `false` otherwise.

## Collisions
`pnc_raycast(mesh, x1, y1, z1, x2, y2, z2)` - Casts a ray onto the specified collision mesh from `[x1, y1, z1]` to `[x2, y2, z2]`. Returns an array `[x, y, z, nx, ny, nz]` if successful and there was an intersection, `false` otherwise.
