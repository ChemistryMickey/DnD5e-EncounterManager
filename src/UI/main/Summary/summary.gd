extends VBoxContainer

@onready var pc_template = preload("res://src/UI/main/Summary/PC.tscn")
@onready var non_actor_template = preload("res://src/UI/main/Summary/non-actor.tscn")

func _ready():
	$ControlButtons/AddPC.get_popup().index_pressed.connect(_handle_add_pc)
	$TopBar/File.get_popup().index_pressed.connect(_handle_file)
	$TopBar/Edit.get_popup().index_pressed.connect(_handle_edit)
	$TopBar/Options.get_popup().index_pressed.connect(_handle_options)
	
	if Signals.connect("update_PCs", _prep_pc_option_button): print("Unable to connect to update_PCs!")
	_prep_pc_option_button()
	
func _prep_pc_option_button():
	$ControlButtons/AddPC.get_popup().clear()
	for pc in DatabaseManager.custom_jsons["PCs"].keys():
		$ControlButtons/AddPC.get_popup().add_item(pc)

func _handle_options(ind: int) -> void:
	var signal_map = {
		3: "show_notes",
		4: "show_spellbook",
		5: "show_help"
	}
	Signals.emit_signal(signal_map[ind])

func _handle_add_pc(ind: int):
	var pc_name = $ControlButtons/AddPC.get_popup().get_item_text(ind)
	var pc_dict = DatabaseManager.custom_jsons["PCs"][pc_name]
	var new_pc_line = pc_template.instantiate()
	new_pc_line.from_pc_dict(pc_dict)

	$InfoOptions/Info/Actors.add_child(new_pc_line)
		
func _handle_edit(ind: int):
	var signal_map = {
		0: "show_manage_PCs", 
		1: "show_add_PC"
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
	$InfoOptions/Info/Actors.add_child(new_nonactor)
