extends KinematicBody2D

export (int) var playerSpeed = 400
export (int) var jumpHeight = 100
export (int) var gravity = 5
export (int) var playerRange = 128
var velocity = Vector2()
var screenSize
var jumping
var usingConsole = false
var mousePos
var mouseCell
var mouseLocalPos
var mouseLocalCell
var mouseCellID
var tilemapNode
var mouseDistance = 0
var usingInventory = false

func _ready(): #Get screen size
	screenSize = get_viewport_rect().size	
	tilemapNode = $"/root/Main/TileMap"
	

func ManageConsole(): #Manages the console
	if(usingConsole):
		if Input.is_action_just_pressed("ui_cancel"):
			usingConsole = !usingConsole
			get_parent().get_node("Console").Delete()
	if Input.is_action_just_pressed("toggle_console"):
		usingConsole = !usingConsole
		if(usingConsole):
			velocity.x = 0
			get_parent().add_child(load("res://Scenes/Console.tscn").instance())
		else:
			get_parent().get_node("Console").Delete()

func ManageInventory(): #Manages the inventory
	if(usingInventory):
		if Input.is_action_just_pressed("ui_cancel"):
			usingInventory = !usingInventory
			get_parent().get_node("Inventory").Delete()
	if Input.is_action_just_pressed("toggle_inventory"):
		usingInventory = !usingInventory
		if(usingInventory):
			get_parent().add_child(load("res://Scenes/Inventory.tscn").instance())
		else:
			get_parent().get_node("Inventory").Delete()

func ManageMovement(): #Manager player movement
	velocity.x = 0
	jumping = false
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_just_pressed('ui_select'):
		jumping = true
	velocity.x *= playerSpeed

func ManageMouse():
	mousePos = get_global_mouse_position()
	mouseCell = tilemapNode.world_to_map(mousePos)
	mouseLocalPos = position-mousePos
	mouseLocalCell = tilemapNode.world_to_map(mouseLocalPos)
	mouseCellID= tilemapNode.get_cellv(tilemapNode.world_to_map(mousePos))
	mouseDistance = mousePos.distance_to(position)
	
func get_input(): #Manages all input
	ManageConsole()
	ManageInventory()
	if(!usingConsole):
		ManageMovement()
		ManageMouse()

func _physics_process(delta): #Manages player physics
	position = get_position()
	velocity.y += gravity * delta
	get_input()
	if jumping:
		velocity.y = -1 * jumpHeight
	if(velocity.y > gravity):
		velocity.y = gravity
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _input(event):
	if(!usingConsole):
		if(mouseDistance < playerRange):
			if(event.is_action_pressed("rightclick")):
				tilemapNode.set_cellv(mouseCell,-1)
			if(event.is_action_pressed("leftclick")):
				tilemapNode.set_cellv(mouseCell,1)
