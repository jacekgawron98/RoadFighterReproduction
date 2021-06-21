extends Node2D

export var nam = ""
export var max_enemies = 0
export (Array, PackedScene) var enemies = []
export (Array, PackedScene) var next_segments = []
export (Array, int) var next_segments_chance = []
export var middle_offset = 0

var instanced_enemies = []
var rng


func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var number_of_enemies = rng.randi_range(0,max_enemies)
	for i in range(number_of_enemies):
		var shape = $SpawnArea2D/SpawnArea.shape.extents
		var pos_x = rng.randf_range(-shape.x, shape.x)
		var pos_y = rng.randf_range(-shape.y, shape.y)
		instanced_enemies.push_back(generate_enemy())
		instanced_enemies.back().position = Vector2(pos_x,pos_y)
		add_child(instanced_enemies.back())
		
#func _process(delta):
#	pass

func update_position(speed):
	position.y += speed
	for enemy in instanced_enemies:
		if(enemy != null):
			enemy.modify_velocity(speed)

func generate_enemy():
	var total_chance = 0
	for enemy in enemies:
		total_chance += enemy.instance().spawn_chance
	var random = rng.randi_range(0,total_chance)
	for i in range(enemies.size()):
		if(enemies[i].instance().spawn_chance == 0): continue
		if(random <= enemies[i].instance().spawn_chance):
			return enemies[i].instance()
		else:
			total_chance -= enemies[i].instance().spawn_chance
			random = rng.randi_range(0,total_chance)

func _on_FinishLine_area_entered(area):
	if(area.is_in_group("player")):
		area.finished()

func _on_Area2D_body_entered(body):
	if(body.is_in_group("player")):
		body.destroy()

func _on_FinishLine_body_entered(body):
	if(body.is_in_group("player")):
		body.finished()


func _on_LeftArea2D_body_entered(body):
	if(body.is_in_group("player")):
		body.destroy()


func _on_newMiddle_body_entered(body):
	if(body.is_in_group("player")):
		body.change_middle(middle_offset)
