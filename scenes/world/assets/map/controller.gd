
extends Node3D

const VERTEX_GAP: float = 1
const VERTEX_COUNT: int = 50

const CHUNK_SIZE: int = int(VERTEX_COUNT * VERTEX_GAP)
const CHUNK_RADIUS: int = CHUNK_SIZE / 2
const CHUNK_PREFAB := preload("res://scenes/world/assets/map/assets/chunk/scene.tscn")
var chunks: Array[Chunk] = []
@onready var chunk_parent := $Chunks

const NOISE_SCALE: float = 0.3
const NOISE_AMPLITUDE: float = 100
const NOISE_OFFSET := 100000 * Vector3(1, 0, 1)
const NOISE_LAYERS: int = 4
const NOISE_PERSISTENCE: float = 0.5
const NOISE_LACUNARITY: float = 2.0

var noise := FastNoiseLite.new()
var surface_tool := SurfaceTool.new()

const MAP_SIZE := 250
const PLATEAU_RADIUS := 100

#environment
@onready var environment: CustomEnvironment = $Environment

func _ready():_generate_map()

func _generate_map():
	noise.seed = randi()
	var offset = CHUNK_RADIUS * Vector3(1, 0, 1)
	
	for x in range(-MAP_SIZE/2, MAP_SIZE/2, CHUNK_SIZE):
		for z in range(-MAP_SIZE/2, MAP_SIZE/2, CHUNK_SIZE):
			_generate_chunk(Vector3(x, 0, z) + offset)
	
	environment.spawn_environment(MAP_SIZE)

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
			
			vertex_position.y = calculate_vertex_height(vertex_position+center)
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

func calculate_vertex_height(point: Vector3) -> float:
	var noise_height := _calculate_noise_height(point)
	noise_height = (1 + noise_height) / 2
	var distance := inverse_lerp(0, PLATEAU_RADIUS, point.length())

	if (distance < 1):
		var inverse_sigmoid_value = (1 - (1 / (1 + exp(6 * (2 * distance - 1)))))
		noise_height = noise_height * lerp(0.1, 1.0, inverse_sigmoid_value)

	return NOISE_AMPLITUDE * noise_height

func _calculate_noise_height(point: Vector3) -> float:
	var height = 0.0
	var amplitude = 1.0
	var frequency = 1.0

	for _i in range(NOISE_LAYERS):
		var sample_point = NOISE_SCALE * frequency * point + NOISE_OFFSET
		var noise_value = noise.get_noise_2d(sample_point.x, sample_point.z)
		height += amplitude * noise_value

		amplitude *= NOISE_PERSISTENCE
		frequency *= NOISE_LACUNARITY

	return height
