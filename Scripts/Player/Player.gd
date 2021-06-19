extends KinematicBody2D

export var maxSpeed = 400
export var slide_rate = 40
var cur_slide_rate
var currentSpeed = 0
var screen_size 

var is_destroyed = false
var has_finished = false

var destroy_delay = 2
var cur_destroy_delay = 0

var slide = 0
var critical_slide = false;

signal finished
signal fuel_get

func _ready():
	cur_slide_rate = slide_rate
	screen_size = get_viewport_rect().size

func _physics_process(delta):
	var velocity = Vector2()
	if(slide == 0):
		if(!is_destroyed && !has_finished):
			if(Input.is_action_pressed("ui_right")):
				velocity.x += 1
			if(Input.is_action_pressed("ui_left")):
				velocity.x -= 1
			if(velocity.length() > 0):
				velocity = velocity.normalized() * maxSpeed
				
			move_and_slide(velocity)
		else:
			reset(delta)
	else:
		if(!is_destroyed && !has_finished):
			velocity.x = cur_slide_rate * slide
			position += velocity * delta
			if(!critical_slide):
				if(Input.is_action_pressed("ui_right")):
					if(slide == -1):
						slide = 0
					elif(slide == 1):
						cur_slide_rate *= 3
						critical_slide = true
				if(Input.is_action_pressed("ui_left")):
					if(slide == -1):
						cur_slide_rate *= 3
						critical_slide = true
					elif(slide == 1):
						slide = 0
		else:
			reset(delta)

func slide(enemy_position):
	print(String(enemy_position.x) + " " + String(position.x))
	if(enemy_position.x <= position.x):
		slide = 1
	else:
		slide = -1

func add_fuel():
	emit_signal("fuel_get")

func destroy():
	cur_destroy_delay = 0
	is_destroyed = true
	$AnimatedSprite.animation = "explode"
	
func reset(delta):
	slide = 0
	cur_slide_rate = slide_rate
	critical_slide = false
	cur_destroy_delay += delta
	if(cur_destroy_delay >= destroy_delay):
		$AnimatedSprite.animation = "default"
		is_destroyed = false
		if(!has_finished):
			position.x = screen_size.x/2

func finished():
	has_finished = true
	emit_signal("finished")
