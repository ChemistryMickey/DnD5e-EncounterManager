extends Window

func _ready():
	if Signals.connect("update_PCs", _populate_list): print("Unable to connect to update_PCs!")
	if Signals.connect("show_manage_PCs", func(): self.visible = true): print("Unable to connect to show_manage_PCs!")
	_populate_list()
	
func _populate_list():
	$VBoxContainer/HBoxContainer/PCListContainer/ItemList.clear()
	for key in DatabaseManager.custom_jsons["PCs"].keys():
		$VBoxContainer/HBoxContainer/PCListContainer/ItemList.add_item(key)

func _on_item_list_item_activated(index):
	$VBoxContainer/HBoxContainer/PCInfo.clear()
	var pc_name = $VBoxContainer/HBoxContainer/PCListContainer/ItemList.get_item_text(index)
	$VBoxContainer/HBoxContainer/PCInfo.load_from_dict(DatabaseManager.custom_jsons["PCs"][pc_name])

func _on_close_requested():
	$VBoxContainer/HBoxContainer/PCInfo.clear()
	self.move_to_center()
	self.visible = false

func _on_remove_pressed():
	var selected_inds: Array = $VBoxContainer/HBoxContainer/PCListContainer/ItemList.get_selected_items()
	var selected_names = selected_inds.map(func(ind): return $VBoxContainer/HBoxContainer/PCListContainer/ItemList.get_item_text(ind))

	# Get user confirmation to remove players
	$ConfirmationDialog.visible = true
	$ConfirmationDialog.dialog_text = "Confirm removal of %s\n" % ", ".join(selected_names)
	$ConfirmationDialog.dialog_text += "THIS CANNOT BE UNDONE"
	await $ConfirmationDialog.confirmed
	
	for pc_name in selected_names:
		DatabaseManager.remove_pc(pc_name)
		Signals.emit_signal("update_PCs")

func _on_add_overwrite_pressed():
	var pc = $VBoxContainer/HBoxContainer/PCInfo.to_dict()
	DatabaseManager.add_pc(pc)
	Signals.emit_signal("update_PCs")
	$VBoxContainer/HBoxContainer/PCInfo.clear()
