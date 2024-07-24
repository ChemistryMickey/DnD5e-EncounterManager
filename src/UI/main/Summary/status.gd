extends HBoxContainer

@export var n_turns = 10
@export var n_turns_remaining = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	$RemainingTurns.value = n_turns_remaining
	$RemainingTurns.max_value = n_turns
	$RemainingTurns.suffix = "/%d" % n_turns

func _on_remove_pressed():
	Signals.emit_signal("status_changed", $Name.text)
	queue_free()
