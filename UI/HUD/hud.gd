extends CanvasLayer

signal confirmed
var confirm : bool = false

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
@onready var confirmation_menu : MarginContainer = $Confirmation_menu
@onready var confirm_btn : Button = $Confirmation_menu/VBoxContainer/HBoxContainer/Confirm_btn
@onready var cancel_btn : Button = $Confirmation_menu/VBoxContainer/HBoxContainer/Cancel_btn
@onready var confirmation_title : Label = $Confirmation_menu/VBoxContainer/Label

func _ready() -> void:
	Events.hud_hp_update.connect(_update_hp_bar)
	Events.save_succes.connect(_succes_saving_handler)
	Events.bad_save_file.connect(_bad_save_handler)
	Events.hud_coins_update.connect(_update_collected_coins)
	Events.win.connect(_show_win_menu)
	Events.lose.connect(_show_lose_menu)
	_update_collected_coins()

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
	
func _update_collected_coins()-> void:
	coin_requeired.text = "/ " + str(Global.required_coins)
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
	_show_confirmation_menu()
	await confirmed
	if confirm:
		confirm = false
		get_tree().paused = false
		Events.load_new_level.emit()
	else:
		confirmation_menu.hide()
func _on_load_btn_pressed() -> void:
	Events.load_save_level.emit()
func _on_save_btn_pressed() -> void:
	Events.save_level.emit()
func _on_menu_btn_pressed() -> void:
	_show_confirmation_menu()
	await confirmed
	if confirm:
		confirm = false
		_hide_pause_menu()
		Events.load_Main_menu.emit()
	else:
		confirmation_menu.hide()


func _on_cancel_btn_pressed() -> void:
	confirm = false
	confirmed.emit()
func _on_confirm_btn_pressed() -> void:
	confirm = true
	confirmed.emit()
func _show_confirmation_menu() -> void:
	cancel_btn.show()
	confirm_btn.show()
	confirmation_title.text = "Are you sure?"
	confirmation_menu.show()
func _bad_save_handler()-> void:
	cancel_btn.hide()
	confirm_btn.hide()
	confirmation_title.text = "You dont have a save"
	confirmation_menu.show()
	await get_tree().create_timer(1.5).timeout
	confirmation_menu.hide()
func _succes_saving_handler()-> void:
	cancel_btn.hide()
	confirm_btn.hide()
	confirmation_title.text = "Game saved successfully"
	confirmation_menu.show()
	await get_tree().create_timer(1.5).timeout
	confirmation_menu.hide()
	
