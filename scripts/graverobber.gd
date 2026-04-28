class_name Graverobber extends MarginContainer

@onready var rng = RandomNumberGenerator.new()
@onready var board2: Board = $Gameview/GameBoard/Panel2/BoardP2
@onready var board1: Board = $Gameview/GameBoard/Panel1/BoardP1

@onready var text_p2: RichTextLabel = $Gameview/PlayersActions/TopBox/Text
@onready var text_p1: RichTextLabel = $Gameview/PlayersActions/BottomBox/Text
@onready var menu_player: VBoxContainer = $Gameview/PlayersActions/BottomBox/MenuPlayer
@onready var menu_record: VBoxContainer = $Gameview/PlayersActions/BottomBox/MenuRecord
@onready var menu_back: MenuBack = $Gameview/PlayersActions/BottomBox/MenuBack
@onready var menu_new: VBoxContainer = $Gameview/PlayersActions/BottomBox/MenuNew

var state: GameState = GameState.WaitForGame:
	set(value):
		state = value
		_change_menu()
		%DebugState.text = GameState.keys()[state]
		
var b1_red_pos: Vector2 = Vector2(7, 0)
var b1_white_pos: Vector2 = Vector2(0, 7)
var b2_red_pos: Vector2 = Vector2(7, 0)
var b2_white_pos: Vector2 = Vector2(0, 7)

var obstacle_type: TileObstacles:
	set(value):
		obstacle_type = value
		var obstacle_name: String = TileObstacles.keys()[value].to_lower().replace("_", " ")
		update_text_boxes("Place your %s."%obstacle_name, "")
var obstacle_rotation: TileRotation
var record_type: RecordState = RecordState.Free


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("AltClick"):
		match(state):
			GameState.PlacingObstacles:
				obstacle_rotation = (obstacle_rotation + 1) % 4 as TileRotation
				%DebugRotation.text = TileRotation.keys()[obstacle_rotation]
			GameState.SelectRecordPre, GameState.SelectRecordPost:
				record_type = (record_type + 1) % 5 as RecordState
				%DebugRecord.color = TileB2.color_map[record_type]
			GameState.WaitForGame, GameState.MenuPlay, \
			GameState.MenuRecordPre, GameState.MenuRecordPost, \
			GameState.SelectMove, GameState.SelectDig:
				pass
			GameState.WaitForTurn:
				state = GameState.MenuRecordPre
			_:
				print("Unknown GameState: ", state)

func _change_menu():
	text_p1.hide()
	menu_player.hide()
	menu_record.hide()
	menu_back.hide()
	menu_new.hide()
	match(state):
		GameState.WaitForGame:
			menu_new.show()
		GameState.MenuPlay:
			menu_player.show()
		GameState.MenuRecordPre, GameState.MenuRecordPost:
			menu_record.show()
		
		GameState.SelectRecordPre, GameState.SelectRecordPost:
			menu_back.show_and_edit("What just happened?", state-4 as GameState)
		
		GameState.SelectMove:
			menu_back.show_and_edit("Move up, down, left, or right.", GameState.MenuPlay)
		
		GameState.SelectDig:
			menu_back.show_and_edit("Dig up, down, left, or right.", GameState.MenuPlay)
		GameState.PlacingObstacles, GameState.WaitForTurn:
			pass
		_:
			print("Unknown GameState: ", state)

func player_tile_pressed(coord: Vector2, is_available: bool):
	match(state):
		GameState.PlacingObstacles:
			_place_player_obstacle(coord)
		GameState.SelectMove:
			_try_move_to(coord, is_available)
		GameState.SelectDig:
			_try_dig_at(coord, is_available)
		GameState.MenuPlay, GameState.MenuRecordPre, GameState.MenuRecordPost,\
		GameState.SelectRecordPre, GameState.SelectRecordPost,\
		GameState.WaitForTurn, GameState.WaitForGame:
			pass
		_:
			print("Unknown GameState: ", state)

