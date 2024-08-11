extends Control

@onready var pc_template = preload("res://src/UI/main/Summary/PC-line.tscn")
@onready var non_actor_template = preload("res://src/UI/main/Summary/non-actor.tscn")
@onready var npc_template = preload("res://src/UI/main/Summary/NPC-line.tscn")

var encounter_started: bool = false

func _ready():
	$vb/TopBar/AddPC.get_popup().index_pressed.connect(_handle_add_pc)
	$vb/TopBar/File.get_popup().index_pressed.connect(_handle_file)
	$vb/TopBar/Edit.get_popup().index_pressed.connect(_handle_edit)
	$vb/TopBar/Options.get_popup().index_pressed.connect(_handle_options)
	$vb/ControlButtons/Sort.get_popup().index_pressed.connect(_handle_sort)
	
	if Signals.connect("update_PCs", _prep_pc_option_button): print("Unable to connect to update_PCs!")
	_prep_pc_option_button()

func save() -> Dictionary:
	return {
		"Current Turn": $vb/ControlButtons/Turn.value,
		"Current Round": $vb/ControlButtons/Round.value,
		"Current Initiative Order" : $vb/InfoOptions/Info/Actors.save(),
		"Version": HardParams.VERSION
	}

func load_sheet(dict: Dictionary) -> void:
	if "Version" not in dict.keys():
		$LoadErrorPopup.dialog_text = "Version not present in sheet dictionary!\nCheck your JSON!"
		$LoadErrorPopup.visible = true
		return
	
	# Check version number
	var loaded_major_version: int = int(dict["Version"].split(".")[0])
	var cur_major_version: int = int(HardParams.VERSION.split(".")[0])
	if loaded_major_version != cur_major_version:
		$LoadErrorPopup.dialog_text = "Unable to load sheet!\nCurrent Version: %s\nSheet Version: %s" % [HardParams.VERSION, dict["Version"]]
		$LoadErrorPopup.visible = true
		return
	
	_zero_counters()
	# This causes the turn max val to go up
	$vb/InfoOptions/Info/Actors.load_sheet(dict)
	
	$vb/ControlButtons/Turn.set_value_no_signal(dict["Current Turn"])
	$vb/ControlButtons/Round.set_value_no_signal(dict["Current Round"])
	
	if dict["Current Round"] > 0:
		encounter_started = false
		_move_turn_indicator()
		_init_encounter()

func _zero_counters():
	$vb/ControlButtons/Turn.min_value = 0
	$vb/ControlButtons/Turn.set_value_no_signal(0)
	
	$vb/ControlButtons/Round.min_value = 0
	$vb/ControlButtons/Round.set_value_no_signal(0)

func _prep_pc_option_button():
	$vb/TopBar/AddPC.get_popup().clear()
	for pc in DatabaseManager.custom_jsons["PCs"].keys():
		$vb/TopBar/AddPC.get_popup().add_item(pc)

func sort_by_init(a, b):
	if a.initiative > b.initiative:
		return true
	return false

func _handle_sort(_ind: int) -> void:
	# Pop off all actor nodes
	var all_actors = []
	for actor in $vb/InfoOptions/Info/Actors.get_children():
		all_actors.append(actor)
		$vb/InfoOptions/Info/Actors.remove_child(actor)
		
	# Sort by initiative
	all_actors.sort_custom(sort_by_init)
	
	# Push on all actor nodes
	for actor in all_actors:
		$vb/InfoOptions/Info/Actors.add_child(actor)

func _handle_options(ind: int) -> void:
	var signal_map = {
		0: "show_notes",
		1: "show_spellbook",
		2: "show_help"
	}
	Signals.emit_signal(signal_map[ind])

func _handle_add_pc(ind: int):
	var pc_name = $vb/TopBar/AddPC.get_popup().get_item_text(ind)
	var pc_dict = DatabaseManager.custom_jsons["PCs"][pc_name]
	var new_pc_line = pc_template.instantiate()
	new_pc_line.from_pc_dict(pc_dict)

	$vb/InfoOptions/Info/Actors.add_child(new_pc_line)
	Signals.emit_signal("add_new_actor_to_initiative")
		
