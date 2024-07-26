extends SpinBox

func _ready():
	if Signals.connect("add_new_actor_to_initiative", _increment_max): print("Unable to connect to add_new_actor_to_initiative!")
	Signals.connect("remove_actor_from_initiative", _decrement_max)

func _decrement_max():
	self.max_value -= 1
	_update_suffix()

func _increment_max():
	self.max_value += 1
	_update_suffix()

func _update_suffix():
	self.suffix = "/%d" % self.max_value
