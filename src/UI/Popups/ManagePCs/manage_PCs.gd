extends Window

func _ready():
	if Signals.connect("update_PCs", _populate_list): print("Unable to connect to update_PCs!")
	_populate_list()
	
func _populate_list():
	$VBoxContainer/HBoxContainer/PCListContainer/ItemList.clear()
	for key in DatabaseManager.custom_jsons["PCs"].keys():
		$VBoxContainer/HBoxContainer/PCListContainer/ItemList.add_item(key)

func _on_item_list_item_activated(index):
	var pc_name = $VBoxContainer/HBoxContainer/PCListContainer/ItemList.get_item_text(index)
	$VBoxContainer/HBoxContainer/PCInfo.load_from_dict(DatabaseManager.custom_jsons["PCs"][pc_name])

func _on_close_requested():
	self.visible = false
