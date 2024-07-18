extends Control

@export var current_character_path: String = ""
@onready var save_dialog = $SaveFile
@onready var spellbook = $SpellbookPopup

var sheet_dict: Dictionary

func _shortcut_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_as"):
		#NOTE: This must go before "save" or else the save event will be handled before this one
		# 	Apparently action clusters are possible
		current_character_path = ""
		save_current_sheet()
	elif event.is_action_pressed("save"):
		save_current_sheet()
	elif event.is_action_pressed("load"):
		load_sheet()
	#if event.is_action_pressed("quit"):
		#Signals.emit_signal("show_confirmation", "quit_to_desktop")
	if event.is_action_pressed("spellbook"):
		Signals.emit_signal("show_spellbook")
	elif event.is_action_pressed("notes"):
		Signals.emit_signal("show_notes")
	#if event.is_action_pressed("new_character"):
		#Signals.emit_signal("show_confirmation", "new_character")
	
	self.get_viewport().set_input_as_handled();

func _on_SaveFile_file_selected(path: String) -> void:
	current_character_path = path

func _on_LoadFile_file_selected(path: String) -> void:
	current_character_path = path

func open_quit_dialogue():
	$ConfirmationDialog.popup_centered()
	await $ConfirmationDialog.confirmed

func save_current_sheet():
	if current_character_path == "":
		save_dialog.popup_centered()
		await save_dialog.file_selected
		
	var save_filename = current_character_path
	Debug.debug_print("Saving current sheet %s..." % save_filename)

	sheet_dict = {} #clear the sheet dict to prevent unintended entry persistence

	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node has a save function.
		if !node.has_method("save"):
			continue

		# Call the node's save function.
		var node_data = node.call("save")
		for key in node_data:
			sheet_dict[key] = node_data[key]
	
	if sheet_dict != {}:
		var json_str: String = JSON.stringify(sheet_dict, "\t")
		FileAccess.open(save_filename, FileAccess.WRITE).store_string(json_str)

	$SaveFlash/AnimationPlayer.play("flash")

func load_sheet(path : String = ""):
	if path == "":
		$LoadFile.popup_centered()
		await $LoadFile.file_selected
	else:
		current_character_path = path
	
	if not FileAccess.file_exists(current_character_path):
		return # Error! We don't have a save to load.
	var save_game = FileAccess.open(current_character_path, FileAccess.READ)

	var conts = save_game.get_as_text()
	save_game.close()
	
	sheet_dict = JSON.parse_string(conts)
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		if !node.has_method("load_sheet"):
			#print("persistent node '%s' is missing a load() function, skipped" % node.name)
			continue
			
		node.call("load_sheet", sheet_dict)
