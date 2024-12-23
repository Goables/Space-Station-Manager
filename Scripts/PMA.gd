extends Sprite2D

class_name PMA

signal integrityChanged 

@export var MAX_MODULE_INTEGRITY: float = 50.0
@export var currentIntegrity: float = 50.0

@onready var damaged_timer = $damagedTimer
@onready var hurtBox = $"../CollisionHolder"
@onready var station_module = $"."

@onready var rightSnapBall = $"../DockRight/SnapBall"
@onready var leftSnapBall = $"../ConnectLeft/SnapBall"

var CONNECT_RIGHT = null
var CONNECT_LEFT = null

var isSnapped = false
var snapLeft = null
var snapRight = null

var connected = false
var holdingShift = false

var IS_MOVING = true

var isHurt: bool = false
var TimeInSeconds = 5
var has_rotated = false

var connected_modules: Dictionary = {
	"left": null,
	"right": null
}
# Array to store node names the module cannot connect to, but can connect to
var forbidden_connect_nodes = ["PMA"]

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		if keycode == KEY_Q:
			if not has_rotated && IS_MOVING == true && Global.BUILD_MODE_ENABLED == true:
				get_parent().rotation_degrees -= 90
				if get_parent().rotation_degrees < 0:
					get_parent().rotation_degrees = 270
				has_rotated = true
				print(get_parent().rotation_degrees)
		elif keycode == KEY_E:
			if not has_rotated && IS_MOVING == true && Global.BUILD_MODE_ENABLED == true:
				get_parent().rotation_degrees += 90
				if get_parent().rotation_degrees > 270:
					get_parent().rotation_degrees = 0
				has_rotated = true
				print(get_parent().rotation_degrees)
		if keycode == KEY_SHIFT:
			holdingShift = true
		if event.pressed == false and (keycode == KEY_Q or keycode == KEY_E):
			has_rotated = false
		if event.pressed == false:
			holdingShift = false
			CONNECT_LEFT = null
			CONNECT_RIGHT = null
			isSnapped = false
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if IS_MOVING == true:
			IS_MOVING = false
			self.self_modulate.a = 1
			getallnodes(get_node("/root/Gameplay"))
			rightSnapBall.visible = false
			leftSnapBall.visible = false
			Global.ITEM_HELD = null
			await get_tree().create_timer(0.25).timeout
			Global.CAN_PICKUP = true
			Global.HOLDING_ITEM = false
		else:
			if Global.BUILD_MODE_ENABLED == true && Global.CAN_PICKUP == true:
				if get_rect().has_point(to_local(get_global_mouse_position())):
					if connected_modules["left"]:
						custom_disconnect("left")
					if connected_modules["right"]:
						custom_disconnect("right")
					IS_MOVING = true
					isSnapped = false
					self.self_modulate.a = 0.5
					Global.CAN_PICKUP = false
					Global.ITEM_HELD = self.get_parent()

func changeMoving():
	IS_MOVING = not IS_MOVING

# Shouldn't do much for the first module, but will be used in other modules
func onDock():
	# placeholder
	pass

func _ready():
	if Global.BUILD_MODE_ENABLED:
		self.self_modulate.a = 0.5

func _physics_process(delta):
	if IS_MOVING == true:
		getallnodes(get_node("/root/Gameplay"))
		rightSnapBall.visible = true
		leftSnapBall.visible = true
		if isSnapped == false:
			get_parent().position = get_global_mouse_position()
	if CONNECT_RIGHT != null:
		get_parent().position = CONNECT_RIGHT
		CONNECT_RIGHT = null
		Global.HOLDING_ITEM = false
	if CONNECT_LEFT != null:
		get_parent().position = CONNECT_LEFT
		CONNECT_LEFT = null
		Global.HOLDING_ITEM = false
		isSnapped = true
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

