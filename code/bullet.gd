extends Area2D

var timeElapsed: int = 0;

func _physics_process(delta):
	self.global_position += transform.x * 16_000 * delta;
	timeElapsed += delta;
	
	if (timeElapsed > 1_000):
		self.queue_free();

func _on_body_entered(other):
	var layer: int = other.get_collision_layer_value();
	if (layer == 4):
		self.queue_free();
