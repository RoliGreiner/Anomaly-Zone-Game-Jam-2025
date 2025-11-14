extends VBoxContainer

signal start_game
signal settings

func _on_start_pressed() -> void:
	start_game.emit()

func _on_options_pressed() -> void:
	settings.emit()

func _on_exit_pressed() -> void:
	get_tree().quit()
