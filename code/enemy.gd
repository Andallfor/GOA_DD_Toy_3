extends CharacterBody2D

@export var speed: float = 800;

var _isFirstRun: bool = true;

func _physics_process(delta: float) -> void:
	if (_isFirstRun): # one frame delay to allow nav server to sync
		_isFirstRun = false;
		return;
	
	var path: PackedVector2Array = NavigationServer2D.map_get_path(get_world_2d().get_navigation_map(), self.position, %player.position, true);
	
	# https://docs.godotengine.org/en/stable/tutorials/navigation/navigation_using_navigationpaths.html
	var mDelta: float = speed * delta;
	var vel: Vector2 = self.transform.origin.direction_to(path[1]) * mDelta;
	self.position = self.transform.origin.move_toward(self.transform.origin + vel, mDelta);
