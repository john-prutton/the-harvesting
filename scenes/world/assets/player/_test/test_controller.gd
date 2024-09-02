extends Node

@onready var anim_tree : AnimationTree = $AnimationTree
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_tree.active = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	var is_jump = 0
	if event is InputEvent:
		if Input.is_action_just_pressed("jump"):
			is_jump = 1
			print("jump")
	anim_tree.set("parameters/BlendSpace1D/blend_position", is_jump)
