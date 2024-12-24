extends Sprite2D

class_name PioneerModule

signal integrityChanged
signal oxygenChanged

@onready var rightSnapBall = $"../ConnectRight/SnapBall"
@onready var leftSnapBall = $"../ConnectLeft/SnapBall"

@export var MAX_MODULE_OXYGEN: float = 120.0
@export var MAX_MODULE_CO2: float = 50.0
@export var MAX_MODULE_INTEGRITY: float = 50.0
@export var currentIntegrity: float = 50.0

@onready var damaged_timer = $damagedTimer
@onready var hurtBox = $"../CollisionHolder"
@onready var update_timer = $updateTimer

var snapLeft = null
var snapRight = null

var CONNECT_RIGHT = null
var CONNECT_LEFT = null

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
	"right": null
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
			isSnapped = false

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if IS_MOVING:
			IS_MOVING = false
			getallnodes(get_node("/root/Gameplay"))
			rightSnapBall.visible = false
			self.self_modulate.a = 1
			leftSnapBall.visible = false
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
	isSnapped = false  # Reset the overall snap status

# ---------------- DOCKING ---------------- #
func can_connect_to_module(node_name) -> bool:
	for forbidden_node in forbidden_connect_nodes:
		# Check if the node name begins with any of the forbidden node names
		if node_name.begins_with(forbidden_node):
			return false
	return true

func can_dock_to_module(area, source) -> bool:
	var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
	var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)
	print(pma_orientation)
	print(module_orientation)
	
	# Calculate the wrapped sum
	var orientation_sum = fmod(pma_orientation + module_orientation, 360.0)
	print("Orientation sum: ", orientation_sum)
	if (orientation_sum == 90 or orientation_sum == 270) and not (area.name == "ConnectTop" or area.name == "ConnectBottom"):
		return false
	
	if connected_modules[source]:
		return false
	
	if source == "left" and self.get_parent().get_meta("LeftConnect") == false and area.name == "ConnectRight" and area.get_parent().get_meta("RightConnect") == false:
		pass
	elif source == "right" and self.get_parent().get_meta("RightConnect") == false and area.name == "ConnectLeft" and area.get_parent().get_meta("LeftConnect") == false:
		pass
	else:
		print("sorry, all were full")
		return false
	
	if source == "left":
		if area.name == "ConnectLeft" and not area.get_parent().get_meta("LeftConnect") == true:
			# Check if the module and PMA orientations are opposites (180 or 360 degrees)
			if orientation_sum == 180 or orientation_sum == 360 or orientation_sum == 0:
				# Explicitly allow 0 and 180 for "left" connections
				if (pma_orientation == 0 and module_orientation == 180) or (pma_orientation == 180 and module_orientation == 0):
					return true
				# Check for 270 and 90 degrees (rotation difference of 180 degrees)
				if (pma_orientation == 270 and module_orientation == 90) or (pma_orientation == 90 and module_orientation == 270):
					return true
				# Original check for opposite orientations
				if module_orientation - 180 == pma_orientation or module_orientation + 180 == pma_orientation:
					return true
			return false
		elif area.name == "ConnectRight" and not area.get_parent().get_meta("RightConnect") == true:
			if orientation_sum == 180 or orientation_sum == 360 or orientation_sum == 0:
				# Explicitly allow 0 and 180 for "left" connections
				if (pma_orientation == 0 and module_orientation == 180) or (pma_orientation == 180 and module_orientation == 0):
					return false
				# Check for 270 and 90 degrees (rotation difference of 180 degrees)
				if (pma_orientation == 270 and module_orientation == 90) or (pma_orientation == 90 and module_orientation == 270):
					return false
				# Original check for opposite orientations
				if module_orientation - 180 == pma_orientation or module_orientation + 180 == pma_orientation:
					return false
				if (orientation_sum == 180 or orientation_sum == 0 or orientation_sum == 360) and pma_orientation == module_orientation:
					return true
			return false
	elif source == "right":
		if area.name == "ConnectRight" and not area.get_parent().get_meta("RightConnect") == true:
			# Check if the module and PMA orientations are opposites (180 or 360 degrees)
			if orientation_sum == 180 or orientation_sum == 360 or orientation_sum == 0:
				# Check for 270 and 90 degrees (rotation difference of 180 degrees)
				if (pma_orientation == 0 and module_orientation == 180) or (pma_orientation == 180 and module_orientation == 0):
					return true
				if (pma_orientation == 270 and module_orientation == 90) or (pma_orientation == 90 and module_orientation == 270):
					return true
				# Original check for opposite orientations
				if module_orientation - 180 == pma_orientation or module_orientation + 180 == pma_orientation:
					return true
			return false
		elif area.name == "ConnectLeft" and not area.get_parent().get_meta("LeftConnect") == true:
			if orientation_sum == 180 or orientation_sum == 360 or orientation_sum == 0:
				# Explicitly allow 0 and 180 for "left" connections
				if (pma_orientation == 0 and module_orientation == 180) or (pma_orientation == 180 and module_orientation == 0):
					return false
				# Check for 270 and 90 degrees (rotation difference of 180 degrees)
				if (pma_orientation == 270 and module_orientation == 90) or (pma_orientation == 90 and module_orientation == 270):
					return false
				# Original check for opposite orientations
				if module_orientation - 180 == pma_orientation or module_orientation + 180 == pma_orientation:
					return false
				if (orientation_sum == 180 or orientation_sum == 0 or orientation_sum == 360)  and pma_orientation == module_orientation:
					return true
			return false
	return true


