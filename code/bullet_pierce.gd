extends AnimatedSprite2D

func _ready() -> void:
	self.play("default");
	
func _process(delta: float) -> void:
	if (!self.is_playing()):
		self.queue_free();
