extends Node

var player_walk_speed : float = 60.0
var player_sprint_speed : float = 120.0
var player_hp : int = 1

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	seed(rng.seed)
