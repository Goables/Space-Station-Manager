extends Node

var BUILD_MODE_ENABLED: bool = false
var SANDBOX_MODE = true

var MAX_OXYGEN: float = 0.0
var MAX_CO2: float = 0.0

var TOTAL_OXYGEN: float = 0.0
var TOTAL_CO2: float = 0.0

var ORBITS_COMPLETED = 0.0
var HOLDING_ITEM = false
var ITEM_HELD = null
var CAN_PICKUP = true

var DATE = "Jan. 1, 2002"

var SUPPLIES = [
	{
		"resource": "Food",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	},
	{
		"resource": "Water",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	},
	{
		"resource": "Waste",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	},
	{
		"resource": "Fuel",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	},
	{
		"resource": "Tools",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	},
	{
		"resource": "Science Equipment",
		"quantity": 0.0
		# "modules": [] # Future possible use for more in-depth supply system
	}
]

var MODULE_ONE = null

var target_variable: bool = false
var target_node_paths: Array = ["/root/Gameplay/Station/PioneerModule", "/root/Gameplay/Station/CollaborationModule"]

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var keycode = DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
		if keycode == KEY_BACKSPACE or keycode == KEY_DELETE:
			if Global.BUILD_MODE_ENABLED:
				if Global.ITEM_HELD != null:
					Global.ITEM_HELD.queue_free()
				Global.HOLDING_ITEM = false
				Global.ITEM_HELD = null
				Global.CAN_PICKUP = true
				getallnodes(get_node("/root/Gameplay"))

func _process(delta: float) -> void:
	if target_variable == false:  # If the variable hasn't been changed yet
		# Loop through each path in the array
		for path in target_node_paths:
			var target_node = get_node_or_null(path)  # Get the node at the current path
			
			if target_node != null and BUILD_MODE_ENABLED == false:  # If the node exists and build mode is not enabled
				target_variable = true  # Change the variable
				print("Node found at path: ", path)  # Print the path where the node was found
				MODULE_ONE = get_node(path)
				return  # Stop checking further paths once a node is found

func getallnodes(node: Node) -> void:
	for N in node.get_children():
		if N.get_child_count() > 0 && N.name != "SnapBall":
			getallnodes(N)
		else:
			if N.name == "SnapBall":
				N.visible = false
