@tool
extends Node3D

@onready var children: Array[Chunk] = [$Chunk]

const VERTEX_GAP: float = 1.0
const VERTEX_COUNT: int = 50

const CHUNK_SIZE: int = VERTEX_COUNT * VERTEX_GAP
const CHUNK_RADIUS: int = CHUNK_SIZE / 2

const NOISE_SCALE: float = 0.5
const NOISE_AMPLITUDE: float = 100

var noise := FastNoiseLite.new()
var surface_tool := SurfaceTool.new()


func _ready():
	children.all(_generate_chunk)

func _generate_chunk(chunk: Chunk):
	print("Generating mesh at: " + str(chunk.position))
	var offset_noise := 10000 * Vector3.ONE
	var array_mesh := _generate_mesh(chunk.global_position)
	
	chunk.set_mesh(array_mesh)
	
func _generate_mesh(center: Vector3) -> ArrayMesh:
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for z in VERTEX_COUNT:
		for x in VERTEX_COUNT:
			# set uv
			var vertex_uv := Vector2(
				float(x)/VERTEX_COUNT, 
				float(z)/VERTEX_COUNT
			)
			surface_tool.set_uv(vertex_uv)

			# set vertex point
			var offset := center - CHUNK_RADIUS * Vector3(1, 0, 1) 
			var vertex_position := VERTEX_GAP * Vector3(x, 0, z) + offset
			
			vertex_position.y = _calculate_noise_height(vertex_position)
			surface_tool.add_vertex(vertex_position)
			
			# if on the top or left edge, exit early
			if x == VERTEX_COUNT-1 or z == VERTEX_COUNT-1: continue

			# A----B
			# | // |
			# C----D
			#
			# mark triangles
			
			var z_offset := z * VERTEX_COUNT
			
			var a := x + z_offset
			var b := a + 1
			var c := a + VERTEX_COUNT
			var d := c + 1
			
			surface_tool.add_index(a)
			surface_tool.add_index(b)
			surface_tool.add_index(c)
			
			surface_tool.add_index(c)
			surface_tool.add_index(b)	
			surface_tool.add_index(d)
	
	# process surface
	surface_tool.generate_tangents()
	surface_tool.generate_normals()
	
	# generate array mesh
	var array_mesh: ArrayMesh = surface_tool.commit()
	
	# clear surface tool
	surface_tool.clear()
	
	return array_mesh

func _calculate_noise_height(point: Vector3) -> float:
	var sample_point = NOISE_SCALE * point
	var noise_value = noise.get_noise_2d(sample_point.x, sample_point.z)
	var height_point = NOISE_AMPLITUDE * noise_value
	
	return height_point
