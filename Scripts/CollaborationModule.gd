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
				CONNECT_LEFT = area_parent_position
				connected_modules["left"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x * 2.0, area.position.y * 2.0)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print("left")
				if area.get_parent().name.begins_with("PioneerModule"):
					# Adjust offset based on the module's orientation and PMA's orientation
					if module_orientation == 0:
						if pma_orientation == 0:
							CONNECT_LEFT.x += rotated_offset.x*0.94
							CONNECT_LEFT.y -= rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 180:
							CONNECT_LEFT.x -= rotated_offset.x*0.88
							CONNECT_LEFT.y += rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_LEFT = null
							return
					elif module_orientation == 90:
						if pma_orientation == 0:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 90:
							CONNECT_LEFT.x += rotated_offset.x
							CONNECT_LEFT.y += rotated_offset.y*0.94
						elif pma_orientation == 180:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 270:
							CONNECT_LEFT.x += rotated_offset.x
							CONNECT_LEFT.y -= rotated_offset.y*0.89
					elif module_orientation == 180:
						if pma_orientation == 0:
							CONNECT_LEFT.x -= rotated_offset.x*0.89
							CONNECT_LEFT.y += rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 180:
							CONNECT_LEFT.x += rotated_offset.x*0.94
							CONNECT_LEFT.y += rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_LEFT = null
							return
					elif module_orientation == 270:
						if pma_orientation == 0:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 90:
							CONNECT_LEFT.x -= rotated_offset.x
							CONNECT_LEFT.y -= rotated_offset.y*0.89
						elif pma_orientation == 180:
							CONNECT_LEFT = null
							return
						elif pma_orientation == 270:
							CONNECT_LEFT.x -= rotated_offset.x
							CONNECT_LEFT.y += rotated_offset.y*0.94
				elif area.get_parent().name.begins_with("CollaborationModule"):
					if module_orientation == 0:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.22
								CONNECT_LEFT.y += rotated_offset.y*3.2
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.22
								CONNECT_LEFT.y += rotated_offset.y*3.2
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*1.0
								CONNECT_LEFT.y -= rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_LEFT.x -= rotated_offset.x*1.0
								CONNECT_LEFT.y += rotated_offset.y
					elif module_orientation == 90:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*3.2
								CONNECT_LEFT.y -= rotated_offset.y*0.21
							elif pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*3.2
								CONNECT_LEFT.y -= rotated_offset.y*0.21
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_LEFT.x += rotated_offset.x
								CONNECT_LEFT.y += rotated_offset.y*1
							elif pma_orientation == 270:
								CONNECT_LEFT.x += rotated_offset.x
								CONNECT_LEFT.y -= rotated_offset.y*1.12
					elif module_orientation == 180:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.21
								CONNECT_LEFT.y += rotated_offset.y*3.2
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.21
								CONNECT_LEFT.y += rotated_offset.y*3.2
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x -= rotated_offset.x*1
								CONNECT_LEFT.y += rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*1
								CONNECT_LEFT.y += rotated_offset.y
					elif module_orientation == 270:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*3.25
								CONNECT_LEFT.y -= rotated_offset.y*0.22
							elif pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*3.25
								CONNECT_LEFT.y -= rotated_offset.y*0.22
						elif area.name == "ConnectRight" or area.name == "ConnectLeft":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x
								CONNECT_LEFT.y -= rotated_offset.y*1
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x
								CONNECT_LEFT.y += rotated_offset.y*1

