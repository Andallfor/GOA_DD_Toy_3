extends CharacterBody2D

@export var speed: float = 200;
@export var minDist: float = 1000;
@export var minFireDist: float = 2000;
@export var minFireInterval: float = 1.5;
@export var isBullet: bool = true;
@export var health: int = 3;
@export var hiddenTimer: float = 2;
var _isFirstRun: bool = true;

const bullet = preload("res://resources/sprites/enemy/sniper_round.tscn");
const rocket = preload("res://resources/sprites/enemy/rifle_round.tscn");

var path: PackedVector2Array = PackedVector2Array([]);
var pathIndex: int = 0;
var rng = RandomNumberGenerator.new();
var currentFireInterval: float = 0;
var timeSinceLastSeen: float = 1000;
var lastSubFireInterval: float = 0;

func _ready() -> void:
	%enemyController.register(self);

func _physics_process(delta: float) -> void:
	if (_isFirstRun): # one frame delay to allow nav server to sync
		_isFirstRun = false;
		return;
	
	if ($sprite.animation == "death"):
		if (!$sprite.is_playing()):
			%enemyController.registeredEnemies.erase(self);
			$sprite.visible = false;
			if (!$audio.playing):
				self.queue_free();
		return;
		
	var dist = %player.position - self.position;
	if (dist.length() > 5_000):
		return;
	
	# check if we can see player
	var state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state;
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(self.global_position, %player.global_position, 1 << 3);
	var vis := state.intersect_ray(query);
	
	if (vis):
		timeSinceLastSeen += delta;
		if (timeSinceLastSeen > hiddenTimer):
			$sprite.play("idle");
			return;
	else:
		if (timeSinceLastSeen > hiddenTimer):
			$audio.stream = get_node("/root/AudioController").enemySee;
			$audio.play();
		timeSinceLastSeen = 0;
	
	if ($sprite.animation == "shoot" && $sprite.is_playing()):
		if (!isBullet):
			if (!$audio.playing && $sprite.frame == 0):
				$audio.stream = get_node("/root/AudioController").riflerFire;
				$audio.play();
			lastSubFireInterval += delta;
			if (lastSubFireInterval > 0.3):
				shoot();
				lastSubFireInterval = 0;
		else:
			if (!$audio.playing):
				$audio.stream = get_node("/root/AudioController").sniperFire;
				$audio.play();
		return;
	currentFireInterval += delta;
	lastSubFireInterval = 0;
	
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
		$audio.stream = get_node("/root/AudioController").riflerDie;
		$audio.play();

func shoot():
	$sprite.play("shoot");
	
	$parent/spawn.look_at(%player.position);
	var b: Node2D = bullet.instantiate() if (isBullet) else rocket.instantiate();
	%bulletParent.add_child(b);

	b.transform = $parent/spawn.global_transform;
