extends ColorRect

func _on_selected_toggled(toggled_on):
	if toggled_on:
		self.color.a = 0.3
	else:
		self.color.a = 0
