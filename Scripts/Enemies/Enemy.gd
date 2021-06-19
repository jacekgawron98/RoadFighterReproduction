extends KinematicBody2D

export var spawn_chance = 100
export var is_fuel = false
export var is_truck = false
export var is_static = false
var has_started = false
var velocity = 0

func _ready():
	if(is_fuel):
		$CollisionShape2D.disabled = true

func _process(delta):
	if(!is_static):
		if(has_started):
			move_and_slide(Vector2(0,-600))
		#position.y += velocity
		move_and_slide(Vector2(0,velocity + 6))
		if(global_position.y >= -500 && !has_started):
			has_started = true
		
		if((has_started && global_position.y <= -1000) || global_position.y >= 1000):
			$Area2D.monitoring = false
			$CollisionShape2D.disabled = true
			set_process(false)
			hide()

func modify_velocity(speed):
	if(speed == 0 && has_started):
		velocity = -6
		return
	velocity = -5.5 + speed

func _on_Area2D_body_entered(body):
	if(body.is_in_group("player")):
		if(is_fuel):
			body.add_fuel()
			hide()
			return
		if(is_truck):
			print("col")
			body.destroy()
		else:
			body.slide(global_position)