func _on_connect_right_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_RIGHT = area_parent_position
				connected_modules["right"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x * 2.0, area.position.y * 2.0)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print("right")
				if area.get_parent().name == "PioneerModule":
					# Adjust offset based on the module's orientation and PMA's orientation for the right side
					if module_orientation == 0:
						if pma_orientation == 0:
							CONNECT_RIGHT.x += rotated_offset.x*0.88
							CONNECT_RIGHT.y -= rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 180:
							CONNECT_RIGHT.x -= rotated_offset.x*0.94
							CONNECT_RIGHT.y -= rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_RIGHT = null
							return
					elif module_orientation == 90:
						if pma_orientation == 0:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 90:
							CONNECT_RIGHT.x -= rotated_offset.x
							CONNECT_RIGHT.y += rotated_offset.y*0.89
						elif pma_orientation == 180:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 270:
							CONNECT_RIGHT.x -= rotated_offset.x
							CONNECT_RIGHT.y -= rotated_offset.y*0.94
					elif module_orientation == 180:
						if pma_orientation == 0:
							CONNECT_RIGHT.x -= rotated_offset.x*0.94
							CONNECT_RIGHT.y -= rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 180:
							CONNECT_RIGHT.x += rotated_offset.x*0.89
							CONNECT_RIGHT.y -= rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_RIGHT = null
							return
					elif module_orientation == 270:
						if pma_orientation == 0:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 90:
							CONNECT_RIGHT.x += rotated_offset.x
							CONNECT_RIGHT.y -= rotated_offset.y*0.94
						elif pma_orientation == 180:
							CONNECT_RIGHT = null
							return
						elif pma_orientation == 270:
							CONNECT_RIGHT.x += rotated_offset.x
							CONNECT_RIGHT.y += rotated_offset.y*0.89
				elif area.get_parent().name == "CollaborationModule":
					if module_orientation == 0:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_RIGHT.x += rotated_offset.x*0.22
								CONNECT_RIGHT.y -= rotated_offset.y*3.2
							elif pma_orientation == 270:
								CONNECT_RIGHT.x += rotated_offset.x*0.22
								CONNECT_RIGHT.y -= rotated_offset.y*3.2
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_RIGHT.x += rotated_offset.x*1.0
								CONNECT_RIGHT.y -= rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_RIGHT.x -= rotated_offset.x*1.0
								CONNECT_RIGHT.y -= rotated_offset.y
					elif module_orientation == 90:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_RIGHT.x -= rotated_offset.x*3.2
								CONNECT_RIGHT.y += rotated_offset.y*0.21
							elif pma_orientation == 180:
								CONNECT_RIGHT.x -= rotated_offset.x*3.2
								CONNECT_RIGHT.y += rotated_offset.y*0.21
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_RIGHT.x += rotated_offset.x*1
								CONNECT_RIGHT.y -= rotated_offset.y*0.8
							elif pma_orientation == 270:
								CONNECT_RIGHT.x += rotated_offset.x*2
								CONNECT_RIGHT.y -= rotated_offset.y*1
					elif module_orientation == 180:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_RIGHT.x += rotated_offset.x*0.21
								CONNECT_RIGHT.y -= rotated_offset.y*3.2
							elif pma_orientation == 270:
								CONNECT_RIGHT.x += rotated_offset.x*0.21
								CONNECT_RIGHT.y -= rotated_offset.y*3.2
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_RIGHT.x -= rotated_offset.x*1
								CONNECT_RIGHT.y += rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_RIGHT.x += rotated_offset.x*1
								CONNECT_RIGHT.y += rotated_offset.y
					elif module_orientation == 270:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_RIGHT.x -= rotated_offset.x*3.25
								CONNECT_RIGHT.y += rotated_offset.y*0.22
							elif pma_orientation == 180:
								CONNECT_RIGHT.x -= rotated_offset.x*3.25
								CONNECT_RIGHT.y += rotated_offset.y*0.21
						elif area.name == "ConnectRight" or area.name == "ConnectLeft":
							if pma_orientation == 90:
								CONNECT_RIGHT.x -= rotated_offset.x
								CONNECT_RIGHT.y -= rotated_offset.y*1
							elif pma_orientation == 270:
								CONNECT_RIGHT.x -= rotated_offset.x
								CONNECT_RIGHT.y += rotated_offset.y*1

