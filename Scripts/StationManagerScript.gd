extends Node

@onready var OxDecTimer = $OxygenDecreaseTimer

var MAX_OXYGEN: float = 0.0
var MAX_CO2: float = 0.0

var TOTAL_OXYGEN: float = 0.0
var TOTAL_CO2: float = 0.0

func _ready():
	OxDecTimer.start()         

func _on_oxygen_decrease_timer_timeout():
	if TOTAL_OXYGEN > 0:
		TOTAL_OXYGEN -= 1
	if TOTAL_CO2 < 50:
		TOTAL_CO2 += 1
	OxDecTimer.start()
