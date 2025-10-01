extends Node

var save_path = "user://"
var save_file_name = "test_build_save.tres"

var SaveFileData : SaveDataResource #= SaveDataResource.new()

func _save_level():
	var err = ResourceSaver.save(SaveFileData, save_path + save_file_name)
	if err != OK:
		push_error("Ошибка сохранения: %s" % err)
	
func _load_saved_level():
	if FileAccess.file_exists(save_path + save_file_name):
		SaveFileData = ResourceLoader.load(save_path + save_file_name).duplicate(true)
		
		
var player_walk_speed : float = 60.0
var player_sprint_speed : float = 120.0
var player_hp : int = 4

var on_level_coins : int = 20
var collected_coins : int = 0
var required_coins : int = 10


var rng := RandomNumberGenerator.new()

func _ready() -> void:
	Events.pick_up_coin.connect(_pick_up_coin)
	rng.randomize()
	seed(rng.seed)
	print("seed = ", rng.seed)

func _pick_up_coin()-> void:
	collected_coins += 1
