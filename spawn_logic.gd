extends Node2D

@export var foor_hazard_scene: PackedScene
@export var floor_y = 240.0
@onready var hazard_timer: Timer = $HazardTimer

var survival_time =  0.0
var telegraph_duration = 1.8
var spawn_interval = 2.2
var targeted_chance = 0.0
var max_simultaneous_drops = 1 

const MIN_SPAWN_X = 50.0
const MAX_SPAWN_X = 430.0
const MIN_SHOE_SEPERATION = 75.0

var player_ref: Node2D = null
