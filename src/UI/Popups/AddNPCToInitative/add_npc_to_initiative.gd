extends Window


# Called when the node enters the scene tree for the first time.
func _ready():
	if Signals.connect("show_add_NPC_to_initative", func(): self.visible = true): print("Unable to connect!")
	if Signals.connect("update_NPCs", _populate_NPCs): print("Unable to connect!")
	_populate_NPCs()
	
func _populate_NPCs():
	$vb/NPC_list.clear()
	for npc in DatabaseManager.custom_jsons["NPCs"].keys():
		$vb/NPC_list.add_item(npc)

func _on_add_pressed():
	var selected_inds = $vb/NPC_list.get_selected_items()
	if selected_inds.is_empty():
		return
	
	for _iter in range($vb/hb/NumToAdd.value):
		for ind in selected_inds:
			var selected_name = $vb/NPC_list.get_item_text(ind)
			Signals.emit_signal("add_NPC_to_initiative", selected_name)
			Signals.emit_signal("add_new_actor_to_initiative")
	_on_close_requested()

func _on_close_requested():
	$vb/hb/NumToAdd.value = 1
	self.visible = false
	self.move_to_center()

func _on_cancel_pressed():
	_on_close_requested()