func _handle_edit(ind: int):
	var signal_map = {
		0: "show_manage_PCs", 
		1: "show_add_PC",
		2: "show_manage_NPCs",
		3: "show_add_NPC"
	}
	
	Signals.emit_signal(signal_map[ind])
	
func _handle_file(ind: int):
	var signal_map = [
		"request_save", 
		"request_load",
		"request_quit"
	]
	
	Signals.emit_signal(signal_map[ind])

func _end_encounter():
	_morph_encounter_button()
	_zero_counters()
	encounter_started = false

func _check_sufficient_actors() -> bool:
	if $vb/InfoOptions/Info/Actors.get_child_count() == 0:
		$InsufficientActorsPopup.visible = true
		await $InsufficientActorsPopup.confirmed
		return false
	return true
	
func _morph_encounter_button():
	if !encounter_started:
		$vb/ControlButtons/StartContEncounter.text = "Next Turn"
		$vb/ControlButtons/StartContEncounter.tooltip_text = \
			"""
			Next turn.
			- Increments turn (or resets and increments round)
			- Moves turn highlight bar
			- Resets actor's action economy
			
			To move highlight bar without affecting action economy, 
			change turn number manually.
			"""
	else:
		$vb/ControlButtons/StartContEncounter.text = "Start Encounter"
		$vb/ControlButtons/StartContEncounter.tooltip_text = \
			"""
			Start the encounter.
			- Increments round 1 and turn to 1
			- Shows current turn highlight
			- Changes this button into "Next Turn"
			"""
		
func _start_counters():
	$vb/ControlButtons/Turn.min_value = 1
	$vb/ControlButtons/Round.min_value = 1

func _update_npc_info(actor_node):
	if actor_node is NPC_line:
		$vb/InfoOptions/ReferenceRect/OptionTray/ReferenceRect/NPCScroll/NPCSummary.load_(actor_node.save())
		return
	
	$vb/InfoOptions/ReferenceRect/OptionTray/ReferenceRect/NPCScroll/NPCSummary.clear()

func _move_turn_indicator(update_npc_info: bool = false):
	#NOTE: Counters are 1-indexed because this will be used by humans
	# 	Internally, however, it's all 0 indexed
	var cur_turn = $vb/ControlButtons/Turn.value
	var actors = $vb/InfoOptions/Info/Actors.get_children()
	if update_npc_info:
		_update_npc_info(actors[cur_turn - 1])
	if actors[cur_turn - 1] is ColorRect:
		actors[cur_turn - 1].set_new_color(HardParams.ENCOUNTER_SELECTED)
			
func _reset_turn_indicator():
	var cur_turn = $vb/ControlButtons/Turn.value
	var actors = $vb/InfoOptions/Info/Actors.get_children()

	if actors[cur_turn - 1] is ColorRect:
		actors[cur_turn - 1].reset_color()

func _update_num_attacks(actor_ind: int):
	var actor_node = $vb/InfoOptions/Info/Actors.get_children()[actor_ind]
	if actor_node is NonActor or actor_node is PC_line:
		$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/NumAttacks.value = \
			0
		return
	
	var actor_name = actor_node.actor_name
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/NumAttacks.value = \
		DatabaseManager.custom_jsons["NPCs"][actor_name]["MultiAttack/NumAttacks"]["value"]
	_allow_attacks()

func _get_current_actor_node():
	if !encounter_started:
		return
		
	var actor_node = $vb/InfoOptions/Info/Actors.get_children()[$vb/ControlButtons/Turn.value - 1]
	return actor_node

func _get_current_turn_actor_name():
	var actor_node = _get_current_actor_node()
	if actor_node is NonActor:
		return null
	return actor_node

func _init_encounter():
	_morph_encounter_button()
	_start_counters()
	encounter_started = true

func _decrement_statuses(actor_ind: int):
	var actor_node = $vb/InfoOptions/Info/Actors.get_children()[actor_ind]
	if actor_node is NonActor:
		return
	
	actor_node.decrement_statuses()
	
func _cast_spell():
	print("TODO _cast_spell")
	pass
	
func _disallow_attacks():
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/Attack.toggle_mode = false
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/Attack.flat = true

func _allow_attacks():
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/Attack.toggle_mode = true
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/Attack.flat = false

func _update_spell_slot_value(slot: int, val: int):
	var cur_actor = _get_current_actor_node()
	if cur_actor is NPC_line:
		cur_actor.spell_slots["%d" % slot]["value"] = val

