@tool
extends Node3D

const VERTEX_GAP: float = 1.0
const VERTEX_COUNT: int = 50

const CHUNK_SIZE: int = int(VERTEX_COUNT * VERTEX_GAP)
const CHUNK_RADIUS: int = CHUNK_SIZE / 2
const CHUNK_PREFAB := preload("res://scenes/world/assets/map/assets/chunk/chunk.tscn")
var chunks: Array[Chunk] = []
@onready var chunk_parent := $Chunks

const NOISE_SCALE: float = 0.3
const NOISE_AMPLITUDE: float = 100
const NOISE_OFFSET := 100000 * Vector3(1, 0, 1)
var noise := FastNoiseLite.new()
var surface_tool := SurfaceTool.new()

const MAP_SIZE := 250

func _ready():
	var offset = CHUNK_RADIUS * Vector3(1, 0, 1)
	
	for x in range(-MAP_SIZE/2, MAP_SIZE/2, CHUNK_SIZE):
		for z in range(-MAP_SIZE/2, MAP_SIZE/2, CHUNK_SIZE):
			_generate_chunk(Vector3(x, 0, z) + offset)
	
func _generate_chunk(_position: Vector3):
	# spawn chunk & add to scene
	var chunk := CHUNK_PREFAB.instantiate()
	chunks.append(chunk)
	chunk_parent.add_child(chunk)
	
	# move into position
	chunk.position = _position
	
	# generate mesh
	var array_mesh := _generate_mesh(_position)
	chunk.set_mesh(array_mesh)

func _generate_mesh(center: Vector3) -> ArrayMesh:
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(VERTEX_COUNT+1):
		for z in range(VERTEX_COUNT+1):
			# set uv
			var vertex_uv := Vector2(
				float(x)/(VERTEX_COUNT), 
				float(z)/(VERTEX_COUNT)
			)
			surface_tool.set_uv(vertex_uv)

			# set vertex point
			var offset := CHUNK_SIZE * Vector3(0.5, 0, 0.5)
			var vertex_position := VERTEX_GAP * Vector3(x, 0, z) - offset
			
			vertex_position.y = _calculate_noise_height(vertex_position+center)
			surface_tool.add_vertex(vertex_position)
			
			# if on the top or left edge, exit early
			if x == VERTEX_COUNT or z == VERTEX_COUNT: continue

			# A----B
			# | // |
			# C----D
			#
			# mark triangles
			
			var z_offset := z * (VERTEX_COUNT+1)
			
			var a := x + z_offset
			var b := a + 1
			var c := a + (VERTEX_COUNT+1)
			var d := c + 1
			
			surface_tool.add_index(a)
			surface_tool.add_index(c)
			surface_tool.add_index(b)
			
			surface_tool.add_index(c)
			surface_tool.add_index(d)
			surface_tool.add_index(b)	
	
	# process surface
	#surface_tool.generate_tangents()
	surface_tool.generate_normals()
	
	# generate array mesh
	var array_mesh: ArrayMesh = surface_tool.commit()
	
	# clear surface tool
	surface_tool.clear()
	
	return array_mesh

func _calculate_noise_height(point: Vector3) -> float:
	var sample_point = NOISE_SCALE * point + NOISE_OFFSET
	var noise_value = noise.get_noise_2d(sample_point.x, sample_point.z)
	var height = NOISE_AMPLITUDE * noise_value
	
	return height
