extends VBoxContainer

@onready var pc_template = preload("res://src/UI/main/Summary/PC-line.tscn")
@onready var non_actor_template = preload("res://src/UI/main/Summary/non-actor.tscn")

var cur_init_ind = 0

func _ready():
	if Signals.connect("add_NPC_to_initiative", _add_npc_to_initiative): print("Unable to connect to add_NPC_to_initiative!")

func _add_npc_to_initiative(npc_name: String):
	print("TODO: Create an NPC template and put in NPC %s" % npc_name)

func save() -> Dictionary:
	var actors = []
	for child in self.get_children():
		if child is PC_line or child is NonActor:
			actors.append(child.save())
	return {
		"Current Initiative Index": cur_init_ind,
		"Current Initiative Order": actors
	}
	
func load_sheet(dict: Dictionary) -> void:
	for entry in dict["Current Initiative Order"]:
		var new_line
		if entry["Type"] == "PC_line":
			new_line = pc_template.instantiate()
		elif entry["Type"] == "NonActor":
			new_line = non_actor_template.instantiate()
		new_line.load_(entry)
		
		self.add_child(new_line)

func _get_ind_to_move() -> int:
	var ind_to_move = 0
	for actor in self.get_children():
		if actor is PC_line or actor is NonActor:
			if actor.selected:
				break
		ind_to_move += 1
	return ind_to_move

func _on_up_pressed():
	var ind_to_move_up = _get_ind_to_move()
	if ind_to_move_up == self.get_child_count() or ind_to_move_up == 0:
		return
		
	var actors = []
	for actor in self.get_children():
		actors.append(actor)
		self.remove_child(actor)
		
	# Perform move operation
	var moving_actor = actors.pop_at(ind_to_move_up)
	actors.insert(ind_to_move_up - 1, moving_actor)
	
	# Push on
	for actor in actors:
		self.add_child(actor)

func _on_down_pressed():
	var ind_to_move_down = _get_ind_to_move()
	if ind_to_move_down >= self.get_child_count() - 1:
		return
		
	var actors = []
	for actor in self.get_children():
		actors.append(actor)
		self.remove_child(actor)
		
	# Perform move operation
	var moving_actor = actors.pop_at(ind_to_move_down)
	actors.insert(ind_to_move_down + 1, moving_actor)
	
	# Push on
	for actor in actors:
		self.add_child(actor)

