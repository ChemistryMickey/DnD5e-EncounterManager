class_name NonActor extends ColorRect

@export var initiative: int = 0
@export var selected: bool = false

func save() -> Dictionary:
	return {
		"Type": "NonActor",
		"Initiative": $Info/b/Initiative.text,
		"Description": $Info/b/Description.text
	}

func load_(dict: Dictionary) -> void:
	$Info/b/Initiative.text = dict["Initiative"]
	$Info/b/Description.text = dict["Description"]

func _on_selected_toggled(toggled_on):
	selected = toggled_on
	if toggled_on:
		self.color.a = 0.3
	else:
		self.color.a = 0


func _on_initiative_text_changed(new_text: String):
	if !new_text.is_valid_int():
		return
	initiative = int(new_text)
