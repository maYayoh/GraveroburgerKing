class_name TileB2 extends Tile

@onready var color_indicator: ColorRect = $RecordState

var recorded_state: Graverobber.RecordState = Graverobber.RecordState.UNKNOWN:
	set(value):
		recorded_state = value
		color_indicator.color = color_map[value]

const color_map: Dictionary[Graverobber.RecordState, Color] = {
	Graverobber.RecordState.UNKNOWN: Color.TRANSPARENT,
	Graverobber.RecordState.FREE: Color.WEB_GREEN,
	Graverobber.RecordState.DUG: Color.SADDLE_BROWN,
	Graverobber.RecordState.BLOCK: Color.DIM_GRAY,
	Graverobber.RecordState.RED: Color.DARK_RED,
	Graverobber.RecordState.WHITE: Color.WHITE_SMOKE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:
	if GR.is_in_record_mode():
		if recorded_state == GR.record_type:
			recorded_state = Graverobber.RecordState.UNKNOWN
		else:
			recorded_state = GR.record_type
