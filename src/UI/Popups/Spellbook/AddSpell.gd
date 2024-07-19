extends Window

func _on_add_pressed():
	var spell_name = $Info/Name.text
	if spell_name == "":
		$WarningDialog.visible = true
		$WarningDialog.title = "Add Spell Error"
		$WarningDialog.dialog_text = "Spell name cannot be empty!"
		_clear_fields()
		return
	
	var data = {
		"Level": $Info/Level.text,
		"School": $Info/School.text,
		"Is Ritual?": $Info/Ritual.button_pressed,
		"Casting Time": $"Info/Casting Time".text,
		"Range": $Info/Range.text,
		"Components": $Info/Components.text,
		"Duration": $Info/Duration.text,
		"Description": $Info/Description.text
	}
	for key in data.keys():
		if data[key] is String:
			if data[key] == "":
				$WarningDialog.visible = true
				$WarningDialog.title = "Add Spell Error"
				$WarningDialog.dialog_text = "%s cannot be empty!" % key
				return
	
	if DatabaseLoader.base_jsons["spell-descriptions"].has(spell_name):
		$ConfirmationDialog.visible = true
		$ConfirmationDialog.title = "Overshadow base spell?"
		$ConfirmationDialog.dialog_text = "Spell already exists in base DnD5e!\n" + \
							"Would you like to add this anyways and overshadow the base definition?"

		await $ConfirmationDialog.confirmed
		
	if DatabaseLoader.custom_jsons["spell-descriptions"].has(spell_name):
		$ConfirmationDialog.visible = true
		$ConfirmationDialog.title = "Overwrite custom spell?"
		$ConfirmationDialog.dialog_text = "Spell already exists in custom database!\n" + \
							"Would you like to overwrite the existing definition?"
		await $ConfirmationDialog.confirmed
		
	DatabaseLoader.custom_jsons["spell-descriptions"][spell_name] = data
	DatabaseLoader.output_custom_jsons()
	DatabaseLoader.load_databases()
	_clear_fields()
	self.visible = false
	
	Signals.emit_signal("update_spellbook")

func _on_cancel_pressed():
	_clear_fields()
	self.visible = false

func _clear_fields():
	$Info/Name.text = ""
	$Info/Level.text = ""
	$Info/School.text = ""
	$Info/Ritual.button_pressed = false
	$"Info/Casting Time".text = ""
	$Info/Range.text = ""
	$Info/Components.text = ""
	$Info/Duration.text = ""
	$Info/Description.text = ""


