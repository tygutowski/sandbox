extends Node2D

#Variables
export (int) var worldStart = -150
export (int) var worldEnd = 150
export (int) var worldDepth = 100
export (int) var skyLimit = -100
export (int) var stoneDepth = 30
export (int) var stoneVariance = 5
export (int) var caveDepth = 20
export (int) var heightMultiplier = 20
export (int) var heightAddition = 0
export (float) var caveNoise = .05
export (Script) var saveGameClass

var worldTileMap
var surfaceLow
var surfaceHeight
var saveVariables = ["playerPosition", "tileMapCells"]
var horizon = 0
var noise = OpenSimplexNoise.new()
var rng = RandomNumberGenerator.new()
var selectedTile
var currentSeed
var worldSize
var worldHeight

func _ready(): #Initialization
	worldSize = worldEnd - worldStart
	worldHeight = skyLimit - worldDepth
	DebugOverlay()
	GenerateWorld()
	GetTiles()
	load("res://Scenes/HUD Overlay.tscn").instance()
	
	
func GenerateWorld(): #World Generation
	LoadNoise()
	GenerateStone()
	GenerateTerrain()
	GenerateLayerMix()
	GenerateCaves()
	
func DebugOverlay(): #Add Debug Overlay to screen
	#var minimapOverlay = load ("res://Scenes/Minimap.tscn").instance()
	var debugOverlay = load("res://Scenes/Debug Overlay.tscn").instance()
	debugOverlay.add_stat("FPS", Engine , "get_frames_per_second", true)
	debugOverlay.add_stat("Player Position", $Player, "position", false)
	debugOverlay.add_stat("Global Mouse Position", $Player, "mousePos", false)
	debugOverlay.add_stat("Local Mouse Position", $Player, "mouseLocalPos", false)
	debugOverlay.add_stat("Global Mouse Cell", $Player, "mouseCell", false)
	debugOverlay.add_stat("Local Mouse Cell", $Player, "mouseLocalCell", false)
	debugOverlay.add_stat("Mouse Cell ID", $Player, "mouseCellID", false)
	debugOverlay.add_stat("Velocity", $Player, "velocity", false)
	debugOverlay.add_stat("RAM Usage", OS, "get_static_memory_usage", true)
	debugOverlay.add_stat("Seed", self, "currentSeed", false)
	add_child(debugOverlay)

func LoadNoise(): #Generates perlin noise for world generation
	noise.octaves = 4
	noise.period = 50.0
	noise.persistence = 0.8
	randomize()
	noise.set_seed(randi())
	currentSeed = noise.seed
	rng.randomize()

func GenerateStone(): #Generates all of the stone in the world
	for x in range(worldStart,worldEnd):
		for y in range(stoneDepth,worldDepth):
			$TileMap.set_cell(x,y,2)
			
func GenerateTerrain(): #Uses perlin noise to generate world
	print(noise.seed)
	surfaceLow = skyLimit
	for x in range(worldStart,worldEnd): #Generates grass
		surfaceHeight = noise.get_noise_2d(horizon,x) * heightMultiplier - heightAddition
		#surfaceShift = noise.get_noise_2d(horizon,y) * heightMultiplier - heightAddition
		if(surfaceLow < surfaceHeight):
			surfaceLow = surfaceHeight		
		for y in range(surfaceHeight-1,skyLimit,-1): #Deletes blocks above grass
			$TileMap.set_cell(x,y,-1)
		for y in range(surfaceHeight+1,stoneDepth): #Generates dirt below grass
			$TileMap.set_cell(x,y,1)
	#for x in range (worldStart, worldEnd): #Generates dirt between stone and dirt layer
		$TileMap.set_cell(x,surfaceHeight,0)
		
func GenerateCaves(): #Uses 2d perlin noise to generate caves
	var tempNoise
	for x in range(worldStart,worldEnd):
		for y in range(surfaceLow+caveDepth, worldDepth):
			tempNoise = noise.get_noise_2d(x,y)
			if(tempNoise>caveNoise):
				$TileMap.set_cell(x,y,-1)

func GenerateLayerMix(): #Mixes the stone and dirt together
	var randomNumber
	for x in range (worldStart,worldEnd):
		for y in range (stoneDepth, stoneDepth+stoneVariance/2):
			randomNumber = rng.randf_range(0,100)
			if(randomNumber>25):
				$TileMap.set_cell(x,y,1)
		for y in range (stoneDepth, stoneDepth+stoneVariance):
			randomNumber = rng.randf_range(0,100)
			if(randomNumber>50):
				$TileMap.set_cell(x,y,1)

func SaveWorld(worldName): #Saves the world
	
	var fileName = str("res://saves/", worldName, ".tres")
	var newSave = saveGameClass.new()
	#newSave.playerPosition = $Player.position
	
	var tileMapCells = []
	for x in range(worldStart,worldEnd):
		tileMapCells.append([])
		for y in range(skyLimit,worldDepth):
			tileMapCells[x-worldStart].append($TileMap.get_cell(x,y))
	newSave.tileMapCells = tileMapCells
	
	var dir = Directory.new()
	if not dir.dir_exists("res://saves/"):
		dir.make_dir_recursive("res://saves/")
	ResourceSaver.save(fileName, newSave)
	
	
func LoadWorld(worldName): #Loads the world
	var fileName = str("res://saves/", worldName, ".tres")
	var dir = Directory.new()
	if not dir.file_exists(fileName):
		return false
	
	var worldSave = load(fileName)
	if not VerifySave(worldSave):
		return false
	
	#$Player.position = worldSave.playerPosition
	for x in range(worldStart,worldEnd):
		for y in range(skyLimit,worldDepth):
			$TileMap.set_cell(x,y,worldSave.tileMapCells[x-worldStart][y-skyLimit])
	
	return true
	
func VerifySave(worldSave): #Checks all variables after saving
	for v in saveVariables:
		if worldSave.get(v) == null:
			return false
	return true

func GetTiles(): #Gets all tiles once the world is generated
	worldTileMap = []
	for x in range(worldStart,worldEnd):
		worldTileMap.append([])
		for y in range(skyLimit,worldDepth):
			worldTileMap[x-worldStart].append($TileMap.get_cell(x,y))
	return worldTileMap
	
