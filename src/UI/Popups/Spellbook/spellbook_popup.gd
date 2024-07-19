extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	if Signals.connect("show_spellbook", Callable(self, "toggle_self")): print("Unable to connect to show_spellbook!")
	if Signals.connect("update_spellbook", Callable(self, "update_lists")): print("Unable to connect to update_spellbook!")
	update_lists()

func update_lists():
	$"HBoxContainer/TabBar/By Class/ItemList".clear()
	$"HBoxContainer/TabBar/All Spells/ItemList".clear()
	prepare_alphabet_spell_list(DatabaseLoader.json_dicts["spell-descriptions"])
	prepare_by_class_list(DatabaseLoader.json_dicts["spells-by-class"])

func prepare_alphabet_spell_list(all_spells : Dictionary):
	var all_spell_list = []
	for spell in all_spells.keys():
		all_spell_list.append(spell)
	all_spell_list.sort()
	for spell in all_spell_list:
		$"HBoxContainer/TabBar/All Spells/ItemList".add_item(spell)
		
func prepare_by_class_list(all_spells : Dictionary):
	for class_choice in all_spells:
		$"HBoxContainer/TabBar/By Class/ItemList".add_item("================ %s" % class_choice, null, false)
		for spell_level in all_spells[class_choice]:
			$"HBoxContainer/TabBar/By Class/ItemList".add_item("------------- %s" % spell_level, null, false)
			for spell in all_spells[class_choice][spell_level]:
				$"HBoxContainer/TabBar/By Class/ItemList".add_item(spell)

func toggle_self():
	self.visible = Utilities.XOR(self.visible, true);

func _on_close_requested():
	self.visible = false;

func _on_all_spells_item_activated(index: int):
	var spell_name = $"HBoxContainer/TabBar/All Spells/ItemList".get_item_text(index)
	_update_spell_info(spell_name)

func _on_by_class_item_activated(index: int):
	var spell_name = $"HBoxContainer/TabBar/By Class/ItemList".get_item_text(index)
	_update_spell_info(spell_name)
	
func _update_spell_info(spell_name: String):
	if !DatabaseLoader.json_dicts["spell-descriptions"].has(spell_name):
		return
		
	var spell_conts = DatabaseLoader.json_dicts["spell-descriptions"][spell_name]
	
	$HBoxContainer/Info/Name.text = spell_name
	$HBoxContainer/Info/Level.text = spell_conts["Level"]
	$HBoxContainer/Info/School.text = spell_conts["School"]
	$HBoxContainer/Info/Ritual.button_pressed = spell_conts["Is Ritual?"]
	$"HBoxContainer/Info/Casting Time".text = spell_conts["Casting Time"]
	$HBoxContainer/Info/Range.text = spell_conts["Range"]
	$HBoxContainer/Info/Components.text = spell_conts["Components"]
	$HBoxContainer/Info/Duration.text = spell_conts["Duration"]
	$HBoxContainer/Info/Description.text = spell_conts["Description"]

func _on_add_spell_pressed():
	$AddSpell.visible = true

func _on_add_spell_close_requested():
	$AddSpell.visible = false

func _on_remove_spell_pressed():
	var selected_spell: String
	var item_list: ItemList
	if $"HBoxContainer/TabBar/All Spells".visible:
		item_list = $"HBoxContainer/TabBar/All Spells/ItemList"
	elif $"HBoxContainer/TabBar/By Class".visible:
		item_list = $"HBoxContainer/TabBar/By Class/ItemList"
		
	var selected: PackedInt32Array = item_list.get_selected_items()
	if selected.is_empty():
		return
	selected_spell = item_list.get_item_text(selected[0])
	
	if DatabaseLoader.base_jsons["spell-descriptions"].has(selected_spell):
		$RemoveSpellError.visible = true
		return
	
	$RemoveSpellConfirm.visible = true
	$RemoveSpellConfirm.dialog_text = "Are you sure you want to remove %s?" % selected_spell
	await $RemoveSpellConfirm.confirmed
	
	DatabaseLoader.custom_jsons["spell-descriptions"].erase(selected_spell)
	DatabaseLoader.output_custom_jsons()
	DatabaseLoader.load_databases()
	update_lists()
