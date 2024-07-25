extends HBoxContainer

@export var n_turns = 10
@export var n_turns_remaining = 10

func _ready():
	$RemainingTurns.value = n_turns_remaining
	$RemainingTurns.max_value = n_turns
	$RemainingTurns.suffix = "/%d" % n_turns

func _on_remove_pressed():
	Signals.emit_signal("status_changed", $Name.text)
	queue_free()

func save() -> Dictionary:
	return {
		"Name": $Name.text,
		"Remaining Turns": $RemainingTurns.value,
		"Total Turns": $RemainingTurns.max_value
	}
	
func load_(dict: Dictionary) -> void:
	$Name.text = dict["Name"]
	n_turns = int(dict["Total Turns"])
	n_turns_remaining = int(dict["Remaining Turns"])
	$RemainingTurns.value = int(dict["Remaining Turns"])
	$RemainingTurns.max_value = dict["Total Turns"]
	$RemainingTurns.suffix = "/%s" % $RemainingTurns.max_value
