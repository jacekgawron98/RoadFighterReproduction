extends Control

var blink_time = 0
var max_blink = 0.7
var starting = false
var start_delay = 1.5

func _ready():
	pass

func _process(delta):
	blink_time += delta
	if(Input.is_action_pressed("ui_accept")):
		max_blink = 0.1
		starting = true
	if(blink_time > max_blink):
		$Info.visible = !$Info.visible
		blink_time = 0
	if(starting):
		start_delay	-= delta
		if(start_delay <= 0):
			start_game()

func start_game():
	get_tree().change_scene("res://Level1.tscn")
