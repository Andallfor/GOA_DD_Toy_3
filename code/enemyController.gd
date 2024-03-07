extends Node2D

@export var updateInterval: float = 1;
var timeElapsed: float = 0;
var isUpdating: bool = false;

var registeredEnemies: Array[CharacterBody2D] = [];
var mask: Array[bool] = [];

func register(n: CharacterBody2D):
	registeredEnemies.append(n);

func _process(delta: float) -> void:
	timeElapsed += delta;

	if (!isUpdating && timeElapsed > updateInterval):
		isUpdating = true;
		mask = [];
		for nav in %terrain.navs:
			mask.append(nav.is_enabled());
			nav.set_enabled(true);
		return;
	
	if (isUpdating):
		timeElapsed = 0;
		isUpdating = false;
		
		var world: RID = get_world_2d().get_navigation_map();
		for char in registeredEnemies:
			var path: PackedVector2Array = NavigationServer2D.map_get_path(world, char.position, %player.position, true);
			char.path = path;
			char.pathIndex = 0;
		
		for nav in %terrain.navs:
			nav.set_enabled(mask.pop_at(0));
