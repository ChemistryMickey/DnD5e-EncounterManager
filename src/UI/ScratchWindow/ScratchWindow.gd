extends Window

func _ready():
	Signals.connect("show_notes", self.toggle_self)

func toggle_self():
	self.visible = Utilities.XOR(self.visible, true);

func _on_close_requested():
	self.visible = false
