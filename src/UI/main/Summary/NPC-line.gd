class_name NPC_line extends ColorRect

var status_template = preload("res://src/UI/main/Summary/status.tscn")

@export var bloodied: bool = false
@export var selected: bool = false
@export var initiative: int = 0

var default_color = Color(1, 1, 1, 0)
var bloodied_color = Color(1, 0.5, 0.5, 0)

func _ready():
	self.color = default_color

func reset_action_economy():
	for button in $Info/b/b1/Actions.get_children():
		if button is CheckButton:
			button.toggle_mode = false

func _on_selected_toggled(toggled_on):
	selected = toggled_on
	if toggled_on:
		self.color.a = 0.3
		default_color.a = 0.3
		bloodied_color.a = 0.3
	else:
		self.color.a = 0
		default_color.a = 0
		bloodied_color.a = 0
		
func _on_hp_value_changed(value):
	if value <= 0:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(0, 0, 0))
		self.color = default_color
		bloodied = false # technically not bloodied
		$Info/b/b2/StatusColor.color = Color(0, 0, 0)
	elif value <= ($Info/b/b1/c1/HP.max_value/2):
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
		self.color = bloodied_color
		bloodied = true
		$Info/b/b2/StatusColor.color = Color(1, 0, 0)
	else:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 1, 1))
		self.color = default_color
		bloodied = false
		$Info/b/b2/StatusColor.color = Color(1, 1, 1)

func save() -> Dictionary:
	var statuses = []
	for status in $Info/StatusRect/StatusScroll/Statuses.get_children():
		statuses.append(status.save())
		
	return {
		"Type": "PC_line",
		"Name": $Info/b/b1/Name.text,
		"Initiative": $Info/b/b2/Initiative.text,
		"Current HP": $Info/b/b1/c1/HP.value,
		"MaxHP": $Info/b/b1/c1/HP.max_value,
		"AC": $Info/b/b2/AC.text,
		"Passive Perception": $Info/b/b2/PP.text,
		"Speed": {
			"Walking": $Info/b/b2/Speeds/Walk.text,
			"Climbing": $Info/b/b2/Speeds/Climb.text,
			"Swimming": $Info/b/b2/Speeds/Swim.text,
			"Flying": $Info/b/b2/Speeds/Fly.text
		},
		"Tooltip": $Info/b/b1/Name.tooltip_text,
		"Status Effects": statuses
	}
	
func load_(dict: Dictionary) -> void:
	$Info/b/b1/Name.text = dict["Name"]
	$Info/b/b1/c1/HP.value = int(dict["Current HP"])
	$Info/b/b1/c1/HP.max_value = int(dict["MaxHP"])
	$Info/b/b1/c1/HP.suffix = "/%s" % dict["MaxHP"]
	_on_hp_value_changed($Info/b/b1/c1/HP.value)
	
	$Info/b/b2/AC.text = dict["AC"]
	$Info/b/b2/PP.text = dict["Passive Perception"]
	$Info/b/b2/Initiative.text = int(dict["Initiative"])
	
	$Info/b/b2/Speeds/Walk.text = dict["Speed"]["Walking"]
	$Info/b/b2/Speeds/Climb.text = dict["Speed"]["Climbing"]
	$Info/b/b2/Speeds/Swim.text = dict["Speed"]["Swimming"]
	$Info/b/b2/Speeds/Fly.text = dict["Speed"]["Flying"]
	
	$Info/b/b1/Name.tooltip_text = dict["Tooltip"]
	
	for status in dict["Status Effects"]:
		var new_status = status_template.instantiate()
		new_status.load_(status)
		
		$Info/StatusRect/StatusScroll/Statuses.add_child(new_status)

func from_npc_dict(npc_dict: Dictionary) -> void:
	$Info/b/b1/Name.text = npc_dict["Name"]
	$Info/b/b1/c1/HP.value = int(npc_dict["Stats/MaxHP"])
	$Info/b/b1/c1/HP.max_value = int(npc_dict["Stats/MaxHP"])
	$Info/b/b1/c1/HP.suffix = "/%s" % npc_dict["Stats/MaxHP"]
	$Info/b/b2/AC.text = npc_dict["Stats/AC"]
	$Info/b/b2/PP.text = npc_dict["Stats/PassivePerception"]
	
	$Info/b/b2/Speeds/Walk.text = npc_dict["Movement/Walk"]
	$Info/b/b2/Speeds/Climb.text = npc_dict["Movement/Climb"]
	$Info/b/b2/Speeds/Swim.text = npc_dict["Movement/Swim"]
	$Info/b/b2/Speeds/Fly.text = npc_dict["Movement/Fly"]
	
	var tooltip_str: String = \
	"""
	STR: {STR}, DEX: {DEX}, CON: {CON}
	INT: {INT}, WIS: {WIS}, CHA: {CHA}
	----------- Spells:
	{spells}
	""".format(
		{
			"STR": npc_dict["Saves/STR"],
			"DEX": npc_dict["Saves/DEX"],
			"CON": npc_dict["Saves/CON"],
			"INT": npc_dict["Saves/INT"],
			"WIS": npc_dict["Saves/WIS"],
			"CHA": npc_dict["Saves/CHA"],
			"spells": "\n".join(npc_dict["Spells/InSpellbook"])
		}
	)
	$Info/b/b1/Name.tooltip_text = tooltip_str
	
	#$Info/b/b1/Name.tooltip_text += "STR: %s, DEX: %s, CON: %s\n" % [npc_dict["Saves"]["STR"], npc_dict["Saves"]["DEX"], npc_dict["Saves"]["CON"]]
	#$Info/b/b1/Name.tooltip_text += "INT: %s, WIS: %s, CHA: %s\n" % [npc_dict["Saves"]["INT"], npc_dict["Saves"]["WIS"], npc_dict["Saves"]["CHA"]]
	#$Info/b/b1/Name.tooltip_text += "----------- Spells:\n"
	#for spell in npc_dict["Spells/InSpellbook"]:
		#$Info/b/b1/Name.tooltip_text += "%s\n" % spell


func _on_initiative_text_changed(new_text: String):
	if !new_text.is_valid_int():
		return
	initiative = int(new_text)
