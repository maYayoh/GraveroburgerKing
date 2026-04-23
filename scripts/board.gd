@tool class_name Board extends GridContainer

@export var texture_dark: CompressedTexture2D
@export var texture_light: CompressedTexture2D

@onready var tile: Tile = $Tile

var all_tiles: Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var temp: Array[Tile] = []
	temp.resize(8)
	all_tiles.resize(8)
	
	for x in range(8):
		all_tiles[x] = temp.duplicate()
		for y in range(8):
			if x == 0 and y == 0:
				all_tiles[x][y] = tile
				continue
			
			var next_tile: Tile = tile.duplicate()
			all_tiles[x][y] = next_tile;
			next_tile.coord = Vector2(x, y)
			if x%2 == y%2:
				next_tile.texture_normal = texture_dark
			else:
				next_tile.texture_normal = texture_light
			add_child(next_tile)
	
	(all_tiles[7][0] as Tile).objects = Graverobber.TileObjects.RedPlayer
	(all_tiles[0][7] as Tile).objects = Graverobber.TileObjects.WhitePlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func reset_available_state():
	for x in range(8):
		for y in range(8):
			all_tiles[x][y].is_available = false

func show_valid_digs(coord: Vector2):
	reset_available_state()
	
	var temp_x = coord.x - 1
	if temp_x >= 0:
		all_tiles[temp_x][coord.y].is_available = all_tiles[temp_x][coord.y].is_diggable(coord)
	temp_x += 2
	if temp_x <= 7:
		all_tiles[temp_x][coord.y].is_available = all_tiles[temp_x][coord.y].is_diggable(coord)
	
	var temp_y = coord.y - 1
	if temp_y >= 0:
		all_tiles[coord.x][temp_y].is_available = all_tiles[coord.x][temp_y].is_diggable(coord)
	temp_y += 2
	if temp_y <= 7:
		all_tiles[coord.x][temp_y].is_available = all_tiles[coord.x][temp_y].is_diggable(coord)

func show_valid_moves(coord: Vector2):
	reset_available_state()
	
	for x in range(coord.x, -1, -1):
		if !all_tiles[x][coord.y].has_collision():
			all_tiles[x][coord.y].is_available = true
		else:
			break
	for x in range(coord.x, 8, 1):
		if !all_tiles[x][coord.y].has_collision():
			all_tiles[x][coord.y].is_available = true
		else:
			break
	for y in range(coord.y, -1, -1):
		if !all_tiles[coord.x][y].has_collision():
			all_tiles[coord.x][y].is_available = true
		else:
			break
	for y in range(coord.y, 8, 1):
		if !all_tiles[coord.x][y].has_collision():
			all_tiles[coord.x][y].is_available = true
		else:
			break
	
