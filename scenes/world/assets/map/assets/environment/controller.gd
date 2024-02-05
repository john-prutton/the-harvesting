@tool
class_name CustomEnvironment
extends Node3D

const tree_prefab := preload("res://scenes/world/assets/map/assets/environment/assets/tree/prefab.blend")
const grass_prefab := preload("res://scenes/world/assets/map/assets/environment/assets/grass/grass.blend")

func spawn_trees(n: int, point: Vector3, radius: float, min_gap: float):
	var spawned := 0
	var fails := 0
	var max_fails := 1000
	
	while (spawned < n and fails < max_fails):
		var pos := _generate_random_position(point, radius)
		var is_valid := _is_valid_position(pos, min_gap)
		if (not is_valid): 
			fails += 1
			continue
		
		var tree = tree_prefab.instantiate()
		tree.global_position = pos
		$Spawnables.add_child(tree)
		spawned += 1
		
	print("spawned: %d, fails: %d" % [spawned, fails])

func spawn_grass(n: int, point: Vector3, radius: float, min_gap: float):
	var spawned := 0
	var fails := 0
	var max_fails := 1000
	
	while (spawned < n and fails < max_fails):
		var pos := _generate_random_position(point, radius)
		var is_valid := _is_valid_position(pos, min_gap)
		if (not is_valid): 
			fails += 1
			continue
		
		var grass = grass_prefab.instantiate()
		grass.global_position = pos
		grass.rotate_y(randf_range(0, 2*PI))
		$Spawnables.add_child(grass)
		spawned += 1
		
	print("spawned: %d, fails: %d" % [spawned, fails])

func _generate_random_position(point: Vector3, radius: float) -> Vector3:
	var theta = randf() * 2 * PI
	var rad = randf() * radius
	var pos = rad * Vector3(cos(theta), 0, sin(theta))
	return pos

func _is_valid_position(point: Vector3, min_gap: float) -> bool:
	var is_valid := true
	
	for i in $Spawnables.get_children():
		var d = ((i as Node3D).position - point).length()
		
		if (d < min_gap):
			is_valid = false
			break
	
	return is_valid
