extends VBoxContainer

func load_(npc_line_dict: Dictionary) -> void:
	clear()

	var full_npc_dict = DatabaseManager.custom_jsons["NPCs"][npc_line_dict["Name"]]
	$Name.text = npc_line_dict["Name"]
	$Resistances.text = full_npc_dict["Resistances"]
	$Immunities.text = full_npc_dict["Immunities"]
	for stat in HardParams.STAT_NAMES:
		get_node("Stats/%s" % stat).text = full_npc_dict["Saves/%s" % stat]
		get_node("SaveThrows/%s" % stat).text = full_npc_dict["SavingThrows/%s" % stat]
	
	for i in range(1, 10):
		get_node("SpellSlots/%d" % i).prefix = "%s Level: " % HardParams.SPELL_SLOT_NAMES[i - 1]
		get_node("SpellSlots/%d" % i).max_value = full_npc_dict["SpellSlots/%d" % i]["max value"]
		get_node("SpellSlots/%d" % i).value = npc_line_dict["Spell Slots"]["%d" % i]["value"]
		get_node("SpellSlots/%d" % i).suffix = "/%d" % full_npc_dict["SpellSlots/%d" % i]["max value"]
	
	for spell in full_npc_dict["Spells/InSpellbook"]:
		$Spells.add_item(spell)
		
	$Senses.text = full_npc_dict["Senses"]
	$Languages.text = full_npc_dict["Languages"]
	$Actions.text = full_npc_dict["Actions"]
	$LegPerRound/LActionsPerRound.text = "%d" % full_npc_dict["LegendaryActions/NumLegActions"]["value"]
	$LegActions.text = full_npc_dict["LegendaryActions/Description"]
	$Reactions.text = full_npc_dict["Reactions"]
	$Misc.text = full_npc_dict["Misc"]

func clear():
	Utilities.recursive_clear_text(self.get_children())
	Utilities.recursive_clear_spinbox(self.get_children())
	$Spells.clear()