func _on_connect_top_area_entered(area):
	if self.get_parent() == Global.ITEM_HELD:
		if can_connect_to_module(area.get_parent().name):
			if holdingShift == true and not isSnapped:
				# Convert positions to world space
				var parent_position = self.get_parent().global_position
				var area_parent_position = area.get_parent().global_position
				CONNECT_TOP = area_parent_position
				connected_modules["top"] = area.get_parent()

				# Get the PMA and module orientations
				var pma_orientation = fmod(self.get_parent().rotation_degrees, 360.0)
				var module_orientation = fmod(area.get_parent().rotation_degrees, 360.0)

				# Calculate local offset for the connecting area
				var local_offset = Vector2(area.position.x * 2.0, area.position.y * 2.0)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				print("top")
				if area.get_parent().name == "PioneerModule":
					# Adjust offset based on the module's orientation and PMA's orientation for the right side
					if module_orientation == 0:
						if pma_orientation == 0:
							CONNECT_TOP.x += rotated_offset.x*0.88
							CONNECT_TOP.y -= rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_TOP = null
							return
						elif pma_orientation == 180:
							CONNECT_TOP.x -= rotated_offset.x*0.94
							CONNECT_TOP.y -= rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_TOP = null
							return
					elif module_orientation == 90:
						if pma_orientation == 0:
							CONNECT_TOP = null
							return
						elif pma_orientation == 90:
							CONNECT_TOP.x -= rotated_offset.x
							CONNECT_TOP.y += rotated_offset.y*0.97
						elif pma_orientation == 180:
							CONNECT_TOP = null
							return
						elif pma_orientation == 270:
							CONNECT_TOP.x -= rotated_offset.x
							CONNECT_TOP.y -= rotated_offset.y*1.03
					elif module_orientation == 180:
						if pma_orientation == 0:
							CONNECT_TOP.x -= rotated_offset.x*1.03
							CONNECT_TOP.y -= rotated_offset.y
						elif pma_orientation == 90:
							CONNECT_TOP = null
							return
						elif pma_orientation == 180:
							CONNECT_TOP.x += rotated_offset.x*0.97
							CONNECT_TOP.y -= rotated_offset.y
						elif pma_orientation == 270:
							CONNECT_TOP = null
							return
					elif module_orientation == 270:
						if pma_orientation == 0:
							CONNECT_TOP = null
							return
						elif pma_orientation == 90:
							CONNECT_TOP.x += rotated_offset.x
							CONNECT_TOP.y -= rotated_offset.y*1.03
						elif pma_orientation == 180:
							CONNECT_TOP = null
							return
						elif pma_orientation == 270:
							CONNECT_TOP.x += rotated_offset.x
							CONNECT_TOP.y += rotated_offset.y*0.97
				elif area.get_parent().name == "CollaborationModule":
					if module_orientation == 0:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_TOP.x += rotated_offset.y*0.8
								CONNECT_TOP.y += rotated_offset.y*0.12
							elif pma_orientation == 270:
								CONNECT_TOP.x -= rotated_offset.y*0.8
								CONNECT_TOP.y -= rotated_offset.y*0.12
						elif area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_TOP.x += rotated_offset.x*0.02
								CONNECT_TOP.y += rotated_offset.y*1
							elif pma_orientation == 180:
								CONNECT_TOP.x -= rotated_offset.x*1.0
								CONNECT_TOP.y -= rotated_offset.y
					elif module_orientation == 90:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_TOP.x -= rotated_offset.x*0.12
								CONNECT_TOP.y += rotated_offset.x*0.8
							elif pma_orientation == 180:
								CONNECT_TOP.x -= rotated_offset.x*3.7
								CONNECT_TOP.y += rotated_offset.y*0.21
						elif area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_TOP.x += rotated_offset.x*1
								CONNECT_TOP.y -= rotated_offset.y*0
							elif pma_orientation == 270:
								CONNECT_TOP.x -= rotated_offset.x*1
								CONNECT_TOP.y -= rotated_offset.y*1.1
					elif module_orientation == 180:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_TOP.x -= rotated_offset.y*0.8
								CONNECT_TOP.y -= rotated_offset.y*0.12
							elif pma_orientation == 270:
								CONNECT_TOP.x += rotated_offset.y*0.8
								CONNECT_TOP.y += rotated_offset.y*0.12
						elif area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 0:
								CONNECT_TOP.x -= rotated_offset.x*1.1
								CONNECT_TOP.y -= rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_TOP.x -= rotated_offset.x*0
								CONNECT_TOP.y += rotated_offset.y
					elif module_orientation == 270:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_TOP.x += rotated_offset.x*0.12
								CONNECT_TOP.y -= rotated_offset.x*0.8
							elif pma_orientation == 180:
								CONNECT_TOP.x -= rotated_offset.x*0.12
								CONNECT_TOP.y += rotated_offset.x*.8
						elif area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_TOP.x -= rotated_offset.x
								CONNECT_TOP.y -= rotated_offset.y*1.11
							elif pma_orientation == 270:
								CONNECT_TOP.x += rotated_offset.x
								CONNECT_TOP.y += rotated_offset.y*0

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