func _try_place_at(coord: Vector2, board: Board) -> bool:
	var can_be_placed: bool = true
	
	var bound_x_min: int = 0
	var bound_y_min: int = 0
	var bound_x_max: int = 7
	var bound_y_max: int = 7
	if obstacle_type == TileObstacles.Windmill:
		bound_x_min = 1
		bound_y_max = 6
	else:
		match (obstacle_rotation):
			TileRotation.North:
				bound_x_min = 1
			TileRotation.South:
				bound_x_max = 6
			TileRotation.West:
				bound_y_min = 1
			TileRotation.East:
				bound_y_max = 6
	
	if (coord.x < bound_x_min or coord.x > bound_x_max) \
	or (coord.y < bound_y_min or coord.y > bound_y_max):
		can_be_placed = false
	
	if can_be_placed:
		var tiles: Array[Array] = board.all_tiles
		if obstacle_type == TileObstacles.Windmill:
			var tile_object_wbnw: TileObjects = tiles[coord.x-1][coord.y].objects
			var tile_object_wbne: TileObjects = tiles[coord.x-1][coord.y+1].objects
			var tile_object_wmsw: TileObjects = tiles[coord.x][coord.y].objects
			var tile_object_wmse: TileObjects = tiles[coord.x][coord.y+1].objects
			
			if tile_object_wbnw != 0 or tile_object_wbne != 0 \
			or tile_object_wmsw != 0 or tile_object_wmse != 0:
				can_be_placed = false
			else:
				tiles[coord.x-1][coord.y].objects = TileObjects.Windmill
				tiles[coord.x-1][coord.y+1].objects = TileObjects.Windmill
				tiles[coord.x][coord.y].objects = TileObjects.Windmill
				tiles[coord.x][coord.y+1].objects = TileObjects.Windmill
		else:
			var dirt_x: int = int(coord.x)
			var dirt_y: int = int(coord.y)
			match (obstacle_rotation):
				TileRotation.North:
					dirt_x -= 1
				TileRotation.South:
					dirt_x += 1
				TileRotation.West:
					dirt_y -= 1
				TileRotation.East:
					dirt_y += 1
			
			var tile_object_tomb: TileObjects = tiles[coord.x][coord.y].objects
			var tile_object_dirt: TileObjects = tiles[dirt_x][dirt_y].objects
			if tile_object_tomb != 0 or tile_object_dirt != 0:
				can_be_placed = false
			else:
				tiles[coord.x][coord.y].objects = TileObjects.Tombstone as TileObjects
				tiles[dirt_x][dirt_y].objects = TileObjects.Dirt as TileObjects
	
	return can_be_placed

func _place_player_obstacle(coord: Vector2):
	if !_try_place_at(coord, board1):
		#play sound or smth
		return
	
	if obstacle_type == TileObstacles.Third_Grave:
		state = GameState.MenuRecordPre
		return
	
	obstacle_type = (obstacle_type + 1) as TileObstacles

# Used for bot and player-random placements
func _auto_place_obstacles(board: Board):
	var coord: Vector2
	for i in range(4):
		obstacle_type = i as TileObstacles
		while(true):
			coord = Vector2(rng.randi_range(0, 7), rng.randi_range(0, 7))
			obstacle_rotation = rng.randi_range(0, 3) as TileRotation
			if _try_place_at(coord, board):
				break

func _try_move_to(coord: Vector2, is_available: bool) -> void:
	# Not aligned on player
	if (!is_available):
		return
	
	var temp_x = coord.x - b1_red_pos.x
	var temp_y = coord.y - b1_red_pos.y
	var new_b2_pos_x = max(0, min(7, b2_red_pos.x + temp_x))
	var new_b2_pos_y = max(0, min(7, b2_red_pos.y + temp_y))
	
	if (temp_x != temp_y):
		if (temp_x != 0):
			var step: int = 1 if temp_x > 0 else -1
			for x in range(b2_red_pos.x, new_b2_pos_x+step, step):
				if board2.all_tiles[x][b2_red_pos.y].has_collision():
					break
				temp_x = x
			new_b2_pos_x = temp_x
		elif (temp_y != 0):
			var step: int = 1 if temp_y > 0 else -1
			for y in range(b2_red_pos.y, new_b2_pos_y+step, step):
				if board2.all_tiles[b2_red_pos.x][y].has_collision():
					break
				temp_y = y
			new_b2_pos_y = temp_y
		
		var b2_old_tile: Tile = board2.all_tiles[b2_red_pos.x][b2_red_pos.y] as Tile
		b2_old_tile.objects = b2_old_tile.objects - TileObjects.RedPlayer as TileObjects
		var b2_new_tile: Tile = board2.all_tiles[new_b2_pos_x][new_b2_pos_y] as Tile
		b2_new_tile.objects = b2_new_tile.objects + TileObjects.RedPlayer as TileObjects
	
	var b1_old_tile: Tile = board1.all_tiles[b1_red_pos.x][b1_red_pos.y] as Tile
	b1_old_tile.objects = b1_old_tile.objects - TileObjects.RedPlayer as TileObjects
	var b1_new_tile: Tile = board1.all_tiles[coord.x][coord.y] as Tile
	b1_new_tile.objects = b1_new_tile.objects + TileObjects.RedPlayer as TileObjects
	
	state = GameState.MenuRecordPost
	board1.reset_available_state()

