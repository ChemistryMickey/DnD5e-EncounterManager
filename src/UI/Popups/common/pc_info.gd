extends VBoxContainer

func _ready():
	var all_classes = DatabaseManager.json_dicts["spells-by-class"].keys()
	for class_ in all_classes:
		$Class.add_item(class_)
	
	var all_spells = []
	for spell in DatabaseManager.json_dicts["spell-descriptions"].keys():
		all_spells.append(spell)
	all_spells.sort()
	for spell in all_spells:
		$Spells/Available.add_item(spell)

func to_dict() -> Dictionary:
	var spells = []
	for i in range($Spells/InSpellbook.item_count):
		spells.append($Spells/InSpellbook.get_item_text(i))
		
	var pc = {
		"Name": $Name.text, 
		"Class": $Class.get_item_text($Class.get_selected_id()),
		"AC": $Stats/AC.text,
		"MaxHP": $Stats/MaxHP.text,
		"Passive Perception": $Stats/PassivePerception.text,
		"Speed": {
			"Walking": $Movement/Walk.text,
			"Climbing": $Movement/Climb.text,
			"Swimming": $Movement/Swim.text,
			"Flying": $Movement/Fly.text
		},
		"Saves": {
			"STR": $Saves/STR.text,
			"DEX": $Saves/DEX.text,
			"CON": $Saves/CON.text,
			"INT": $Saves/INT.text,
			"WIS": $Saves/WIS.text,
			"CHA": $Saves/CHA.text
		},
		"Spells": spells
	}
	return pc

func load_from_dict(dict: Dictionary) -> void:
	$Name.text = dict["Name"]
	$Stats/AC.text = dict["AC"]
	$Stats/MaxHP.text = dict["MaxHP"]
	$Stats/PassivePerception.text = dict["Passive Perception"]
	$Movement/Walk.text = dict["Speed"]["Walking"]
	$Movement/Climb.text = dict["Speed"]["Climbing"]
	$Movement/Swim.text = dict["Speed"]["Swimming"]
	$Movement/Fly.text = dict["Speed"]["Flying"]
	$Saves/STR.text = dict["Saves"]["STR"]
	$Saves/DEX.text = dict["Saves"]["DEX"]
	$Saves/CON.text = dict["Saves"]["CON"]
	$Saves/INT.text = dict["Saves"]["INT"]
	$Saves/WIS.text = dict["Saves"]["WIS"]
	$Saves/CHA.text = dict["Saves"]["CHA"]
	for spell in dict["Spells"]:
		$Spells/InSpellbook.add_item(spell)
	$Spells/InSpellbook.sort_items_by_text()