func _on_connect_left_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name) and can_dock_to_module(area, "left"):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_LEFT = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["left"] = area.get_parent()
				self.get_parent().set_meta("LeftConnect", true)
				area.get_parent().set_meta("RightConnect", true)

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
					CONNECT_LEFT.x += 94
					if area.get_parent().name == "CollaborationModule":
						CONNECT_LEFT.x += 4
				elif pma_orientation == 90:
					CONNECT_LEFT.y += 94
					CONNECT_LEFT.x += 0
					if area.get_parent().name == "CollaborationModule":
						CONNECT_LEFT.x += 4
				elif pma_orientation == 180:
					CONNECT_LEFT.y += 0
					CONNECT_LEFT.x -= 94
					if area.get_parent().name == "CollaborationModule":
						CONNECT_LEFT.x -= 4
				elif pma_orientation == 270:
					CONNECT_LEFT.y -= 94
					CONNECT_LEFT.x += 0
					if area.get_parent().name == "CollaborationModule":
						CONNECT_LEFT.x -= 4
				print("left")
			return

func _on_connect_right_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name) and can_dock_to_module(area, "right"):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_RIGHT = area.global_position
				#CONNECT_RIGHT += area.get_parent()
				connected_modules["right"] = area.get_parent()
				self.get_parent().set_meta("RightConnect", true)
				area.get_parent().set_meta("LeftConnect", true)

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
					CONNECT_RIGHT.x -= 92
					if area.get_parent().name == "CollaborationModule":
						CONNECT_RIGHT.x -= 4
				elif pma_orientation == 90:
					CONNECT_RIGHT.y -= 92
					CONNECT_RIGHT.x += 0
					if area.get_parent().name == "CollaborationModule":
						CONNECT_RIGHT.x -= 4
				elif pma_orientation == 180:
					CONNECT_RIGHT.y += 1
					CONNECT_RIGHT.x += 92
					if area.get_parent().name == "CollaborationModule":
						CONNECT_RIGHT.x += 4
				elif pma_orientation == 270:
					CONNECT_RIGHT.y += 92
					CONNECT_RIGHT.x += 0
					if area.get_parent().name == "CollaborationModule":
						CONNECT_RIGHT.x += 4
				print("right")
			return


func _physics_process(delta: float) -> void:
	if self.get_parent().get_meta("LeftConnect") == false:
		connected_modules["left"] = null
	elif self.get_parent().get_meta("RightConnect") == false:
		connected_modules["right"] = null
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
	if not isHurt:
		for area in hurtBox.get_overlapping_areas():
			if area.name == "hitBox":
				takeDamage(area)

func custom_disconnect(direction: String) -> void:
	if connected_modules[direction]:
		var disconnected_module = connected_modules[direction]
		reset_snap_variables()  # Reset snap variables when disconnected
		isSnapped = false
		if direction == "left":
			self.get_parent().set_meta("LeftConnect", false)
			disconnected_module.set_meta("RightConnect", false)
		elif direction == "right":
			self.get_parent().set_meta("RightConnect", false)
			disconnected_module.set_meta("LeftConnect", false)
		connected_modules[direction] = null

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
