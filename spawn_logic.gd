extends Node2D

@export var foot_hazard_scene: PackedScene
@export var floor_y: float = 240.0
@onready var hazard_timer: Timer = $HazardTimer

var survival_time =  0.0
var telegraph_duration = 1.8
var spawn_interval = 2.2
var targeted_chance = 0.0
var max_simultaneous_drops = 1 

const MIN_SPAWN_X = 50.0
const MAX_SPAWN_X = 430.0
const MIN_SHOE_SEPARATION = 75.0

var player_ref: Node2D = null


func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	
	hazard_timer.one_shot = false
	hazard_timer.wait_time = spawn_interval
	hazard_timer.timeout.connect(_on_hazard_timer_timeout)
	hazard_timer.start()
	
func _process(_delta: float) -> void:
	survival_time += _delta
	update_difficulty_curve() 
	
func update_difficulty_curve() -> void:
	if survival_time < 15.0:
		spawn_interval = 2.2
		telegraph_duration = 1.8
		targeted_chance = 0.0
		max_simultaneous_drops = 1
	elif survival_time < 35.0:
		spawn_interval = 1.2
		telegraph_duration = 1.0
		targeted_chance = 0.3
		max_simultaneous_drops = randi_range(1, 2)
	elif survival_time < 60.0:
		spawn_interval = 0.9
		telegraph_duration = 0.9
		targeted_chance = 0.5
		max_simultaneous_drops = 2
	elif survival_time < 90.0:
		spawn_interval = 0.7
		telegraph_duration = 0.7
		targeted_chance = 0.75
		max_simultaneous_drops = randi_range(2, 3)
	else:
		spawn_interval = 0.5
		telegraph_duration = 0.5
		targeted_chance = 0.9
		max_simultaneous_drops = 3
		
	if abs(hazard_timer.wait_time - spawn_interval) > 0.1:
		hazard_timer.wait_time = spawn_interval
		
func _on_hazard_timer_timeout() -> void:
	if not foot_hazard_scene:
		return
		
	var spawn_positions: Array[float] = []
	var drop_count : int = max_simultaneous_drops
	
	# Determine first drop position (Targeted vs Random)
	var first_x: float
	if player_ref and randf() < targeted_chance:
		first_x = clampf(player_ref.global_position.x, MIN_SPAWN_X, MAX_SPAWN_X)
	else:
		first_x = randf_range(MIN_SPAWN_X, MAX_SPAWN_X)
	
	spawn_positions.append(first_x)
	
	# Determine secondary drops without directly stacking them
	for i in range(1, drop_count):
		var candidate_x := randf_range(MIN_SPAWN_X, MAX_SPAWN_X)
		var valid := true
		for existing_x in spawn_positions:
			if abs(candidate_x - existing_x) < MIN_SHOE_SEPARATION:
				valid = false
				break
		if valid:
			spawn_positions.append(candidate_x)
	
	for x_pos in spawn_positions:
		instantiate_foot(x_pos)
		
func instantiate_foot(spawn_x: float) -> void:
	var hazard = foot_hazard_scene.instantiate()
	hazard.global_position = Vector2(spawn_x, floor_y)  # Must take exactly 2 arguments (x and y)
	get_parent().add_child(hazard)
	
	if "telegraph_time" in hazard:
		hazard.telegraph_time = telegraph_duration
	

		
	
	
	
	
