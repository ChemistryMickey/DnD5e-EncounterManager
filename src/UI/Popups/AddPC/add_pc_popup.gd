extends Window

func _ready():
	if Signals.connect("show_add_pc", _reveal): print("Unable to connect to show_add_pc!")
	var all_classes = DatabaseLoader.json_dicts["spells-by-class"].keys()
	for class_ in all_classes:
		$VBoxContainer/Class.add_item(class_)
	
	var all_spells = []
	for spell in DatabaseLoader.json_dicts["spell-descriptions"].keys():
		all_spells.append(spell)
	all_spells.sort()
	for spell in all_spells:
		$VBoxContainer/Spells/Available.add_item(spell)

func _clear_fields():
	Utilities.recursive_clear_lineedits(self.get_children())

func _reveal():
	self.visible = true

func _on_close_requested():
	_clear_fields()
	self.visible = false

func _on_cancel_pressed():
	_clear_fields()
	self.visible = false
