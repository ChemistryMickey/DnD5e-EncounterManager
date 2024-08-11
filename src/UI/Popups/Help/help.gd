extends Window

func _ready():
	$TabContainer/Base.text += "\n\n Version: %s" % HardParams.VERSION

func _on_close_requested():
	self.move_to_center()
	self.visible = false
