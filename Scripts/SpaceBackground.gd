extends ParallaxBackground
@onready var stars_layer = %StarsLayer
@onready var space_layer: ParallaxLayer = %SpaceLayer
@onready var camera = $"../Camera2D"

func _process(delta: float) -> void:
	stars_layer.motion_offset.x -= 20 * delta
