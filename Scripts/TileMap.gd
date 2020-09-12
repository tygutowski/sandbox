extends TileMap

var playerPosition
var playerTilePosition
onready var main = get_node("/root/Main")
const CHUNK_SIZE = Vector2(84,58)
const CHUNK_SNAP = 8
var current_chunk_x = -1
var current_chunk_y = -1
var chunk_update_time = 0
var tileMap

func _process(delta):
	tileMap = main.GetTiles()
	ChunkLoad()

func ChunkLoad():
	playerPosition = get_node("/root/Main/Player").get("position")
	playerTilePosition = world_to_map(playerPosition)
	current_chunk_x = int(stepify(playerTilePosition.x, CHUNK_SNAP) - CHUNK_SIZE.x/2)
	current_chunk_y = int(stepify(playerTilePosition.y, CHUNK_SNAP) - CHUNK_SIZE.y/2)
	var current_chunk_frame = Rect2(current_chunk_x, current_chunk_y, CHUNK_SIZE.x, CHUNK_SIZE.y)
	
	for x in range(current_chunk_frame.position.x, current_chunk_frame.end.x):
		for y in range(current_chunk_frame.position.y, current_chunk_frame.end.y):
				set_cell(x,y,GetTile(x,y))
	
func GetTile(x,y):
	
	x = clamp(x, 0, main.worldSize - 1)
	y = clamp(y, 0, main.worldHeight - 1)
	return tileMap[x][y]
	#return tileMap[x-main.worldStart][y-main.skyLimit]
	
func check_update_chunks():
	var start_time = OS.get_ticks_msec()
	
	playerTilePosition = world_to_map(playerPosition)
	var new_chunk_x = int(stepify(playerTilePosition.x, CHUNK_SNAP) - CHUNK_SIZE.x/2)
	var new_chunk_y = int(stepify(playerTilePosition.y, CHUNK_SNAP) - CHUNK_SIZE.y/2)
	if new_chunk_x == current_chunk_x and new_chunk_y == current_chunk_y:
		return
	var new_lr = Rect2(0,0, CHUNK_SNAP, CHUNK_SIZE.y)
	var old_lr = Rect2(0,0, CHUNK_SNAP, CHUNK_SIZE.y)
	var new_tb = Rect2(0,0, CHUNK_SIZE.x, CHUNK_SNAP)
	var old_tb = Rect2(0,0, CHUNK_SIZE.x, CHUNK_SNAP)

	if new_chunk_x > current_chunk_x:
		new_lr.position = Vector2(current_chunk_x + CHUNK_SIZE.x, new_chunk_y)
		old_lr.position = Vector2(current_chunk_x + current_chunk_y)
	else:
		new_lr.position = Vector2(current_chunk_x, new_chunk_y)
		old_lr.position = Vector2(current_chunk_x + CHUNK_SIZE.x, current_chunk_y)
	if new_chunk_y > current_chunk_y:
		new_tb.position = Vector2( max(current_chunk_x, new_chunk_x), current_chunk_y + CHUNK_SIZE.y)
		old_tb.position = Vector2( max(current_chunk_x, new_chunk_x), current_chunk_y)
	else:
		new_tb.position = Vector2(max(current_chunk_x, new_chunk_x), new_chunk_y)
		old_tb.position = Vector2(max(current_chunk_x, new_chunk_x), new_chunk_y + CHUNK_SIZE.y) 

	var world_rect = Rect2(0,0,main.worldSize, main.worldHeight)
	new_lr = new_lr.clip(world_rect)
	new_tb = new_tb.clip(world_rect)
	
	for x in range(old_lr.position.x, old_lr.end.x):
		for y in range(old_lr.position.y, old_lr.end.y):
			set_cell(x,y,-1)
	for x in range(old_tb.position.x, old_tb.end.x):
		for y in range(old_tb.position.y, old_tb.end.y):
			set_cell(x,y,-1)
	for x in range(new_lr.position.x, new_lr.end.x):
		for y in range(new_lr.position.y, new_lr.end.y):
			set_cell(x,y, GetTile(x,y))
	for x in range(new_tb.position.x, new_tb.end.x):
		for y in range(new_tb.position.y, new_tb.end.y):
			set_cell(x,y,GetTile(x,y))
		
	current_chunk_x = new_chunk_x
	current_chunk_y = new_chunk_y
	
	chunk_update_time = OS.get_ticks_msec() - start_time
