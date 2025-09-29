extends Node

var player_speed : float = 100.0
var player_sprint_speed : float = 220.0
var player_hp : int = 1

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	seed(rng.seed)
