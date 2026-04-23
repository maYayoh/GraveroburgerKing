class_name Tile extends TextureButton

@export var coord: Vector2
@export var is_record_tile: bool
@export var show_objects: bool

@onready var GR: Graverobber = $"../../../../.."
@onready var label: Label = $Label


var is_available: bool = false:
	set(value):
		is_available = value
		if GR.is_board_highlighted():
			var c: float = 1.75 if value else 0.25
			set_self_modulate(Color(c, c, c))
		else:
			set_self_modulate(Color.WHITE)

var objects: Graverobber.TileObjects = Graverobber.TileObjects.None:
	get:
		return objects
	set(value):
		if value & Graverobber.TileObjects.RedPlayer:
			GR.update_red_position(coord, is_record_tile)
		elif value & Graverobber.TileObjects.WhitePlayer:
			GR.update_white_position(coord, is_record_tile)
		objects = value
		_update_display()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func has_collision() -> bool:
	return objects & Graverobber.TileObjects.Windmill \
	or objects & Graverobber.TileObjects.Tombstone

func is_diggable(player_pos: Vector2) -> bool:
	return !has_collision() and coord.distance_squared_to(player_pos) == 1

func _update_display() -> void:
	if !show_objects:
		label.text = ""
		return
	match(objects):
		Graverobber.TileObjects.None:
			label.text = ""
		Graverobber.TileObjects.RedPlayer:
			label.text = "❤"
		Graverobber.TileObjects.WhitePlayer:
			label.text = "🤍"
		Graverobber.TileObjects.Dirt:
			label.text = "🟫"
		Graverobber.TileObjects.Hole:
			label.text = "⚫"
		
		Graverobber.TileObjects.RedDirt:
			label.text = "🟥"
		Graverobber.TileObjects.WhiteDirt:
			label.text = "⬜"
		Graverobber.TileObjects.RedHole:
			label.text = "🔴"
		Graverobber.TileObjects.WhiteHole:
			label.text = "⚪"
		Graverobber.TileObjects.RedDug:
			label.text = "❗"
		Graverobber.TileObjects.WhiteDug:
			label.text = "❕"
		Graverobber.TileObjects.Tombstone:
			label.text = "🧱"
		Graverobber.TileObjects.Windmill:
			label.text = "⬛"
		
		_:
			label.text = str(objects)
