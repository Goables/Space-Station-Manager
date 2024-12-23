extends Camera2D
var _target_zoom: float = 1.5
const MIN_ZOOM: float = 0.75
const MAX_ZOOM: float = 2.5
const ZOOM_INCREMENT: float = 0.1
const ZOOM_RATE: float = 5.0

# Use for zooming to show interior/exterior of modules
# 	print(get_node("/root/Gameplay/Station/PioneerModule1/StationModule1"))

# Define the module names and their corresponding textures
var modules = [
	{
		"name": "PioneerModule",
		"interior_texture": preload("res://Textures/Station Module 1 Interior.png"),
		"exterior_texture": preload("res://Textures/Station Module 1.png")
	},
	{
		"name": "CollaborationModule",
		"interior_texture": preload("res://Textures/Station Module 2 Interior.png"),
		"exterior_texture": preload("res://Textures/Station Module 2.png")
	}
]

# Function to change the sprite texture
func change_sprite(node, texture):
	if node.has_node("StationModule"):
		var sprite = node.get_node("StationModule")
		if sprite is Sprite2D:
			sprite.texture = texture

# Function to update all station sprites based on the zoom level
func update_station_sprites(target_zoom):
	var station_node = get_node("/root/Gameplay/Station")
	if station_node == null:
		print("Station node not found!")
		return

	for module_node in station_node.get_children():
		for module in modules:
			# Use `begins_with()` to match partial names
			if module_node.name.begins_with(module["name"]):
				var texture = module["interior_texture"] if target_zoom >= 2.0 else module["exterior_texture"]
				change_sprite(module_node, texture)


func _physics_process(delta: float) -> void:
	zoom = lerp(
		zoom,
		_target_zoom * Vector2.ONE,
		ZOOM_RATE * delta
	)
	set_physics_process(
		not is_equal_approx(zoom.x, _target_zoom)
	)

func zoom_in() -> void:
	_target_zoom = max(_target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_out() -> void:
	_target_zoom = min(_target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()
			update_station_sprites(_target_zoom)
	if event is InputEventMouseMotion:
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			# Adjust the middle mouse motion sensitivity based on zoom level
			var zoom_factor = 2.0 / zoom.x  # The smaller the zoom, the faster the movement
			position -= event.relative * (zoom_factor * 0.2)
