extends CharacterBody2D

class_name Player

var player_cfg : ConfigFile = ConfigFile.new()
#config vars
var sprint_speed : float = 120.0
var walk_speed : float = 60.0
var hp : int = 4

var is_active : bool = true #Можно ли управлять
var immunity : bool = false #Можно ли получать урон
var is_jumping : bool = false #Мы в прыжке?
var speed : float = walk_speed
var _tween : Tween 

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var shadow : Sprite2D = $shadow

#Читаем конфиг. Потом ещё всем кому нужно сообщаем наше актуальное HP.
func _ready() -> void:
	var cfg : ConfigFile = ConfigFile.new()
	var err := cfg.load("res://core/config.ini") 
	if err == OK:
		walk_speed = cfg.get_value("player", "walk_speed", 60.0)
		sprint_speed = cfg.get_value("player", "sprint_speed", 120.0)
		hp = cfg.get_value("player", "hp", 4)
	Events.hud_hp_update.emit(hp)

#Управление
func _physics_process(_delta):
	if !is_active: return
	if Input.is_action_just_pressed("jump"):
		_jump()
	#вектор направления, через 2 функции axis, -1.0, 1.0, в каждой	
	var direction:Vector2 = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
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

#Прыжок - это отключение коллайдера и смещение спрайта. И обратно на свои места
func _jump()-> void:
	#прыжок по сути, отключение коллизии и смещение спрайта
	if is_jumping: return
	is_jumping = true
	collider.set_deferred("disabled", true)
	var tween = get_tween()
	tween.tween_property(sprite, "position", Vector2(0, -40), 0.2)
	await tween.finished
	tween = get_tween()
	tween.tween_property(sprite, "position", Vector2(0, 0), 0.2)
	await tween.finished
	collider.set_deferred("disabled", false)
	sprite.play("idle")
	is_jumping = false

#Получение урона. С небольшим Delay, чтобы не умереть с 1 касания
#Также пара ограничений, чтобы не били после смерти, анимация до конца и т.п.
func take_damage(value: int)-> void:
	if immunity == true or hp <= 0: return
	immunity = true
	is_active = false
	sprite.play("hurt")
	await sprite.animation_finished
	hp -= value
	Events.hud_hp_update.emit(hp)
	is_active = true
	if hp <= 0:
		die()
	await get_tree().create_timer(0.5).timeout	
	immunity = false

#Смерть :(
func die()-> void:
	is_active = false
	sprite.play("die")
	await sprite.animation_finished
	shadow.hide()
	await get_tree().create_timer(0.5).timeout
	Events.lose.emit()
	#alive()

#Жизнь :) В проекте не используется, но выглядит прикольно
func alive()-> void:
	sprite.play_backwards("die")
	await sprite.animation_finished
	shadow.show()
	hp = 2
	is_active = true

#чтобы каждый раз не создавать новый tween, но при этом удалять старый
func get_tween()-> Tween:
	if (_tween):
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween
