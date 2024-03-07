extends CharacterBody2D

@export var speed: float = 200;
@export var minDist: float = 1000;
@export var minFireDist: float = 2000;
@export var minFireInterval: float = 1.5;
@export var isBullet: bool = true;
@export var health: int = 3;
var _isFirstRun: bool = true;

const bullet = preload("res://resources/sprites/enemy/sniper_round.tscn");
const rocket = preload("res://resources/sprites/enemy/sniper_round.tscn");

var path: PackedVector2Array = PackedVector2Array([]);
var pathIndex: int = 0;
var rng = RandomNumberGenerator.new();
var currentFireInterval: float = 0;

func _ready() -> void:
	%enemyController.register(self);

func _physics_process(delta: float) -> void:
	if (_isFirstRun): # one frame delay to allow nav server to sync
		_isFirstRun = false;
		return;
	
	if ($sprite.animation == "death"):
		if (!$sprite.is_playing()):
			%enemyController.registeredEnemies.erase(self);
			self.queue_free();
		return;
	
	if ($sprite.animation == "shoot" && $sprite.is_playing()):
		return;
	currentFireInterval += delta;
	
	var dist = %player.position - self.position;
	if (abs(dist.length()) < minFireDist && currentFireInterval > minFireInterval):
		if (rng.randi_range(0, 10) == 2):
			currentFireInterval = 0;
			shoot();
			return;
	
	if (path.size() == 0 || abs(dist.length()) < minDist):
		$sprite.play("idle");
		$sprite.flip_h = dist.x < 0;
		return;
	
	if (pathIndex < path.size()):
		# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationpaths.html
		var mDelta: float = speed * delta;
		if (self.transform.origin.distance_to(path[pathIndex]) < 10):
			pathIndex += 1;
			if (pathIndex >= path.size()):
				return;
		
		var vel: Vector2 = self.transform.origin.direction_to(path[pathIndex]) * mDelta;
		self.transform.origin = self.transform.origin.move_toward(self.transform.origin + vel, mDelta);
		$sprite.flip_h = vel.x < 0;
		$sprite.play("run");

func takeDamage(dmg: int):
	self.health -= dmg;
	if (self.health <= 0):
		$sprite.play("death");

func shoot():
	$sprite.play("shoot");
	
	$parent/spawn.look_at(%player.position);
	var b: Node2D = bullet.instantiate();
	%bulletParent.add_child(b);
	b.transform = $parent/spawn.global_transform;
