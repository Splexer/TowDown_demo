extends CanvasLayer

@onready var no_saves_panel : Panel = $No_saves_panel

func _ready() -> void:
	Events.bad_save_file.connect(_bad_save_handler)

func _on_new_game_btn_pressed() -> void:
	Events.load_new_level.emit()


func _on_load_game_btn_pressed() -> void:
	Events.load_save_level.emit()


func _on_exit_btn_pressed() -> void:
	get_tree().quit()

func _bad_save_handler()-> void:
	no_saves_panel.show()
	await get_tree().create_timer(1.5).timeout
	no_saves_panel.hide()
	
