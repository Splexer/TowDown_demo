extends Node2D

class_name Level

var floor_tiles : Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0),
Vector2i(2,0),Vector2i(0,1),Vector2i(1,1),Vector2i(2,1)]
var wall_tiles : Array[Vector2i] = [Vector2i(0,3), Vector2i(0,2)]
var water_tile : Vector2i = Vector2i(3,0)
var vase_tile : Vector2i = Vector2i(1,2)

var astar : AStarGrid2D

var free_tiles: Array[Vector2i] = []

@onready var coin_scene : PackedScene = load("res://elements/coin/coin.tscn")
@onready var Define_Layer : TileMapLayer = $Define_Layer
@onready var ObjectLayer : TileMapLayer = $ObjectLayer
@onready var player : Player = $Player
@onready var camera : Camera2D = $Player/Camera2D

func _ready() -> void:
	astar = AStarGrid2D.new()
	astar.cell_size = Vector2(16, 16)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_CHEBYSHEV
	astar.region = Define_Layer.get_used_rect()
	astar.update()
	_get_borders_position()
	_init_NPCs()
	get_tree().paused = false

func _init_NPCs()-> void:
	for i in get_tree().get_nodes_in_group("NPC"):
		i.setup(astar, ObjectLayer, player)

func generate_map()-> void:
	var noise = FastNoiseLite.new()
	noise.seed = Global.rng.seed
	noise.frequency = 0.1
	for x in Define_Layer.get_used_rect().size.x:
		for y in Define_Layer.get_used_rect().size.y:
			var tile_position = Vector2i(x, y)
			var tile_data :TileData = Define_Layer.get_cell_tile_data(tile_position)
			if tile_data != null:
				var type_data = tile_data.get_custom_data("type")
				match type_data:
					"water":
						ObjectLayer.set_cell(tile_position, 0, water_tile)
						free_tiles.append(tile_position)
					"wall":	
						ObjectLayer.set_cell(tile_position, 0, wall_tiles.pick_random())
						astar.set_point_solid(tile_position, true)
					"floor":	
						ObjectLayer.set_cell(tile_position, 0, floor_tiles.pick_random())
						free_tiles.append(tile_position)
					"object":
						ObjectLayer.set_cell(tile_position, 0, vase_tile)
						astar.set_point_solid(tile_position, true)
					_:
						_define_tile(noise.get_noise_2d(x, y), tile_position)
	Define_Layer.hide()				
	#for i in range(Global.on_level_coins):
		#var coin: Area2D = coin_scene.instantiate()
		#var index = Global.rng.randi_range(0, free_tiles.size() - 1)
		#var tile_position : Vector2i = free_tiles[index]
		#free_tiles.erase(tile_position)
		#coin.global_position = ObjectLayer.map_to_local(tile_position)
		#add_child(coin)
func _define_tile(value: float, tile_position: Vector2i)-> void:
	if value < -0.2:
		ObjectLayer.set_cell(tile_position, 0, water_tile)
		free_tiles.append(tile_position)
	elif value < 0.3:
		ObjectLayer.set_cell(tile_position, 0, floor_tiles.pick_random())
		free_tiles.append(tile_position)
	elif value < 0.4:
		ObjectLayer.set_cell(tile_position, 0, vase_tile)
		astar.set_point_solid(tile_position, true)
	else:
		ObjectLayer.set_cell(tile_position, 0, wall_tiles.pick_random())
		astar.set_point_solid(tile_position, true)

func set_coins(amount: int = Global.on_level_coins, coords: Array = [])-> void:
	if coords == []:
		for i in range(amount):
			var coin: Area2D = coin_scene.instantiate()
			var index: int = Global.rng.randi_range(0, free_tiles.size() - 1)
			var tile_position : Vector2i = free_tiles[index]
			free_tiles.erase(tile_position)
			coin.global_position = ObjectLayer.map_to_local(tile_position)
			add_child(coin)
	else:
		for i in coords:
			var coin: Area2D = coin_scene.instantiate()
			coin.global_position = i
			add_child(coin)
			
func set_enemies_position(coords : Array)-> void:
	var enemies: Array = get_tree().get_nodes_in_group("NPC")
	for i in enemies.size():
		enemies[i].position = coords[i]

func _get_borders_position()-> void:
	var rect : Rect2i = Define_Layer.get_used_rect()
	camera.limit_left = rect.position.x * 16
	camera.limit_top = rect.position.y * 16
	camera.limit_right = (rect.position.x + rect.size.x) * 16
	camera.limit_bottom = (rect.position.y + rect.size.y) * 16


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	player.global_position = Vector2(580, 340)
