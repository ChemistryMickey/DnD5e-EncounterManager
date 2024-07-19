extends Window

func _ready():
	if Signals.connect("show_add_pc", _reveal): print("Unable to connect to show_add_pc!")
	var all_classes = DatabaseLoader.json_dicts["spells-by-class"].keys()
	for class_ in all_classes:
		$VBoxContainer/Class.add_item(class_)

func _reveal():
	self.visible = true

func _on_close_requested():
	self.visible = false
