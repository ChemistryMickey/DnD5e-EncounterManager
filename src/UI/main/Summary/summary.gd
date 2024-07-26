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
	
func _process(_delta):
	if encounter_started:
		_move_turn_indicator()

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
		3: "show_notes",
		4: "show_spellbook",
		5: "show_help"
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

func _on_add_non_actor_pressed():
	var new_nonactor = non_actor_template.instantiate()
	$vb/InfoOptions/Info/Actors.add_child(new_nonactor)
	Signals.emit_signal("add_new_actor_to_initiative")

func _on_remove_selected_pressed():
	# Go through actors; if selected, queue free
	for actor in $vb/InfoOptions/Info/Actors.get_children():
			if actor.selected:
				actor.queue_free()
				Signals.emit_signal("remove_actor_from_initiative")

func _on_add_npc_pressed():
	Signals.emit_signal("show_add_NPC_to_initative")

func _check_sufficient_actors() -> bool:
	if $vb/InfoOptions/Info/Actors.get_child_count() == 0:
		$InsufficientActorsPopup.visible = true
		await $InsufficientActorsPopup.confirmed
		return false
	return true
	
func _morph_encounter_button():
	$TurnIndicator.visible = true
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
		
func _start_counters():
	$vb/ControlButtons/Round.value = 1
	$vb/ControlButtons/Turn.value = 1
	
	$vb/ControlButtons/Turn.min_value = 1
	$vb/ControlButtons/Round.min_value = 1

func _move_turn_indicator():
	#NOTE: Counters are 1-indexed because this will be used by humans
	# 	Internally, however, it's all 0 indexed
	var cur_turn = $vb/ControlButtons/Turn.value
	var actors = $vb/InfoOptions/Info/Actors.get_children()
	
	$TurnIndicator.set_global_position(actors[cur_turn - 1].global_position, false)

func _on_start_cont_encounter_pressed():
	var sufficient_actors = await _check_sufficient_actors()
	if !sufficient_actors:
		return
	
	if !encounter_started:
		encounter_started = true
		_morph_encounter_button()
		_start_counters()
		_move_turn_indicator()
		return
		
	if $vb/ControlButtons/Turn.value >= $vb/ControlButtons/Turn.max_value:
		$vb/ControlButtons/Turn.value = 1
		$vb/ControlButtons/Round.value += 1
	else:
		$vb/ControlButtons/Turn.value += 1
	_move_turn_indicator()
	Signals.emit_signal("next_turn", $vb/ControlButtons/Turn.value - 1)
