extends CharacterBody2D

class_name Enemy

enum States {WALKING, HUNTING, ATTACKING}

var state : States = States.WALKING
var speed : float = 100
var visibility_range : float = 150
var attack_range : float = 10
var attack_damage : int = 1

var player : Player
var last_player_pos : Vector2i = Vector2i.ZERO
var astar : AStarGrid2D
var tilemap : TileMapLayer
var current_tile_coord : Vector2i = Vector2i.ZERO
var current_id_path : Array[Vector2i] = []

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area : Area2D = $Damage_Area

#func _ready() -> void:
	#current_id_path = [Vector2i(44, 20),Vector2i(43, 20),Vector2i(42, 20),Vector2i(41, 20),Vector2i(40, 20),Vector2i(39, 20),Vector2i(38, 20),
	#Vector2i(37, 20),Vector2i(36, 20),Vector2i(35, 20),Vector2i(34, 20),Vector2i(33, 20),Vector2i(32, 20),Vector2i(31, 20),Vector2i(30, 20)]
func _process(delta: float) -> void:
	match state:
		States.WALKING:
			move(delta)
			if _player_in_range(visibility_range):
				state = States.HUNTING
				sprite.modulate = Color(1.825, 1.825, 1.825)
				current_id_path = []
		States.HUNTING:
			hunt(delta)
		States.ATTACKING:
			attack()

func move(delta: float)-> void:
	if current_id_path.is_empty() == false:
		sprite.play("walk")
		astar.set_point_solid(current_tile_coord, false)
		var target_position = tilemap.map_to_local(current_id_path.front())
		if global_position.x < target_position.x:
			sprite.flip_h = true
		elif global_position.x > target_position.x:
			sprite.flip_h = false
		global_position = global_position.move_toward(target_position, speed * delta)
		if global_position.distance_to(target_position) < 1:
			global_position = target_position
			current_tile_coord = tilemap.local_to_map(global_position)
			astar.set_point_solid(current_tile_coord, true)
			current_id_path.pop_front()
	else:
		sprite.play("idle")	
			

func hunt(delta: float)-> void:
	if !_player_in_range(visibility_range):
		sprite.modulate = Color(1.0, 1.0, 1.0)
		state = States.WALKING
		return
	if _player_in_range(attack_range):
		state = States.ATTACKING
		return
	if current_id_path.is_empty():
		current_id_path = _find_path(tilemap.local_to_map(player.global_position))
	move(delta)
		
func attack()-> void:
	sprite.play("attack")
	var bodies = damage_area.get_overlapping_bodies()
	for i in bodies:
		if i is Player:
			i.take_damage(attack_damage)
	await sprite.animation_finished
	state = States.HUNTING
	
func _player_in_range(range: float)-> bool:
	var result = _send_ray_to_player()
	if result.has("collider") == false:
		return false
	elif result["collider"] is Player and result["position"].distance_to(self.global_position) <= range:
		return true
	else: 
		return false	
	#elif result["collider"] is Player and result["position"].distance_to(self.global_position) <= visibility_range:
		#if result["position"].distance_to(self.global_position) <= attack_range:
				#state = States.ATTACKING
		#else:
			#state = States.HUNTING
			#return 

		
func _send_ray_to_player()-> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var ray = PhysicsRayQueryParameters2D.create(self.global_position, player.global_position)
	var result:Dictionary = space_state.intersect_ray(ray)
	return result

func _find_path(target_tile: Vector2i)-> Array[Vector2i]:
	if astar and tilemap:
		var current_tile: Vector2i = tilemap.local_to_map(global_position)
		var id_path :Array[Vector2i] = astar.get_id_path(current_tile, target_tile)
		return id_path
	else:
		return []	

func setup(new_astar: AStarGrid2D, new_tilemap: TileMapLayer, new_player: Player)-> void:
	astar = new_astar
	tilemap = new_tilemap
	player = new_player

func _on_timer_timeout() -> void:
	if state == States.WALKING and current_id_path.is_empty():
		var new_path : Array[Vector2i] = _find_path(tilemap.get_used_cells().pick_random())
		if new_path != []:
			current_id_path = new_path	