# ========= Signals
func _on_add_non_actor_pressed():
	var new_nonactor = non_actor_template.instantiate()
	$vb/InfoOptions/Info/Actors.add_child(new_nonactor)
	Signals.emit_signal("add_new_actor_to_initiative")

func _on_remove_selected_pressed():
	var n_actors_selected = 0
	for actor in $vb/InfoOptions/Info/Actors.get_children():
		if actor.selected:
			n_actors_selected += 1
				
	if $vb/InfoOptions/Info/Actors.get_child_count() == n_actors_selected:
		_end_encounter()
		
	# Go through actors; if selected, queue free
	for actor in $vb/InfoOptions/Info/Actors.get_children():
		if actor.selected:
			actor.queue_free()
			Signals.emit_signal("remove_actor_from_initiative")

func _on_add_npc_pressed():
	Signals.emit_signal("show_add_NPC_to_initative")

func _on_start_cont_encounter_pressed():
	var sufficient_actors = await _check_sufficient_actors()
	if !sufficient_actors:
		return
	
	if !encounter_started: #init
		_init_encounter()
	else:
		# Decrement happens at the end of the turn, not the beginning
		_reset_turn_indicator()
		_decrement_statuses($vb/ControlButtons/Turn.value - 1)
		if $vb/ControlButtons/Turn.value >= $vb/ControlButtons/Turn.max_value:
			$vb/ControlButtons/Turn.value = 1
			$vb/ControlButtons/Round.value += 1
		else:
			$vb/ControlButtons/Turn.value += 1
			
	_move_turn_indicator()
	_update_num_attacks($vb/ControlButtons/Turn.value - 1)
	Signals.emit_signal("next_turn", $vb/ControlButtons/Turn.value - 1)
	
func _on_attack_pressed():
	if !encounter_started:
		return false
		
	$vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/NumAttacks.value -= 1
	if $vb/InfoOptions/ReferenceRect/OptionTray/ActionScroll/ActionEconomy/Actions/hb/NumAttacks.value == 0:
		_disallow_attacks()
		_trip_action()

func _trip_action() -> bool:
	if !encounter_started:
		return false
		
	var cur_actor = _get_current_actor_node()
	if cur_actor is NonActor:
		return false
	
	return cur_actor.trip_action()
	
func _trip_bonus_action() -> bool:
	if !encounter_started:
		return false
		
	var cur_actor = _get_current_actor_node()
	if cur_actor is NonActor:
		return false
	
	return cur_actor.trip_bonus_action()

func _trip_reaction() -> bool:
	if !encounter_started:
		return false
		
	var cur_actor = _get_current_actor_node()
	if cur_actor is NonActor:
		return false
	
	return cur_actor.trip_reaction()

func _on_action_cast_spell_pressed():
	if !encounter_started:
		return
	var allowed_to_cast = _trip_action()
	if allowed_to_cast:
		_cast_spell()

func _on_bonus_action_cast_spell_pressed():
	if !encounter_started:
		return
	var allowed_to_cast = _trip_bonus_action()
	if allowed_to_cast:
		_cast_spell()
	
func _on_add_status_effect_pressed():
	print("TODO: Bulk status effects")
	# Define status (dialog)
	
	# Get selected actors
	
	# If it's an NPC or a PC, add status
	pass # Replace with function body.

func _on_add_status_effect_popup_close_requested():
	$AddStatusEffectPopup.visible = false
	$AddStatusEffectPopup.move_to_center()

func _on_SS1_value_changed(value):
	_update_spell_slot_value(1, value)

func _on_SS2_value_changed(value):
	_update_spell_slot_value(2, value)

func _on_SS3_value_changed(value):
	_update_spell_slot_value(3, value)

func _on_SS4_value_changed(value):
	_update_spell_slot_value(4, value)

func _on_SS5_value_changed(value):
	_update_spell_slot_value(5, value)

func _on_SS6_value_changed(value):
	_update_spell_slot_value(6, value)

func _on_SS7_value_changed(value):
	_update_spell_slot_value(7, value)

func _on_SS8_value_changed(value):
	_update_spell_slot_value(8, value)

func _on_SS9_value_changed(value):
	_update_spell_slot_value(9, value)
