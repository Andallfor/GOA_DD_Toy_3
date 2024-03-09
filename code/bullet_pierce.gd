extends AnimatedSprite2D

func _ready() -> void:
	self.play("default");
	$audio.stream = get_node("/root/AudioController").hit;
	$audio.play();
	
func _process(delta: float) -> void:
	if (!self.is_playing()):
		self.visible = false;
		if (!$audio.playing):
			self.queue_free();
