extends Window

func _ready():
	if Signals.connect("show_manage_NPCs", func(): self.visible = true): print("Unable to connect to show_manage_NPCs!")
	if Signals.connect("update_NPCs", _populate_NPCs): print("Unable to connect to update_NPCs!")
	_populate_NPCs()

func _populate_NPCs():
	$a/b/c1/NPC_list.clear()
	
	for npc in DatabaseManager.custom_jsons["NPCs"].keys():
		$a/b/c1/NPC_list.add_item(npc)

func _on_close_requested():
	$a/b/c2/npc_info.clear()
	self.visible = false



func _on_save_overwrite_pressed():
	var npc_dict: Dictionary = $a/b/c2/npc_info.save()
	if npc_dict.is_empty():
		return
	
	DatabaseManager.add_npc(npc_dict)
	Signals.emit_signal("update_NPCs")
	$a/b/c2/npc_info.clear()

func _on_npc_list_item_activated(ind: int):
	var npc_dict = DatabaseManager.custom_jsons["NPCs"][$a/b/c1/NPC_list.get_item_text(ind)]
	$a/b/c2/npc_info.load_(npc_dict)

func _on_remove_pressed():
	var selected_inds: Array = $a/b/c1/NPC_list.get_selected_items()
	var selected_names = selected_inds.map(func(ind): return $a/b/c1/NPC_list.get_item_text(ind))

	# Get user confirmation to remove players
	$ConfirmationDialog.visible = true
	$ConfirmationDialog.dialog_text = "Confirm removal of %s\n" % ", ".join(selected_names)
	$ConfirmationDialog.dialog_text += "THIS CANNOT BE UNDONE"
	await $ConfirmationDialog.confirmed
	
	for pc_name in selected_names:
		DatabaseManager.remove_npc(pc_name)
		Signals.emit_signal("update_NPCs")
