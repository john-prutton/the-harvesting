@tool
class_name CustomEnvironment
extends Node3D

@onready var map = $".."
var map_size: int

const prefabs: Array = [
	[
		preload("res://scenes/world/assets/map/assets/environment/assets/tree/prefab.blend"), 
		0.01, 
		5
	],
	[
		preload("res://scenes/world/assets/map/assets/environment/assets/grass/prefab.blend"), 
		0.8,
		0.5
	],
]

func spawn_environment(_map_size: int):
	map_size = _map_size
	var map_area = pow(map_size, 2)
	var positions: Array[Vector3] = []

	for prefab in prefabs:
		var model = prefab[0]
		var density = prefab[1]
		var gap = prefab[2]
		var n = density * map_area
		
		var spawned = 0
		var failed = 0
		while spawned < n and failed < 100:
			var pos = _generate_random_position()
			if not _is_valid_position(pos, gap, positions):
				failed += 1
				continue
				
			failed = 0
			spawned += 1
			_spawn_prefab(model, pos)
			
		print("spawned: %d, failed: %d" % [spawned, failed])

func _generate_random_position() -> Vector3:
	var x = randf() * map_size - map_size/2
	var z = randf() * map_size - map_size/2
	var pos = Vector3(x,0,z)
	pos.y = map.calculate_vertex_height(pos)
	
	return pos

func _is_valid_position(pos: Vector3, min_gap: float, positions: Array[Vector3]) -> bool:
	var is_valid := true
	
	for _pos in positions:
		var d = (_pos - pos).length()
		
		if (d < min_gap):
			is_valid = false
			break
	
	return is_valid

func _spawn_prefab(prefab: PackedScene, pos: Vector3):
	var _prefab = prefab.instantiate()
	$Spawnables.add_child(_prefab)
	_prefab.global_position = pos
