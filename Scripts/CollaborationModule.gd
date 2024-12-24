extends Sprite2D

class_name CollaborationModule

signal integrityChanged
signal oxygenChanged

@onready var rightSnapBall = $"../ConnectRight/SnapBall"
@onready var leftSnapBall = $"../ConnectLeft/SnapBall"
@onready var topSnapBall = $"../ConnectTop/SnapBall"
@onready var bottomSnapBall = $"../ConnectBottom/SnapBall"

@export var MAX_MODULE_OXYGEN: float = 80.0
@export var MAX_MODULE_CO2: float = 40.0
@export var MAX_MODULE_INTEGRITY: float = 50.0
@export var currentIntegrity: float = 50.0

@onready var damaged_timer = $damagedTimer
@onready var hurtBox = $"../CollisionHolder"
@onready var update_timer = $updateTimer

var snapLeft = null
var snapRight = null
var snapTop = null
var snapBottom = null

var CONNECT_RIGHT = null
var CONNECT_LEFT = null
var CONNECT_TOP = null
var CONNECT_BOTTOM = null

var isSnapped = false
var IS_MOVING = true
var holdingShift = false

var isHurt: bool = false
var TimeInSeconds = 5
var has_rotated = false

var CURRENT_MODULE_OXYGEN: float = 120.0
var CURRENT_MODULE_CO2: float = 0.0
var OXYGEN_USAGE: float = 0.0
var CO2_USAGE: float = 0.0

var connected_modules: Dictionary = {
	"left": null,
	"right": null,
	"top": null,
	"bottom": null
}

# Array to store node names the module cannot connect to, but can be connected to
var forbidden_connect_nodes = ["PMA"]

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		if keycode == KEY_Q:
			if not has_rotated and IS_MOVING and Global.BUILD_MODE_ENABLED:
				get_parent().rotation_degrees -= 90
				if get_parent().rotation_degrees < 0:
					get_parent().rotation_degrees = 270
				has_rotated = true
				print(get_parent().rotation_degrees)
		elif keycode == KEY_E:
			if not has_rotated and IS_MOVING and Global.BUILD_MODE_ENABLED:
				get_parent().rotation_degrees += 90
				if get_parent().rotation_degrees > 270:
					get_parent().rotation_degrees = 0
				has_rotated = true
				print(get_parent().rotation_degrees)
		if keycode == KEY_SHIFT:
			holdingShift = true
		if not event.pressed and (keycode == KEY_Q or keycode == KEY_E):
			has_rotated = false
		if not event.pressed:
			holdingShift = false
			CONNECT_LEFT = null
			CONNECT_RIGHT = null
			CONNECT_TOP = null
			CONNECT_BOTTOM = null
			isSnapped = false

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if IS_MOVING:
			IS_MOVING = false
			getallnodes(get_node("/root/Gameplay"))
			rightSnapBall.visible = false
			self.self_modulate.a = 1
			leftSnapBall.visible = false
			topSnapBall.visible = false
			bottomSnapBall.visible = false
			Global.ITEM_HELD = null
			await get_tree().create_timer(0.25).timeout
			Global.CAN_PICKUP = true
			Global.HOLDING_ITEM = false
		elif Global.BUILD_MODE_ENABLED and Global.CAN_PICKUP:
			if get_rect().has_point(to_local(get_global_mouse_position())):
				if connected_modules["left"]:
					custom_disconnect("left")
				if connected_modules["right"]:
					custom_disconnect("right")
				if connected_modules["top"]:
					custom_disconnect("top")
				if connected_modules["bottom"]:
					custom_disconnect("bottom")
				IS_MOVING = true
				Global.CAN_PICKUP = false
				self.self_modulate.a = 0.5
				Global.ITEM_HELD = self.get_parent()
				reset_snap_variables()  # Reset snap variables before moving the module

func _ready() -> void:
	Global.TOTAL_OXYGEN += CURRENT_MODULE_OXYGEN
	Global.TOTAL_CO2 += CURRENT_MODULE_CO2
	Global.MAX_OXYGEN += MAX_MODULE_OXYGEN
	Global.MAX_CO2 += MAX_MODULE_CO2
	if Global.BUILD_MODE_ENABLED:
		self.self_modulate.a = 0.5


func reset_snap_variables() -> void:
	# Reset the snap variables
	snapLeft = null
	snapRight = null
	snapTop = null
	snapBottom = null
	isSnapped = false  # Reset the overall snap status

# ---------------- DOCKING ---------------- #
func can_connect_to_module(node_name: String) -> bool:
	for forbidden_node in forbidden_connect_nodes:
		# Check if the node name begins with any of the forbidden node names
		if node_name.begins_with(forbidden_node):
			return false
	return true

