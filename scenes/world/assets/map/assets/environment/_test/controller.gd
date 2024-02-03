@tool
extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	($Environment as CustomEnvironment).spawn_trees(1000, Vector3.ZERO, 250, 5)
