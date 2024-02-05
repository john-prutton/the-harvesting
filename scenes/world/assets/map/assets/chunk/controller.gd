@tool
class_name Chunk
extends StaticBody3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_mesh(array_mesh: ArrayMesh):
	mesh_instance.mesh = array_mesh
	collision_shape.shape = array_mesh.create_trimesh_shape()
