class_name Status_line
extends HBoxContainer

@export var auto_update: bool = false

func _ready():
	if $RemainingTurns.value == -1:
		$RemainingTurns.visible = false

func decrement():
	$RemainingTurns.value -= 1
	if $RemainingTurns.value == 0:
		queue_free()
		
func set_properties(stat_name: String, max_turns: int, auto_update_in: bool):
	$Name.text = stat_name
	$RemainingTurns.value = max_turns
	$RemainingTurns.max_value = max_turns
	$RemainingTurns.suffix = "/%d" % max_turns
	auto_update = auto_update_in

func _on_remove_pressed():
	Signals.emit_signal("status_changed", $Name.text)
	queue_free()
	
func save() -> Dictionary:
	return {
		"Name": $Name.text,
		"Remaining Turns": $RemainingTurns.value,
		"Total Turns": $RemainingTurns.max_value,
		"Auto Update": auto_update
	}
	
func load_(dict: Dictionary) -> void:
	$Name.text = dict["Name"]
	$RemainingTurns.value = dict["Remaining Turns"]
	$RemainingTurns.max_value = dict["Total Turns"]
	$RemainingTurns.suffix = "/%d" % $RemainingTurns.max_value
	auto_update = dict["Auto Update"]