func _on_connect_left_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_LEFT = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["left"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x, area.position.y)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print(pma_orientation)
				if pma_orientation == 0:
					CONNECT_LEFT.y += 0
					CONNECT_LEFT.x += 77
				elif pma_orientation == 90:
					CONNECT_LEFT.y += 77
					CONNECT_LEFT.x += 0
				elif pma_orientation == 180:
					CONNECT_LEFT.y += 0
					CONNECT_LEFT.x -= 77
				elif pma_orientation == 270:
					CONNECT_LEFT.y -= 77
					CONNECT_LEFT.x += 0
				print("left")
				return

func _on_connect_right_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_RIGHT = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["right"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x, area.position.y)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print(pma_orientation)
				if pma_orientation == 0:
					CONNECT_RIGHT.y += 0
					CONNECT_RIGHT.x -= 77
				elif pma_orientation == 90:
					CONNECT_RIGHT.y -= 77
					CONNECT_RIGHT.x += 0
				elif pma_orientation == 180:
					CONNECT_RIGHT.y += 1
					CONNECT_RIGHT.x += 77
				elif pma_orientation == 270:
					CONNECT_RIGHT.y += 77
					CONNECT_RIGHT.x += 0
				print("right")
				return

func _on_connect_top_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_TOP = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["top"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x, area.position.y)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print(pma_orientation)
				if pma_orientation == 0:
					CONNECT_TOP.y += 46
					CONNECT_TOP.x -= 20
				elif pma_orientation == 90:
					CONNECT_TOP.y -= 20
					CONNECT_TOP.x -= 46
				elif pma_orientation == 180:
					CONNECT_TOP.y -= 46
					CONNECT_TOP.x += 20
				elif pma_orientation == 270:
					CONNECT_TOP.y += 20
					CONNECT_TOP.x += 46
				print("top")
				return

func _on_connect_bottom_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_BOTTOM = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["bottom"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x, area.position.y)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print(pma_orientation)
				if pma_orientation == 0:
					CONNECT_BOTTOM.y -= 46
					CONNECT_BOTTOM.x -= 20
				elif pma_orientation == 90:
					CONNECT_BOTTOM.y -= 20
					CONNECT_BOTTOM.x += 46
				elif pma_orientation == 180:
					CONNECT_BOTTOM.y += 46
					CONNECT_BOTTOM.x += 20
				elif pma_orientation == 270:
					CONNECT_BOTTOM.y += 20
					CONNECT_BOTTOM.x -= 46
				print("bottom")
				return

# TRY JUST SETTING POSITION BASED ON PMA ORIENTATION, THEN NEST CHECKS FOR AREA NAME

func _physics_process(delta: float) -> void:
	if IS_MOVING:
		getallnodes(get_node("/root/Gameplay"))
		rightSnapBall.visible = true
		leftSnapBall.visible = true
		if not isSnapped:
			get_parent().position = get_global_mouse_position()
	if CONNECT_RIGHT:
		get_parent().position = CONNECT_RIGHT
		isSnapped = true
		CONNECT_RIGHT = null
		Global.HOLDING_ITEM = false
	if CONNECT_LEFT:
		get_parent().position = CONNECT_LEFT
		isSnapped = true
		CONNECT_LEFT = null
		Global.HOLDING_ITEM = false
	if CONNECT_TOP:
		get_parent().position = CONNECT_TOP
		isSnapped = true
		CONNECT_TOP = null
		Global.HOLDING_ITEM = false
	if CONNECT_BOTTOM:
		get_parent().position = CONNECT_BOTTOM
		isSnapped = true
		CONNECT_BOTTOM = null
		Global.HOLDING_ITEM = false
	if not isHurt:
		for area in hurtBox.get_overlapping_areas():
			if area.name == "hitBox":
				takeDamage(area)

func custom_disconnect(direction: String) -> void:
	if connected_modules[direction]:
		var disconnected_module = connected_modules[direction]
		connected_modules[direction] = null
		reset_snap_variables()  # Reset snap variables when disconnected
		isSnapped = false

func takeDamage(area: Node) -> void:
	currentIntegrity -= 5
	if currentIntegrity < 0:
		currentIntegrity = MAX_MODULE_INTEGRITY
	
	isHurt = true
	integrityChanged.emit()
	damaged_timer.start()
	await damaged_timer.timeout
	isHurt = false

func getallnodes(node: Node) -> void:
	for N in node.get_children():
		if N.get_child_count() > 0 && N.name != "SnapBall" && can_connect_to_module(N.name):
			getallnodes(N)
		else:
			if N.name == "SnapBall":
				if Global.BUILD_MODE_ENABLED == true && IS_MOVING == true:
					N.visible = true
				else:
					N.visible = false
