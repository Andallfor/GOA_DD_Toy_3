extends Node2D

@export var map0: TileMap;
@export var map1: TileMap;
@export var map2: TileMap;
@export var map3: TileMap;
@export var map4: TileMap;

@export var nav0: NavigationRegion2D;
@export var nav1: NavigationRegion2D;
@export var nav2: NavigationRegion2D;
@export var nav3: NavigationRegion2D;
@export var nav4: NavigationRegion2D;

var maps: Array[TileMap];
var navs: Array[NavigationRegion2D];

const LAYER_HEIGHT: float = 10;

const TERRAIN_LAYER: int = 0;
const RAMP_LAYER: int = 1;
const DETAIL_LAYER: int = 2;

const PLAYER_Z_ABOVE: int = 21;
const PLAYER_Z_BELOW: int = 19;

func _ready():
	maps = [map0, map1, map2, map3, map4];
	navs = [nav0, nav1, nav2, nav3, nav4];

func queryLayerTerrain(id: int, coord: Vector2i) -> TileData:
	return maps[id].get_cell_tile_data(TERRAIN_LAYER, coord);

func queryLayerRamp(id: int, coord: Vector2i) -> TileData:
	return maps[id].get_cell_tile_data(RAMP_LAYER, coord);

func worldToMap(pos: Vector2) -> Vector2i:
	return maps[0].local_to_map(pos);
