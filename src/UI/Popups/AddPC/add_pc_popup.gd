extends Window

func _ready():
	if Signals.connect("show_add_PC", _reveal): print("Unable to connect to show_add_pc!")

func _clear_fields():
	$VBoxContainer/PCInfo.clear()

func _reveal():
	self.visible = true

func _on_close_requested():
	_clear_fields()
	self.move_to_center()
	self.visible = false

func _on_cancel_pressed():
	_clear_fields()
	self.visible = false

func _on_add_spell_pressed():
	# Remove it from the available spells list
	var selected_items: PackedInt32Array = $VBoxContainer/PCInfo/Spells/Available.get_selected_items()
	if selected_items.is_empty():
		return
	
	var selected_ind = selected_items[0]
	var selected_spell = $VBoxContainer/PCInfo/Spells/Available.get_item_text(selected_ind)
	$VBoxContainer/PCInfo/Spells/Available.remove_item(selected_ind)
	
	# Add it to the InSpellBook list
	$VBoxContainer/PCInfo/Spells/InSpellbook.add_item(selected_spell)
	
	# Sort InSpellBook
	$VBoxContainer/PCInfo/Spells/InSpellbook.sort_items_by_text()

func _on_remove_spell_pressed():
	# Remove it from the InSpellBook list
	var selected_items: PackedInt32Array = $VBoxContainer/PCInfo/Spells/InSpellbook.get_selected_items()
	if selected_items.is_empty():
		return
	
	var selected_ind = selected_items[0]
	var selected_spell = $VBoxContainer/PCInfo/Spells/InSpellbook.get_item_text(selected_ind)
	$VBoxContainer/PCInfo/Spells/InSpellbook.remove_item(selected_ind)
	
	# Add it to the Available list
	$VBoxContainer/PCInfo/Spells/Available.add_item(selected_spell)
	
	# Sort Available
	$VBoxContainer/PCInfo/Spells/Available.sort_items_by_text()

func _on_save_pressed():
	var pc = $VBoxContainer/PCInfo.to_dict()
	
	# Sanitize
	for val in pc.values():
		if val is String:
			if val == "":
				$AcceptDialog.visible = true
				$AcceptDialog.dialog_text = "Unable to save character with missing values!\n"
				$AcceptDialog.dialog_text += "Only able to omit saves, spells, and movement speed"
				return
	
	# Add to database
	DatabaseManager.add_pc(pc)
	Signals.emit_signal("update_PCs")
	
	_clear_fields()
	self.visible = false
