extends CanvasLayer

@onready var coin_collected : Label = $Coin_Bar/HBoxContainer/coin_collected_label
@onready var coin_requeired : Label = $Coin_Bar/HBoxContainer/coin_requeired_label
@onready var heart_cointainer : HBoxContainer = $HP_Bar/HBoxContainer

@onready var pause_menu : MarginContainer = $Pause_menu
@onready var pause_title : Label = $Pause_menu/VBoxContainer/Menu_title
@onready var resume_btn : Button = $Pause_menu/VBoxContainer/Resume_btn
@onready var restart_btn : Button = $Pause_menu/VBoxContainer/Restart_btn
@onready var load_btn : Button = $Pause_menu/VBoxContainer/Load_btn
@onready var save_btn : Button = $Pause_menu/VBoxContainer/Save_btn
@onready var menu_btn : Button = $Pause_menu/VBoxContainer/Menu_btn
@onready var pause_btn : TextureButton = $Pause/Pause_btn

func _ready() -> void:
	Events.player_take_damage.connect(_update_hp_bar)
	Events.pick_up_coin.connect(_update_collected_coins)
	_update()

#Одно меню, используется в разных ситуациях. Функция для каждого варианта	
func _show_win_menu()-> void:
	get_tree().paused = true
	pause_title.text = "YOU WIN!"
	resume_btn.hide()
	save_btn.hide()
	pause_menu.show()
func _show_lose_menu()-> void:
	get_tree().paused = true
	pause_title.text = "YOU LOSE!"
	resume_btn.hide()
	save_btn.hide()
	pause_menu.show()
func _show_pause_menu()-> void:
	get_tree().paused = true
	pause_title.text = "Pause"
	resume_btn.show()
	save_btn.show()
	pause_menu.show()

func _hide_pause_menu()-> void:
	pause_menu.hide()
	get_tree().paused = false
	
func _update(hp : int = Global.player_hp)-> void:
	coin_requeired.text = "/ " + str(Global.required_coins)
	_update_collected_coins()
	_update_hp_bar(hp)
func _update_collected_coins()-> void:
	coin_collected.text = str(Global.collected_coins)
func _update_hp_bar(hp: int)-> void:
	for i in heart_cointainer.get_child_count():
		heart_cointainer.get_child(i).visible = hp > i

#Кнопка паузы в углу
func _on_pause_btn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		_show_pause_menu()
	else:
		_hide_pause_menu()
#Кнопки меню паузы	
func _on_resume_btn_pressed() -> void:
	_hide_pause_menu()
	pause_btn.button_pressed = false
func _on_restart_btn_pressed() -> void:
	pass # Replace with function body.
func _on_load_btn_pressed() -> void:
	pass # Replace with function body.
func _on_save_btn_pressed() -> void:
	pass # Replace with function body.
func _on_menu_btn_pressed() -> void:
	pass # Replace with function body.
