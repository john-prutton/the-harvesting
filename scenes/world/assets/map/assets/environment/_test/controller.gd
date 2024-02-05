@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	($Environment as CustomEnvironment).spawn_trees(80, Vector3.ZERO, 60, 5)
	($Environment as CustomEnvironment).spawn_grass(2000, Vector3.ZERO, 60, 0.1)
	pass
