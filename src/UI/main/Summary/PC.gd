class_name PC_line extends ColorRect

@export var maxHP = 100
var default_color = Color(1, 1, 1, 0)
var bloodied = Color(1, 0.5, 0.5, 0)

func save() -> Dictionary:
	return {
		"Name": $Info/b/b1/Name.text,
		"MaxHP": $Info/b/b1/c1/HP.max_value,
		"AC": $Info/b/b2/AC.text,
		"Passive Perception": $Info/b/b2/PP.text,
		"Speed": {
			"Walking": $Info/b/b2/Speeds/Walk,
			"Climbing": $Info/b/b2/Speeds/Climb,
			"Swimming": $Info/b/b2/Speeds/Swim,
			"Flying": $Info/b/b2/Speeds/Fly
		},
		"Tooltip": $Info/b/b1/Name.tooltip_text
	}
	
func load_(dict: Dictionary) -> void:
	$Info/b/b1/Name.text = dict["Name"]
	$Info/b/b1/c1/HP.max_value = int(dict["MaxHP"])
	$Info/b/b1/c1/HP.suffix = "/%s" % dict["MaxHP"]
	$Info/b/b2/AC.text = dict["AC"]
	$Info/b/b2/PP.text = dict["Passive Perception"]
	
	$Info/b/b2/Speeds/Walk.text = dict["Speed"]["Walking"]
	$Info/b/b2/Speeds/Climb.text = dict["Speed"]["Climbing"]
	$Info/b/b2/Speeds/Swim.text = dict["Speed"]["Swimming"]
	$Info/b/b2/Speeds/Fly.text = dict["Speed"]["Flying"]
	
	$Info/b/b1/Name.tooltip_text = dict["Tooltip"]

func from_pc_dict(pc_dict: Dictionary) -> void:
	$Info/b/b1/Name.text = pc_dict["Name"]
	$Info/b/b1/c1/HP.max_value = int(pc_dict["MaxHP"])
	$Info/b/b1/c1/HP.suffix = "/%s" % pc_dict["MaxHP"]
	$Info/b/b2/AC.text = pc_dict["AC"]
	$Info/b/b2/PP.text = pc_dict["Passive Perception"]
	
	$Info/b/b2/Speeds/Walk.text = pc_dict["Speed"]["Walking"]
	$Info/b/b2/Speeds/Climb.text = pc_dict["Speed"]["Climbing"]
	$Info/b/b2/Speeds/Swim.text = pc_dict["Speed"]["Swimming"]
	$Info/b/b2/Speeds/Fly.text = pc_dict["Speed"]["Flying"]
	
	$Info/b/b1/Name.tooltip_text += "STR: %s, DEX: %s, CON: %s\n" % [pc_dict["Saves"]["STR"], pc_dict["Saves"]["DEX"], pc_dict["Saves"]["CON"]]
	$Info/b/b1/Name.tooltip_text += "INT: %s, WIS: %s, CHA: %s\n" % [pc_dict["Saves"]["INT"], pc_dict["Saves"]["WIS"], pc_dict["Saves"]["CHA"]]
	$Info/b/b1/Name.tooltip_text += "----------- Spells:\n"
	for spell in pc_dict["Spells"]:
		$Info/b/b1/Name.tooltip_text += "%s\n" % spell
		
func _ready():
	self.color = default_color

func _on_selected_toggled(toggled_on):
	if toggled_on:
		self.color.a = 0.3
		default_color.a = 0.3
		bloodied.a = 0.3
	else:
		self.color.a = 0
		default_color.a = 0
		bloodied.a = 0
		
func _on_hp_value_changed(value):
	if value <= 0:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(0, 0, 0))
		self.color = default_color
	elif value <= ($Info/b/b1/c1/HP.max_value/2):
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
		self.color = bloodied
	else:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 1, 1))
		self.color = default_color
