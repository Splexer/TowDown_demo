extends Area2D

@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

#Вся логика монетки, если в нас вошёл игрок, то отключаем коллайдер, анимация взятия
#И когда она закончится пускаем сигнал что подобрали монетку
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collider.set_deferred("disabled", true)
		sprite.play("pick_up")
		await sprite.animation_finished
		sprite.hide()
		Events.pick_up_coin.emit()
		queue_free()
