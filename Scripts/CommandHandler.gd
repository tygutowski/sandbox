extends Node

onready var player = get_parent().get_parent().get_node("Player")
onready var main = get_node("/root/Main")

enum {
	ARG_INT,
	ARG_STRING,
	ARG_BOOL,
	ARG_FLOAT
}

const commands = [ #List of all commands
	["help"],
	["set_speed", [ARG_INT]],
	["save_as", [ARG_STRING]],
	["load_from", [ARG_STRING]],
	["set_jump", [ARG_INT]],
	["set_gravity", [ARG_INT]],
]

func help(): #Prints all commands
	var commandList = ""
	var iteration = commands.size()
	for c in range (iteration):
		if c == iteration-1:
			commandList = str(commandList, commands[c][0], ".")
		else:
			commandList = str(commandList, commands[c][0], ", ")
	return commandList

func set_speed(speed): #Changes player speed
	speed = int(speed)
	player.playerSpeed = speed
	return str("Successfully set player speed to ", speed)

func set_gravity(gravity): #Changes player gravity
	gravity = int(gravity)
	player.gravity = gravity
	return str("Successfully set player gravity to ", gravity)
	
func set_jump(jump): #Changes player jump
	jump = int(jump)
	player.jumpHeight = jump
	return str("Successfully set player jump height to ", jump)
	
func save_as(worldName): #Saves world as file
	main.SaveWorld(worldName)
	return str('Succesfully saved world as "', worldName, '".')

func load_from(worldName): #Loads world from file
	main.LoadWorld(worldName)
	return str('Succesfully loaded world "', worldName, '".')
