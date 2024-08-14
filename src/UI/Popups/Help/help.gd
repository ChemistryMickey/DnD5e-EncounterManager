extends Window

func _ready():
	$TabContainer/Base.text += "\n\nVersion: %s" % HardParams.VERSION
	$TabContainer/Base.text += "\nAll user custom databases can be found in the following location: \n\t%s" % OS.get_user_data_dir()

func _on_close_requested():
	self.move_to_center()
	self.visible = false
