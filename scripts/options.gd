extends VBoxContainer

signal back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VolumeSlider.value = Global.volume

func _on_volume_slider_value_changed(value: float) -> void:
		# Volume érték változtató (global.gd)
	Global.volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_toggle_fullscreen_pressed() -> void:
		# Toggle Fullscreen
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_back_pressed() -> void:
	back.emit()
