extends Window

func _on_close_requested():
	self.move_to_center()
	self.visible = false
