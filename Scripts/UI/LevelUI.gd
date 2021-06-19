extends Control

var screen_size

func _ready():
	screen_size = get_viewport_rect().size

func update_progress(move_val, total_len):
	var ratio = move_val/total_len
	var move = screen_size.y * ratio
	$ProgressRect/ProgressSprite.position.y -= move
	$ProgressRect/ProgressSprite.position.y = clamp($ProgressRect/ProgressSprite.position.y,20,580)

func update_speed_label(speed,max_speed):
	var speed_to_write = speed/max_speed * 400
	$StatsRect/SpeedLabel.text = String(int(speed_to_write)) + "km\\h"

func update_fuel_label(fuel,max_fuel):
	var fuel_to_write = fuel/max_fuel * 100
	$StatsRect/FuelLabel.text = String(int(fuel_to_write)) + "%"
