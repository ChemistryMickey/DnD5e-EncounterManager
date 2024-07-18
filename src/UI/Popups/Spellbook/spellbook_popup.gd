extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.connect("show_spellbook", self.toggle_self)
	

func toggle_self():
	self.visible = Utilities.XOR(self.visible, true);

func _on_close_requested():
	self.visible = false;
