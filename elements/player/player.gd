extends CharacterBody2D

class_name Player

#config vars
var sprint_speed : float = 220.0
var walk_speed : float = 100.0
var hp : int = 10

var is_active : bool = true
var is_jumping : bool = false
var speed : float = 120.0
var _tween : Tween

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	speed = Global.player_speed
	sprint_speed = Global.player_sprint_speed
	#hp = Global.player_hp
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_key1"):
		take_damage(1)
		print("now hp = ", hp)

func _physics_process(_delta):
	if !is_active: return
	if Input.is_action_just_pressed("jump"):
		_jump()
	#вектор направления, через 2 функции axis, -1.0, 1.0, в каждой	
	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	#поворачивает персонажа, в зависимости от значения x
	sprite.flip_h = direction.x < 0 
	if direction:
		if Input.is_action_pressed("sprint"):
			sprite.play("run")
			speed = sprint_speed
		else:
			sprite.play("walk")
			speed = walk_speed	
		velocity = direction.normalized() * speed
	else:
		sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)
	move_and_slide()
	
func _jump()-> void:
	#прыжок по сути, отключение коллизии и смещение спрайта
	if is_jumping: return
	is_jumping = true
	collider.set_deferred("disabled", true)
	var tween = get_tween()
	tween.tween_property(sprite, "position", Vector2(0, -40), 0.3 )
	await tween.finished
	tween = get_tween()
	tween.tween_property(sprite, "position", Vector2(0, 0), 0.3)
	await tween.finished
	collider.set_deferred("disabled", false)
	sprite.play("idle")
	is_jumping = false

func take_damage(value: int)-> void:
	sprite.play("hurt")
	hp -= value
	if hp <= 0:
		die()

func die()-> void:
	is_active = false
	sprite.play("die")
	await sprite.animation_finished
	Events.player_died.emit()

func get_tween()-> Tween:
	#чтобы каждый раз не создавать новый tween
	if (_tween):
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween
