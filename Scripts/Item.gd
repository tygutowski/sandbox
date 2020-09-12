extends Node2D

var item_name
var item_quantity

func _ready():
	var rand_val = randi() % 2
	
	if rand_val == 0:
		item_name = "Stick"
	elif rand_val == 1:
		item_name = "Rock"
	else:
		pass
	
	$TextureRect.texture = load("res://SandboxSprites/" + item_name + ".png")
	var stack_size = int(JSONData.item_data[item_name]["StackSize"])
	item_quantity = randi() % stack_size + 1
	if stack_size == 1:
		$Label.visible = false
	else:
		$Label.text = String(item_quantity)

func add_item_quantity(amount):
	item_quantity += amount
	$Label.text = String(item_quantity)

func remove_item_quantity(amount):
	item_quantity -= amount
	$Label.text = String(item_quantity)

