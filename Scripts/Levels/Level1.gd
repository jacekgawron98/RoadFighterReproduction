extends Node2D

export (Array, PackedScene) var startSegments = []
export (Array, PackedScene) var middleSegments = []
export (Array, Array, int) var middleSegmentsChances = []
export (Array, PackedScene) var endSegments = []

var segments = []
var instancedSegments = []
var screen_size
var player
var rng

var race_length
var cur_race_len = 0

export var max_fuel = 100
var current_fuel

export var accelerate_rate = 5
export var break_rate = 10

var speed = 0
var max_speed = 6

var has_started = false

var game_finished = false
var game_over = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/LevelUI/FinishMsg.visible = false
	screen_size = get_viewport_rect().size
	rng = RandomNumberGenerator.new()
	rng.randomize()
	segments.append_array(startSegments)
	for i in range(100):
		var seg_index = find_next_segment_index(segments.back())
		segments.append(middleSegments[seg_index])
	segments.append_array(endSegments)
	
	for i in range(segments.size()):
		instancedSegments.push_back(segments[i].instance())
		instancedSegments.back().position = Vector2(screen_size.x/2,screen_size.y/2 - screen_size.y * i)
		add_child(instancedSegments.back())
	pass
	
	race_length = (segments.size()+1) * screen_size.y
	current_fuel = max_fuel
	
	var player_scene = load("res://Player.tscn")
	player = player_scene.instance()
	add_child(player)
	player.connect("finished", self, "on_game_finished")
	player.connect("fuel_get", self, "add_fuel")
	player.position = Vector2(screen_size.x/2,screen_size.y/2 + 220)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!game_over && !game_finished):
		move_track(delta)
		check_fuel(delta)

func find_next_segment_index(last_segment):
	var index  = middleSegments.find(last_segment)
	if(index > -1):
		var chance_sum = 0
		for chance in middleSegmentsChances[index]:
			chance_sum += chance
		var random = rng.randi_range(0,chance_sum)
		for i in range(middleSegments.size()):
			if(middleSegmentsChances[index][i] == 0): continue
			if(random <= middleSegmentsChances[index][i]):
				return i
			else:
				chance_sum -= middleSegmentsChances[index][i]
				random = rng.randi_range(0,chance_sum)
	return 0

func move_track(delta):
	if(Input.is_action_pressed("ui_up") && !player.is_destroyed && player.slide == 0):
		has_started = true
		speed += accelerate_rate * delta
	else:
		speed -= break_rate * delta 
	speed = clamp(speed,0,max_speed)
	cur_race_len += speed
	$CanvasLayer/LevelUI.update_progress(speed,race_length)
	$CanvasLayer/LevelUI.update_speed_label(speed,max_speed)
	for seg in instancedSegments:
		seg.update_position(speed)

func check_fuel(delta):
	if(has_started):
		current_fuel -= delta
		$CanvasLayer/LevelUI.update_fuel_label(current_fuel,max_fuel)
		if(current_fuel <= 0):
			gameover()

func add_fuel():
	var amount_to_add = 0.05 * max_fuel
	current_fuel = clamp(current_fuel + amount_to_add,0,max_fuel)

func gameover():
	game_over = true
	player.has_finished = true
	$CanvasLayer/LevelUI/FinishMsg.text = "GAME OVER!"
	$CanvasLayer/LevelUI/FinishMsg.visible = true
	$GameResetTimer.start()
	

func on_game_finished():
	game_finished = true
	$CanvasLayer/LevelUI/FinishMsg.text = "YOU WON!"
	$CanvasLayer/LevelUI/FinishMsg.visible = true
	$GameResetTimer.start()
	
func reset_game():
	get_tree().change_scene("res://MainMenu.tscn")
