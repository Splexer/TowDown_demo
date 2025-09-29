extends Area2D

@onready var collider : CollisionShape2D = $CollisionShape2D
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collider.set_deferred("disabled", true)
		sprite.play("pick_up")
		#Events.pick_up_coin.emit()
		await sprite.animation_finished
		sprite.hide()
		queue_free()
