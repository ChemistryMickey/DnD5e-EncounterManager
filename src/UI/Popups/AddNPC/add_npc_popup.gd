extends Window

func _ready():
	if Signals.connect("show_add_NPC", func(): self.visible = true): print("Unable to connect to show_add_NPC!")
	$a/npc_info.populate_spells()

func _on_close_requested():
	$a/npc_info.clear()
	self.move_to_center()
	self.visible = false

func _on_save_pressed():
	var npc_dict: Dictionary = $a/npc_info.save()
	if npc_dict.is_empty():
		return
	
	DatabaseManager.add_npc(npc_dict)
	Signals.emit_signal("update_NPCs")
	_on_close_requested()

func _on_cancel_pressed():
	_on_close_requested()
