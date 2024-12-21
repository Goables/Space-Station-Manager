extends Sprite2D

class_name PioneerModule

signal integrityChanged 
signal oxygenChanged 

@export var MAX_MODULE_OXYGEN: float = 120.0
@export var MAX_MODULE_CO2: float = 50.0
@export var MAX_MODULE_INTEGRITY: float = 50.0
@export var currentIntegrity: float = 50.0

@onready var damaged_timer = $damagedTimer
@onready var hurtBox = $"../CollisionHolder"

var isHurt: bool = false
var TimeInSeconds = 5

var CURRENT_MODULE_OXYGEN: float = 120.0
var CURRENT_MODULE_CO2: float = 0.0

func _ready():
	Global.TOTAL_OXYGEN += CURRENT_MODULE_OXYGEN
	Global.TOTAL_CO2 += CURRENT_MODULE_CO2
	
	Global.MAX_OXYGEN += MAX_MODULE_OXYGEN
	Global.MAX_CO2 += MAX_MODULE_CO2

func _physics_process(delta):
	if !isHurt:
		hurtBox
		for area in hurtBox.get_overlapping_areas():
			if area.name == "hitBox":
				takeDamage(area)

func takeDamage(area):
	currentIntegrity -= 5
	if currentIntegrity < 0:
		currentIntegrity = MAX_MODULE_INTEGRITY
	
	isHurt = true
	integrityChanged.emit()
	damaged_timer.start()
	await damaged_timer.timeout
	isHurt = false
