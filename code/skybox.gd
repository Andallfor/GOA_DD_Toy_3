extends Node2D

func _process(delta):
	self.position = -%player.position / 100;
