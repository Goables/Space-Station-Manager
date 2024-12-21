extends TextureRect
# CO2 Dial Arrow

@onready var arrow = $"."

func _physics_process(delta):
	update_dial()

func update_dial():
	var min_angle = -118
	var max_angle = 124
	var angle_range = max_angle - min_angle
	
	# Calculate the angle dynamically
	arrow.rotation_degrees = min_angle + (Global.TOTAL_CO2 / Global.MAX_CO2) * angle_range