# -------- DOCKING ---------------- #
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
				var local_offset = Vector2(area.position.x * 1.28, area.position.y * 1.28)

				# Rotate the local offset based on the PMA's rotation
				var rotated_offset = local_offset.rotated(deg_to_rad(pma_orientation))
				if area.get_parent().name.begins_with("PioneerModule"):
					if module_orientation == 0:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*1
								CONNECT_LEFT.y += rotated_offset.y*0.98
							elif pma_orientation == 180:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y += rotated_offset.y
					elif module_orientation == 90:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y += rotated_offset.y
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x
								CONNECT_LEFT.y -= rotated_offset.y*0.96
					elif module_orientation == 180:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y += rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*1.0
								CONNECT_LEFT.y -= rotated_offset.y
					elif module_orientation == 270:
						if area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_LEFT.x += rotated_offset.x
								CONNECT_LEFT.y -= rotated_offset.y*0.95
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y += rotated_offset.y
				elif area.get_parent().name.begins_with("CollaborationModule"):
					if module_orientation == 0:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.3
								CONNECT_LEFT.y += rotated_offset.y*2.8
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.35
								CONNECT_LEFT.y += rotated_offset.y*2.85
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*1.02
								CONNECT_LEFT.y -= rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_LEFT.x -= rotated_offset.x*1.01
								CONNECT_LEFT.y += rotated_offset.y
					elif module_orientation == 90:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*2.85
								CONNECT_LEFT.y -= rotated_offset.y*0.3
							elif pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*2.85
								CONNECT_LEFT.y -= rotated_offset.y*0.36
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_LEFT.x += rotated_offset.x*0.8
								CONNECT_LEFT.y += rotated_offset.y*1.02
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y -= rotated_offset.y
					elif module_orientation == 180:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.35
								CONNECT_LEFT.y += rotated_offset.y*2.85
							elif pma_orientation == 270:
								CONNECT_LEFT.x -= rotated_offset.x*0.3
								CONNECT_LEFT.y += rotated_offset.y*2.8
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 0:
								CONNECT_LEFT.x -= rotated_offset.x*1.0
								CONNECT_LEFT.y += rotated_offset.y
							elif pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*1.02
								CONNECT_LEFT.y += rotated_offset.y
					elif module_orientation == 270:
						if area.name == "ConnectTop" or area.name == "ConnectBottom":
							if pma_orientation == 180:
								CONNECT_LEFT.x += rotated_offset.x*2.75
								CONNECT_LEFT.y -= rotated_offset.y*0.35
							elif pma_orientation == 0:
								CONNECT_LEFT.x += rotated_offset.x*2.8
								CONNECT_LEFT.y -= rotated_offset.y*0.3
						elif area.name == "ConnectLeft" or area.name == "ConnectRight":
							if pma_orientation == 90:
								CONNECT_LEFT.x -= rotated_offset.x*0.96
								CONNECT_LEFT.y -= rotated_offset.y*1.0
							elif pma_orientation == 270:
								CONNECT_LEFT.x += rotated_offset.x*0.96
								CONNECT_LEFT.y += rotated_offset.y*1.025

func _on_dock_right_area_entered(area):
	if IS_MOVING == false:
		if not area.get_parent().get_node("StationModule"):
			CONNECT_RIGHT = area.get_parent().position
			CONNECT_RIGHT += area.position*2

func reset_snap_variables() -> void:
	# Reset the snap variables
	snapLeft = null
	snapRight = null
	isSnapped = false  # Reset the overall snap status

func custom_disconnect(direction: String) -> void:
	if connected_modules[direction]:
		var disconnected_module = connected_modules[direction]
		connected_modules[direction] = null
		reset_snap_variables()  # Reset snap variables when disconnected
		isSnapped = false

func getallnodes(node):
	for N in node.get_children():
		if N.get_child_count() > 0 && N.name != "SnapBall" && can_connect_to_module(N.name):
			getallnodes(N)
		else:
			if N.name == "SnapBall":
				if Global.BUILD_MODE_ENABLED == true && IS_MOVING == true:
					N.visible = true
				else:
					N.visible = false
