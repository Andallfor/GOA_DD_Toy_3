extends CharacterBody2D

var timeElapsed: float = 0;
var isPlayer: bool = false;
@export var animation: String = "shot";
@export var speed: float = 16_000;
@export var explosionScale: float = 1;
@export var damage: int = 1;

const pierce = preload("res://resources/sprites/shooting/bullet_pierce.tscn");

func _ready():
	$sprite.play(animation);

func _physics_process(delta):
	if ($sprite.animation == "explosion"):
		if (!$sprite.is_playing()):
			$sprite.visible = false;
			if (!$audio.playing):
				self.queue_free();
		return;
	
	var col: KinematicCollision2D = move_and_collide(transform.x * speed * delta);
	
	if (col):
		if (col.get_collider().get_meta_list().has("player")):
			col.get_collider().takeDamage(self.damage);
			explode(col);
			$audio.stream = get_node("/root/AudioController").hit;
			$audio.play();
		elif (col.get_collider().get_meta_list().has("enemy")):
			var e: Node2D = col.get_collider();
			e.takeDamage(self.damage);
			
			var b: Node2D = pierce.instantiate();
			self.get_parent().add_child(b);
			b.global_position = col.get_position();
			
			self.add_collision_exception_with(col.get_collider());
		else:
			if (isPlayer):
				$audio.stream = get_node("/root/AudioController").playerMiss;
			else:
				$audio.stream = get_node("/root/AudioController").enemyMiss;
			$audio.play();
			explode(col);
	
	timeElapsed += delta;
	if (timeElapsed > 5):
		self.queue_free();

func explode(col: KinematicCollision2D):
	self.position = col.get_position();
	self.z_index = 100;
	$sprite.speed_scale = 3;
	$sprite.play("explosion");
	$sprite.set_frame(0);
	self.set_collision_layer(0);
	self.set_collision_mask(0);
	self.global_scale = Vector2(explosionScale, explosionScale);
