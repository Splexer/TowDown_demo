extends Node2D

var floor_tiles : Array[Vector2i] = [Vector2i(0,0), Vector2i(1,0),
Vector2i(2,0),Vector2i(0,1),Vector2i(1,1),Vector2i(2,1)]
var wall_tiles : Array[Vector2i] = [Vector2i(0,3), Vector2i(0,2)]
var water_tile : Vector2i = Vector2i(3,0)
var vase_tile : Vector2i = Vector2i(1,2)

@onready var Define_Layer : TileMapLayer = $Define_Layer
@onready var ObjectLayer : TileMapLayer = $ObjectLayer
@onready var camera : Camera2D = $Player/Camera2D

func _ready() -> void:
	_generate_map()
	Define_Layer.hide()
	_get_borders_position()

#func _unhandled_input(event: InputEvent) -> void:
	#if Input.is_action_just_pressed("debug_key1"):
		#_generate_map()

func _generate_map()-> void:
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
					"wall":	
						ObjectLayer.set_cell(tile_position, 0, wall_tiles.pick_random())
					"floor":	
						ObjectLayer.set_cell(tile_position, 0, floor_tiles.pick_random())
					"object":
						ObjectLayer.set_cell(tile_position, 0, vase_tile)
					_:
						_define_tile(noise.get_noise_2d(x, y), tile_position)
		
func _define_tile(value: float, tile_position: Vector2i)-> void:
	if value < -0.2:
		ObjectLayer.set_cell(tile_position, 0, water_tile)
	elif value < 0.3:
		ObjectLayer.set_cell(tile_position, 0, floor_tiles.pick_random())
	elif value < 0.4:
		ObjectLayer.set_cell(tile_position, 0, vase_tile)
	else:
		ObjectLayer.set_cell(tile_position, 0, wall_tiles.pick_random())

func _get_borders_position()-> void:
	var rect : Rect2i = Define_Layer.get_used_rect()
	camera.limit_left = rect.position.x * 16
	camera.limit_top = rect.position.y * 16
	camera.limit_right = (rect.position.x + rect.size.x) * 16
	camera.limit_bottom = (rect.position.y + rect.size.y) * 16
