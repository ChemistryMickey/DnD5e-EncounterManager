extends VBoxContainer

func _ready():
	$ControlButtons/AddPC.get_popup().index_pressed.connect(_handle_add_pc)
	$TopBar/File.get_popup().index_pressed.connect(_handle_file)
	$TopBar/Edit.get_popup().index_pressed.connect(_handle_edit)
	$TopBar/Options.get_popup().index_pressed.connect(_handle_options)

func _handle_options(ind: int) -> void:
	var signal_map = {
		3: "show_notes",
		4: "show_spellbook",
		5: "show_help"
	}
	Signals.emit_signal(signal_map[ind])

func _handle_add_pc(ind: int):
	if ind == ($ControlButtons/AddPC.get_popup().item_count - 1):
		Signals.emit_signal("show_add_pc")
		
func _handle_edit(ind: int):
	var signal_map = {
		0: "show_manage_pcs", 
		1: "show_add_pc"
	}
	
	Signals.emit_signal(signal_map[ind])
	
func _handle_file(ind: int):
	var signal_map = [
		"request_save", 
		"request_load",
		"request_quit"
	]
	
	Signals.emit_signal(signal_map[ind])

