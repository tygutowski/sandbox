extends TextureButton

func _input(event):
	if(get_pressed_texture()):
		print("New World!")
