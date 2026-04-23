class_name MenuBack extends VBoxContainer

@onready var GR: Graverobber = %Graverobber
@onready var label: RichTextLabel = $Text
@onready var button: Button = $Button

var previous_state: Graverobber.GameState

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_and_edit(text: String, state: Graverobber.GameState):
	label.text = text
	previous_state = state
	show()

func _on_button_pressed() -> void:
	label.text = ""
	GR.state = previous_state
