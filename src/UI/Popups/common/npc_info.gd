extends ScrollContainer

func _ready():
	populate_spells()

func populate_spells():
	$b/Spells/InSpellbook.clear()
	var all_spells = []
	for spell in DatabaseManager.json_dicts["spell-descriptions"].keys():
		all_spells.append(spell)
	all_spells.sort()
	for spell in all_spells:
		$b/Spells/Available.add_item(spell)

func clear():
	Utilities.recursive_clear_text(self.get_children())
	Utilities.recursive_clear_spinbox(self.get_children())
	_set_spell_slot_prefixes()
	populate_spells()

func _set_spell_slot_prefixes():
	var i = 0
	for spell_spin in $b/SpellSlots.get_children():
		spell_spin.prefix = "%s: " % HardParams.SPELL_SLOT_NAMES[i]
		i += 1

func _on_add_spell_pressed():
	# Remove it from the available spells list
	var selected_items: PackedInt32Array = $b/Spells/Available.get_selected_items()
	if selected_items.is_empty():
		return
	
	var selected_ind = selected_items[0]
	var selected_spell = $b/Spells/Available.get_item_text(selected_ind)
	$b/Spells/Available.remove_item(selected_ind)
	
	# Add it to the InSpellBook list
	$b/Spells/InSpellbook.add_item(selected_spell)
	
	# Sort InSpellBook
	$b/Spells/InSpellbook.sort_items_by_text()

func _on_remove_spell_pressed():
	# Remove it from the InSpellBook list
	var selected_items: PackedInt32Array = $b/Spells/InSpellbook.get_selected_items()
	if selected_items.is_empty():
		return
	
	var selected_ind = selected_items[0]
	var selected_spell = $b/Spells/InSpellbook.get_item_text(selected_ind)
	$b/Spells/InSpellbook.remove_item(selected_ind)
	
	# Add it to the Available list
	$b/Spells/Available.add_item(selected_spell)
	
	# Sort Available
	$b/Spells/Available.sort_items_by_text()

func save() -> Dictionary:
	var mutable_dict: Dictionary = {}
	Utilities.recursive_construct_savable_child_dict(self.get_children(), mutable_dict, self.name)
	
	# Strip out unnecessary strings in keys
	for key: String in mutable_dict.keys():
		var new_key = "/".join(key.split("/").slice(1))
		var info = mutable_dict[key]
		mutable_dict.erase(key)
		mutable_dict[new_key] = info
	
	# Get spells (don't want to do this as part of recursive construct dict)
	var spells = []
	for ind in range($b/Spells/InSpellbook.item_count):
		spells.append($b/Spells/InSpellbook.get_item_text(ind))
	mutable_dict["Spells/InSpellbook"] = spells
	
	# Specifically handle max values for spell slots
	for i in range(1, 10):
		mutable_dict["SpellSlots/%d" % i]["max value"] = get_node("b/SpellSlots/%d" % i).value

	if mutable_dict["Name"] == "":
		return {}
		
	return mutable_dict

func load_(dict: Dictionary) -> void:
	populate_spells()
	for key in dict.keys():
		var node_up = get_node("b/%s" % key)
		if !node_up:
			continue
			
		if node_up is LineEdit or node_up is TextEdit:
			node_up.text = dict[key]
		elif node_up is SpinBox:
			node_up.set_value_no_signal(dict[key]["value"])
		
		if key == "Spells/InSpellbook":
			for spell in dict[key]:
				$b/Spells/InSpellbook.add_item(spell)
				
				for ind in range($b/Spells/Available.item_count):
					if $b/Spells/Available.get_item_text(ind) == spell:
						$b/Spells/Available.remove_item(ind)
						break
