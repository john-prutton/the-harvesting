class_name Character
extends Node

@onready var anim_tree : AnimationTree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true

func update_animation(velocity: Vector3):
	var is_jump = velocity.y > 0
	anim_tree.set("parameters/BlendSpace1D/blend_position", is_jump)
