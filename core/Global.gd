extends Node

var config_file : ConfigFile = ConfigFile.new()

var save_path = "user://"
var save_file_name = "test_build_save.res"
var save_data: Dictionary = {
	"seed" : 0,
	"player_position" : Vector2(0,0),
	"player_hp" : 1,
	"collected_coins" : 0,
	"ucollected_coins_position" : [],
	"enemies_position" : []
}

var level_scene : PackedScene = preload("res://elements/level/level.tscn")
var main_menu_scene : PackedScene = preload("res://UI/Main_menu/main_menu.tscn")


var on_level_coins : int = 20
var collected_coins : int = 0
var required_coins : int = 10


var rng := RandomNumberGenerator.new()

func _ready() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	var err := cfg.load("res://core/config.ini") 
	if err == OK:
		required_coins = cfg.get_value("Global", "required_coins", 15)
		on_level_coins = cfg.get_value("Global", "on_level_coins", 25)
	Events.load_Main_menu.connect(_load_Main_menu)
	Events.save_level.connect(_save_level)
	Events.load_save_level.connect(_load_save_level)
	Events.load_new_level.connect(_load_new_level)
	Events.pick_up_coin.connect(_pick_up_coin)
	rng.randomize()
	seed(rng.seed)
	print_debug("seed = ", rng.seed)

func _save_level()-> void:
	var level : Level = get_tree().current_scene
	if level.player.hp < 1:
		print("hp < 1 can't save now")
		return 
	save_data["player_hp"] = level.player.hp
	save_data["seed"] = rng.seed
	save_data["player_position"] = level.player.position
	save_data["collected_coins"] = collected_coins
	var uncollected_coins:Array = get_tree().get_nodes_in_group("Coin")
	save_data["uncollected_coins_position"] = []
	save_data["enemies_position"] = []
	for i in uncollected_coins:
		save_data["uncollected_coins_position"].append(i.position)
	var enemies	: Array = get_tree().get_nodes_in_group("NPC")
	for i in enemies:
		save_data["enemies_position"].append(i.position)
	var file = FileAccess.open(save_path + save_file_name, FileAccess.WRITE)	
	file.store_var(save_data.duplicate())
	file.close()
	Events.save_succes.emit()
	print_debug("Игра сохранена")	

func _load_new_level()-> void:
	get_tree().change_scene_to_packed(level_scene)
	collected_coins = 0
	await get_tree().scene_changed
	var level : Level = get_tree().current_scene
	level.generate_map()
	level.set_coins(on_level_coins)
	
func _load_save_level()-> void:
	print("Начиная загружать игру")
	if !FileAccess.file_exists(save_path + save_file_name):
		Events.bad_save_file.emit()
		print("не удалось загрузить игру :(((")
		return
	var file = FileAccess.open(save_path + save_file_name, FileAccess.READ)
	save_data = file.get_var()
	rng.seed = save_data["seed"]
	seed(save_data["seed"])
	get_tree().change_scene_to_packed(level_scene)
	await get_tree().scene_changed
	var level : Level = get_tree().current_scene
	level.player.position = save_data["player_position"]
	level.player.hp = save_data["player_hp"]
	collected_coins = save_data["collected_coins"]
	level.generate_map()
	level.set_coins(save_data["uncollected_coins_position"].size(), save_data["uncollected_coins_position"])
	level.set_enemies_position(save_data["enemies_position"])
	print("успешно загрузил сохранение")

func _load_Main_menu()-> void:
	get_tree().change_scene_to_packed(main_menu_scene)
	

func _pick_up_coin()-> void:
	collected_coins += 1
	if collected_coins >= required_coins:
		Events.win.emit()
