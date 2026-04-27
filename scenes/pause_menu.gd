extends Control

var pause_toggle = false
@onready var hud = $"../Head/Camera3D/CanvasLayer/HUD"   # путь может отличаться

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_and_unpause()

func pause_and_unpause():
	pause_toggle = !pause_toggle
	get_tree().paused = pause_toggle
	
	visible = pause_toggle
	hud.visible = !pause_toggle   # ← вот это скрывает HUD
	
	if pause_toggle:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

########


func _on_resume_button_mouse_entered() -> void:
	$VBoxContainer/Hover.play()


func _on_restart_button_mouse_entered() -> void:

	$VBoxContainer/Hover.play()
func _on_quit_button_mouse_entered() -> void:
	$VBoxContainer/Hover.play()



func _on_resume_button_pressed() -> void:
	$VBoxContainer/Click.play()
	pause_and_unpause()


func _on_restart_button_pressed() -> void:
	$VBoxContainer/Click.play()
	pause_and_unpause()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	$VBoxContainer/Click.play()
	get_tree().quit()
