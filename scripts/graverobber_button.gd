extends Button

# Godot doesn't support 'null' if the variable is static-typed.
# @export variable needs to be static-typed.
# To not update a text, leave it empty. To clear it, set a white space.
@export var text_p2: String = ""
@export var text_p1: String = ""

@onready var GR: Graverobber = %Graverobber

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed():
	GR.update_text(text_p1, text_p2)
