extends Window

func clear():
	$vb/StatusInfo/StatusName.text = ""
	$vb/StatusInfo/Turns.value = -1
	$vb/StatusInfo/AutoUpdate.button_pressed = false

func _on_cancel_pressed():
	self.move_to_center()
	self.visible = false
