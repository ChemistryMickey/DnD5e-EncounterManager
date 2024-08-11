class_name NonActor extends ColorRect

@export var initiative: int = 0
@export var selected: bool = false

var default_color: Color = HardParams.SELECTED
var previous_color: Color = HardParams.SELECTED

func set_new_color(color_in: Color, alpha: float = -1) -> void:
	self.previous_color = self.color
	self.color = color_in
	if alpha != -1:
		self.color.a = alpha
	
	return

func reset_color() -> void:
	self.color = self.previous_color
	if not self.selected:
		self.color.a = 0
	
	return

func save() -> Dictionary:
	return {
		"Type": "NonActor",
		"Initiative": $Info/b/Initiative.value,
		"Description": $Info/b/Description.text
	}

func load_(dict: Dictionary) -> void:
	$Info/b/Initiative.value = dict["Initiative"]
	$Info/b/Description.text = dict["Description"]
	initiative = dict["Initiative"]
	self.color.a = 0

func _on_selected_toggled(toggled_on):
	selected = toggled_on
	if toggled_on:
		self.color.a = HardParams.SELECTED_TRANSPARENCY
		self.previous_color = HardParams.SELECTED
	elif self.color == HardParams.ENCOUNTER_SELECTED:
		self.previous_color = HardParams.SELECTED
		return
	else:
		self.color.a = 0

func _on_initiative_value_changed(value):
	initiative = value
