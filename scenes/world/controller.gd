extends Node3D

@onready var fps = $FPS

func _process(delta):
	fps.text = "%d FPS" % (1 / delta)
