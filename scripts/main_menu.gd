extends Control

@export_file("*.tscn") var game_scene


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_options_pressed() -> void:
	# Főmenüből Optionsbe
	$Main.visible = false
	$OptionsMenu.visible = true


func _on_button_pressed() -> void:
	# Optionsből Főmenübe
	$OptionsMenu.visible = false
	$Main.visible = true


func _on_toggle_fullscreen_pressed() -> void:
	# Toggle Fullscreen
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_volume_slider_value_changed(value: float) -> void:
	# Volume érték változtató (global.gd)
	Global.volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
