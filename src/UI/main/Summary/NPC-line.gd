class_name NPC_line extends ColorRect

var status_template = preload("res://src/UI/main/Summary/status.tscn")

@export var bloodied: bool = false
@export var selected: bool = false
@export var initiative: int = 0
@export var actor_name: String = ""
@export var spell_slots: Dictionary = {}

var previous_color: Color = HardParams.SELECTED

func _ready():
	self.color = HardParams.SELECTED
	self.color.a = 0
	
func set_new_color(color_in: Color, alpha: float = -1) -> void:
	self.previous_color = self.color
	self.color = color_in
	if alpha != -1:
		self.color.a = alpha
	
	return

func reset_color() -> void:
	self.color = self.previous_color
	
	return
	
func reset_action_economy():
	for button in $Info/b/b1/Actions.get_children():
		if button is CheckButton:
			button.button_pressed = false


func decrement_statuses():
	for status in $Info/StatusRect/StatusScroll/Statuses.get_children():
		if status.auto_update:
			status.decrement()

func trip_action() -> bool:
	if $Info/b/b1/Actions/Action.button_pressed:
		return false
	$Info/b/b1/Actions/Action.button_pressed = true
	return true

func trip_bonus_action() -> bool:
	if $Info/b/b1/Actions/Bonus.button_pressed:
		return false
	$Info/b/b1/Actions/Bonus.button_pressed = true
	return true
	
func trip_reaction() -> bool:
	if $Info/b/b1/Actions/Reaction.button_pressed:
		return false
	$Info/b/b1/Actions/Reaction.button_pressed = true
	return true

func _on_selected_toggled(toggled_on):
	selected = toggled_on
	if toggled_on:
		self.color.a = HardParams.SELECTED_TRANSPARENCY
		self.previous_color = HardParams.SELECTED
	elif self.color == HardParams.ENCOUNTER_SELECTED:
		self.previous_color = HardParams.SELECTED
		return
	else:
		self.color.a = 0
		
func _on_hp_value_changed(value):
	if value <= 0:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(0, 0, 0))
		self.color = HardParams.SELECTED
		bloodied = false # technically not bloodied
		$Info/b/b2/StatusColor.color = Color(0, 0, 0)
	elif value <= ($Info/b/b1/c1/HP.max_value/2):
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 0.2, 0.1))
		self.color = HardParams.BLOODIED
		bloodied = true
		$Info/b/b2/StatusColor.color = Color(1, 0, 0)
	else:
		$Info/b/b1/Name.add_theme_color_override("font_color", Color(1, 1, 1))
		self.color = HardParams.SELECTED
		bloodied = false
		$Info/b/b2/StatusColor.color = Color(1, 1, 1)

func save() -> Dictionary:
	var statuses = []
	for status in $Info/StatusRect/StatusScroll/Statuses.get_children():
		statuses.append(status.save())
		
	return {
		"Type": "NPC_line",
		"Name": $Info/b/b1/Name.text,
		"Initiative": $Info/b/b2/Initiative.value,
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
		"Status Effects": statuses,
		"Spell Slots": spell_slots
	}
	
func load_(dict: Dictionary) -> void:
	$Info/b/b1/Name.text = dict["Name"]
	$Info/b/b1/c1/HP.value = int(dict["Current HP"])
	$Info/b/b1/c1/HP.max_value = int(dict["MaxHP"])
	$Info/b/b1/c1/HP.suffix = "/%s" % dict["MaxHP"]
	_on_hp_value_changed($Info/b/b1/c1/HP.value)
	
	$Info/b/b2/AC.text = dict["AC"]
	$Info/b/b2/PP.text = dict["Passive Perception"]
	$Info/b/b2/Initiative.value = dict["Initiative"]
	
	$Info/b/b2/Speeds/Walk.text = dict["Speed"]["Walking"]
	$Info/b/b2/Speeds/Climb.text = dict["Speed"]["Climbing"]
	$Info/b/b2/Speeds/Swim.text = dict["Speed"]["Swimming"]
	$Info/b/b2/Speeds/Fly.text = dict["Speed"]["Flying"]
	
	for status in dict["Status Effects"]:
		var new_status = status_template.instantiate()
		new_status.load_(status)
		
		$Info/StatusRect/StatusScroll/Statuses.add_child(new_status)
		
	actor_name = $Info/b/b1/Name.text
	spell_slots = dict["Spell Slots"]
	initiative = dict["Initiative"]

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
	
	actor_name = npc_dict["Name"]
	var spells_str = ", ".join(npc_dict["Spells/InSpellbook"])
	spells_str = Utilities.replace_every_nth_chr(spells_str, ",", "\n", 4)
	for i in range(1, 10):
		spell_slots["%d" % i] = {
			"value": npc_dict["SpellSlots/%d" % i]["value"],
			"max value": npc_dict["SpellSlots/%d" % i]["max value"]
		}


func _on_initiative_text_changed(new_text: String):
	if !new_text.is_valid_int():
		initiative = 0
		return
	initiative = int(new_text)

func _on_add_status_pressed():
	$AddStatusEffectPopup.visible = true

func _on_add_status_effect_popup_close_requested():
	$AddStatusEffectPopup.visible = false
	$AddStatusEffectPopup.move_to_center()

func _on_add_status_from_popup_pressed():
	var new_status = status_template.instantiate()
	new_status.set_properties(
		$AddStatusEffectPopup/vb/StatusInfo/StatusName.text, 
		$AddStatusEffectPopup/vb/StatusInfo/Turns.value,
		$AddStatusEffectPopup/vb/StatusInfo/AutoUpdate.button_pressed
	)
	$Info/StatusRect/StatusScroll/Statuses.add_child(new_status)
	$AddStatusEffectPopup.clear()
	_on_add_status_effect_popup_close_requested()