func _try_dig_at(coord: Vector2, is_available: bool) -> void:
	# Not next to player
	if !is_available:
		return
	
	var temp_x = b2_red_pos.x + (coord.x - b1_red_pos.x)
	var temp_y = b2_red_pos.y + (coord.y - b1_red_pos.y)
	
	var b1_tile: Tile = board1.all_tiles[coord.x][coord.y] as Tile
	b1_tile.objects = b1_tile.objects | TileObjects.Hole as TileObjects
	
	if (temp_x < 0 or temp_x > 7 or temp_y < 0 or temp_y > 7):
		# if dig outside, show temporarily where it was dug "There was nowhere to dig."
		pass
	else:
		var b2_tile: TileB2 = board2.all_tiles[temp_x][temp_y] as TileB2
		if b2_tile.objects & TileObjects.Windmill or b2_tile.objects & TileObjects.Tombstone:
			b2_tile.recorded_state = RecordState.Block
			#"There was something in the way."
		else:
			b2_tile.recorded_state = RecordState.Dug
			b2_tile.objects = b2_tile.objects | TileObjects.Hole as TileObjects
			if b2_tile.objects & TileObjects.Dirt:
				#"Something was there! But what?"
				pass
			else:
				#"Player X reported that nothing was found there."
				pass
	#"Player X dug <green>Y</green>."
	state = GameState.MenuRecordPost
	board1.reset_available_state()

func update_red_position(coord: Vector2, is_record_tile: bool):
	if !is_record_tile:
		b1_red_pos = coord
	else:
		b2_red_pos = coord

func update_white_position(coord: Vector2, is_record_tile: bool):
	if !is_record_tile:
		b1_white_pos = coord
	else:
		b2_white_pos = coord

func update_text_boxes(t1: String, t2: String):
	if t1 != "":
		text_p1.text = t1
		text_p1.show()
	else:
		text_p1.hide()
	
	text_p2.text = t2 if t2 != "" else "Player 2 is waiting."

func is_in_record_menu() -> bool:
	return state == GameState.MenuRecordPre or state == GameState.MenuRecordPost

func is_in_record_mode() -> bool:
	return state == GameState.SelectRecordPre or state == GameState.SelectRecordPost

func is_board_highlighted() -> bool:
	return state == GameState.SelectMove or state == GameState.SelectDig



func _on_button_new_game_pressed() -> void:
	_auto_place_obstacles(board2)
	if (%DebugRandom.button_pressed):
		_auto_place_obstacles(board1)
		state = GameState.MenuRecordPre
		return
	
	state = GameState.PlacingObstacles
	obstacle_type = TileObstacles.Windmill
	obstacle_rotation = TileRotation.South

func _on_button_move_pressed() -> void:
	state = GameState.SelectMove
	board1.show_valid_moves(b1_red_pos)

func _on_button_dig_pressed() -> void:
	state = GameState.SelectDig
	board1.show_valid_digs(b1_red_pos)

func _on_button_skip_pressed() -> void:
	state = GameState.WaitForTurn

func _on_button_back_pressed() -> void:
	state = GameState.MenuRecordPre

func _on_button_continue_pressed() -> void:
	if state == GameState.MenuRecordPre:
		state = GameState.MenuPlay
	elif state == GameState.MenuRecordPost:
		state = GameState.WaitForTurn
	else:
		print("Why is this menu showing in ", state)

func _on_button_record_pressed() -> void:
	if state == GameState.MenuRecordPre:
		state = GameState.SelectRecordPre
	elif state == GameState.MenuRecordPost:
		state = GameState.SelectRecordPost
	else:
		print("Why is this menu showing in ", state)

func _on_button_quit_pressed() -> void:
	print("huhhhhhhh reset plz")


#										V---------------------|
# WaitForGame > PlacingObstacles > MenuRecord |> SelectRecord |
#									^		  |> MenuPlay |> SelectMove |
#									|					  |> SelectDig  |
#									|---------------------|				|> MenuRecord |> SelectRecord |
#									|												  |> WaitForTurn  |
#									|-----------------------------------------------------------------|
enum GameState {
	PlacingObstacles,
	MenuPlay,
	MenuRecordPre,
	MenuRecordPost,
	SelectMove,
	SelectDig,
	SelectRecordPre,
	SelectRecordPost,
	WaitForTurn,
	WaitForGame
}

enum RecordState {
	#Default; No override (gray checkered tile)
	Unknown = -1,
	#Walkable space; Green tile
	Free,
	#Space already dug; Brown tile
	Dug,
	#Space blocked by Windmill or Tombstone; Black tile
	Block,
	#Red player (Human); Red tile
	Red,
	#White player (Bot); White tile
	White
}

enum TileObjects {
	None = 0,
	RedPlayer = 1,
	WhitePlayer = 2,
	Dirt = 4,
	Hole = 8,
	
	RedDirt = 5,
	WhiteDirt = 6,
	RedHole = 9,
	WhiteHole = 10,
	Dug = 12,
	RedDug = 13,
	WhiteDug = 14,
	
	Tombstone = 16,
	Windmill = 32
}

enum TileObstacles {
	Windmill,
	First_Grave,
	Second_Grave,
	Third_Grave
}

enum TileRotation {
	North = 0,
	East = 1,
	South = 2,
	West = 3
}


func _on_debug_objects_toggled(toggled_on: bool) -> void:
	for x in range(8):
		for y in range(8):
			board2.all_tiles[x][y].show_objects = toggled_on
			board2.all_tiles[x][y]._update_display()
