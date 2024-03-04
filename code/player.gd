extends Node2D

@export var speedVert: int = 50;
@export var speedHorz: int = 50;

var height: float = 10;
var isInTransition: bool = false;
var _isFirstRun: bool = true;

var sprite: AnimatedSprite2D;

var animationPriority: Array[String] = ["shoot", "reload", "run", "idle"];
var animationSpeed = {
	"shoot": 2,
	"reload": 1,
	"run": 1.5,
	"idle": 1
};

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = %spawn.position;
	
	sprite = get_node("sprite");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (_isFirstRun): # one frame delay to allow nav server to sync
		_isFirstRun = false;
		return;

	var vec: Vector2 = Vector2(0, 0);

	if (Input.is_action_pressed("move_up")):
		vec.y -= speedVert;
	
	if (Input.is_action_pressed("move_down")):
		vec.y += speedVert;
	
	if (Input.is_action_pressed("move_right")):
		vec.x += speedVert;
		sprite.flip_h = false;
	
	if (Input.is_action_pressed("move_left")):
		vec.x -= speedVert;
		sprite.flip_h = true;
	
	if (Input.is_action_just_pressed("shoot")):
		tryPlayAnimation("shoot");
	
	if (sprite.animation == "shoot" && sprite.frame_progress != 1):
		vec = Vector2(0, 0);
	
	if (vec.length() != 0):
		tryPlayAnimation("run");
	else:
		tryPlayAnimation("idle", ["run"]);
	
	vec *= delta;
	
	# check if we're in a ramp transition for above and below levels
	# note that height at mod 10 is considered to be at the surface of that tile layer
	# height 0 is the surface of the first tile layer, not the bottom
	var level: int = int(height / 10);
	var world: RID = get_world_2d().get_navigation_map();
	
	var transitionMaskToBelow = level + 8;
	var transitionMaskToAbove = transitionMaskToBelow + 1;
	
	var onBelow = checkTransition(transitionMaskToBelow);
	var onAbove = checkTransition(transitionMaskToAbove);
	
	if (onBelow || onAbove):
		isInTransition = true;
		%terrain.navs[max(level - 1, 0)].set_enabled(true);
		%terrain.navs[min(level + 1, 4)].set_enabled(true);
	elif (isInTransition):
		isInTransition = false;
		
		var cur: RID = NavigationServer2D.map_get_closest_point_owner(world, self.position);
		for i in range(len(%terrain.navs)):
			var nav = %terrain.navs[i];
			var e = nav.get_region_rid() == cur;
			nav.set_enabled(e);
			
			if (e):
				height = i * 10;

	self.position = NavigationServer2D.map_get_closest_point(world, self.position + vec);
	%camera.position = self.position;
	%camera.force_update_scroll(); # otherwise camera has one frame delay

func checkTransition(mask: int) -> bool:
	if (mask <= 8 || mask >= 14):
		return false;
	
	var point = PhysicsPointQueryParameters2D.new();
	point.position = self.position;
	point.collide_with_areas = true;
	point.collision_mask = 1 << (mask - 1);
	var result: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(point, 1);
	
	return result.size() != 0;

func tryPlayAnimation(name: String, ignore: Array[String] = []):
	# shush
	# if new priority is greater than old priority (0 is greatest priority)
	var isDone: bool = sprite.frame_progress == 1;
	var override: bool = ignore.has(sprite.animation);
	var priority: bool = animationPriority.find(name) < animationPriority.find(sprite.animation);
	if (isDone || override || priority):
		sprite.play(name);
		sprite.speed_scale = animationSpeed[name];
