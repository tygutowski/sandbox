extends Control

var commandHistoryLine = CommandHistory.history.size()

func _input(event): #Handles going back to past command
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_UP:
			GotoCommandHistory(-1)
		if event.scancode == KEY_DOWN:
			GotoCommandHistory(1)

func GotoCommandHistory(offset): #Handles command saving
	commandHistoryLine += offset
	commandHistoryLine = clamp(commandHistoryLine, 0, CommandHistory.history.size())
	if commandHistoryLine < CommandHistory.history.size() and CommandHistory.history.size() > 0:
		$CanvasLayer/Input.text = CommandHistory.history[commandHistoryLine]
		$CanvasLayer/Input.call_deferred("set_cursor_position", 9999)
		
func _on_Input_text_entered(new_text): #Gets input text
	$CanvasLayer/Input.clear()
	ProcessCommand(new_text)
	commandHistoryLine = CommandHistory.history.size()

func OutputText(text): #Prints text to console
	$CanvasLayer/Output.text = str($CanvasLayer/Output.text, "\n", text)
	$CanvasLayer/Output.set_v_scroll(9999999)

func ProcessCommand(text): #Processes commands to CommandHandler
	var words = text.split(" ")
	words = Array(words)
	for _i in range(words.count("")):
		words.erase("")
	
	if words.size() == 0:
		return

	CommandHistory.history.append(text)
	
	var commandWord = words.pop_front()
	for c in $CommandHandler.commands:
		if c[0] == commandWord:
			if(c.size() == 1): #If command has no parameters (help)
				OutputText(str($CommandHandler.call(commandWord)))
				return
			if words.size() != c[1].size(): #If command has equal parameters
				OutputText(str('Failure executing command "', commandWord, '", expected ', c[1].size(), ' parameters.'))
				return
			for i in range(words.size()):
				if not CheckType(words[i], c[1][i]):
					OutputText(str('Failure executing command "', commandWord, '", parameter ', (i + 1), '("', words[i], ')" is of the wrong type.'))
					return
			OutputText(str($CommandHandler.callv(commandWord, words)))
			return
	OutputText(str('Command "', commandWord, '" does not exist.'))
	
func CheckType(string, type): #Determines type of parameter
	if type == $CommandHandler.ARG_INT:
		return string.is_valid_integer()
	if type == $CommandHandler.ARG_STRING:
		return true
	if type == $CommandHandler.ARG_BOOL:
		return (string == "true") or (string == "false")
	if type == $CommandHandler.ARG_FLOAT:
		return string.is_valid_float()
	return false

func Delete(): #Closes the console
	queue_free()
