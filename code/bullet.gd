extends CharacterBody2D

var timeElapsed: float = 0;

func _ready():
	$sprite.play("shot");

func _physics_process(delta):
	if ($sprite.animation == "explosion" && $sprite.frame_progress == 1):
		self.queue_free();
		return;
	
	if ($sprite.animation == "explosion"):
		return;
	
	var collision: KinematicCollision2D = move_and_collide(transform.x * 16_000 * delta);
	
	if (collision):
		self.position = collision.get_position();
		$sprite.speed_scale = 3;
		$sprite.play("explosion");
		self.scale = Vector2(2.5, 2.5);
	
	timeElapsed += delta;
	if (timeElapsed > 1):
		self.queue_free();
