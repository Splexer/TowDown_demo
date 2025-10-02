extends CharacterBody2D

class_name Enemy

#Простая машина состояний для врага, гуляет, преследует, атакует
enum States {WALKING, HUNTING, ATTACKING}

var state : States = States.WALKING
var speed : float = 100.0
var visibility_range : float = 150.0
var attack_range : float = 10.0
var attack_damage : int = 1

var player : Player
#var last_player_pos : Vector2i = Vector2i.ZERO
var astar : AStarGrid2D
var tilemap : TileMapLayer
var current_tile_coord : Vector2i = Vector2i.ZERO
var current_id_path : Array[Vector2i] = [] #Массив из тайлов, если двигаемся используя AStar

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_area : Area2D = $Damage_Area

#Читаем конфиг, устанавливаем значения
func _ready() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	var err := cfg.load("res://core/config.ini") 
	if err == OK:
		speed = cfg.get_value("NPC", "speed", 100.0)
		visibility_range = cfg.get_value("NPC", "visibility_range", 150.0)
		attack_range = cfg.get_value("NPC", "attack_range", 10.0)
		attack_damage = cfg.get_value("NPC", "attack_damage", 1)

#Поведение в зависимости от состояния
func _physics_process(delta: float) -> void:
	match state:
		States.WALKING:
			if _player_in_range(visibility_range):
				state = States.HUNTING
				sprite.modulate = Color(1.825, 1.825, 1.825)
				current_id_path = []
			_path_move(delta)
		States.HUNTING:
			hunt(delta)
		States.ATTACKING:
			attack()

#Двигаться используя алгоритм AStar чтобы обходить тайлы
func _path_move(delta: float)-> void:
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
		
#Про напрямую двигаемся к цели
func _move(delta: float)-> void:
	sprite.play("walk")
	var target_position = player.global_position
	if global_position.x < target_position.x:
		sprite.flip_h = true
	elif global_position.x > target_position.x:
		sprite.flip_h = false
	global_position = global_position.move_toward(target_position, speed * delta)

#Состояние преследования. Если ушёл из радиуса, гуляем. Если близко, атакуем
#Иначе бежим напрямую
func hunt(delta: float)-> void:
	if !_player_in_range(visibility_range):
		sprite.modulate = Color(1.0, 1.0, 1.0)
		state = States.WALKING
		return
	if _player_in_range(attack_range):
		state = States.ATTACKING
		return
	#if current_id_path.is_empty():
		#current_id_path = _find_path(tilemap.local_to_map(player.global_position))
	#move(delta)
	_move(delta)

#Атака. Работает через Area, проверяем, есть ли там игрок, если да, бить!
func attack()-> void:
	sprite.play("attack")
	var bodies = damage_area.get_overlapping_bodies()
	for i in bodies:
		if i is Player:
			i.take_damage(attack_damage)
	await sprite.animation_finished
	state = States.HUNTING
	
#Функция для проверки виден ли игрок и достаточно ли близко	
func _player_in_range(range_len: float)-> bool:
	var result = _send_ray_to_player()
	if result.has("collider") == false:
		return false
	elif result["collider"] is Player and result["position"].distance_to(self.global_position) <= range_len:
		return true
	else: 
		return false	

#Кидаем луч до игрока, напрямую через физический сервер, чтобы узел не создавать
func _send_ray_to_player()-> Dictionary:
	var space_state = get_world_2d().direct_space_state
	var ray = PhysicsRayQueryParameters2D.create(self.global_position, player.global_position)
	var result:Dictionary = space_state.intersect_ray(ray)
	return result

#Найти путь до нужной точки через AStar
func _find_path(target_tile: Vector2i)-> Array[Vector2i]:
	if astar and tilemap:
		var current_tile: Vector2i = tilemap.local_to_map(global_position)
		var id_path :Array[Vector2i] = astar.get_id_path(current_tile, target_tile)
		return id_path
	else:
		return []	

#Функция настройки. Чтобы можно было обращаться к карте, алгоритму поиска и полям игрока
#Так то не совсем по SOLID, но зато быстро и удобно
func setup(new_astar: AStarGrid2D, new_tilemap: TileMapLayer, new_player: Player)-> void:
	astar = new_astar
	tilemap = new_tilemap
	player = new_player

#Когда стоим, надо имитировать жизнь, ищем путь в случайную точку каждые 5 сек.
func _on_timer_timeout() -> void:
	if state == States.WALKING and current_id_path.is_empty():
		var new_path : Array[Vector2i] = _find_path(tilemap.get_used_cells().pick_random())
		if new_path != []:
			current_id_path = new_path	
