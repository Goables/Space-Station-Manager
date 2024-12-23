extends Panel 

var debounce = false

@onready var itemsContainer = $ItemsList/ScrollContainer
@onready var habitation = $ItemsList/ScrollContainer/Habitation
@onready var storage = $ItemsList/ScrollContainer/Storage
@onready var coupling = $ItemsList/ScrollContainer/Coupling

@onready var habitation_button = $CategoryList/ScrollContainer/VBoxContainer/HabitationButton
@onready var storage_button = $CategoryList/ScrollContainer/VBoxContainer/StorageButton
@onready var coupling_button = $CategoryList/ScrollContainer/VBoxContainer/CouplingButton

const spawnPMA = preload("res://Objects/pma.tscn")
const spawnPioneer = preload("res://Objects/station_module_1.tscn")
@onready var build_timer = $buildTimer

@onready var panels = [
	$ItemsList/ScrollContainer/Habitation,
	$ItemsList/ScrollContainer/Storage,
	$ItemsList/ScrollContainer/Coupling
]

var IS_HOLDING_ITEM = Global.HOLDING_ITEM

func hideOthers(tab):
	for i in range(panels.size()):
		panels[i].visible = (i == tab)  # Set only the selected panel to visible

func _on_coupling_button_pressed():
	hideOthers(2)

func _on_storage_button_pressed():
	hideOthers(1)

func _on_habitation_button_pressed():
	hideOthers(0)


func _on_pma_button_pressed():
	if IS_HOLDING_ITEM == false and not debounce:
		debounce = true
		IS_HOLDING_ITEM = true
		if not Global.SANDBOX_MODE:
			build_timer.wait_time = 2
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = true
			build_timer.wait_time = 3
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = false
		var CURRENT_OBJECT = spawnPMA.instantiate()
		get_node("/root/Gameplay/Station").add_child(CURRENT_OBJECT)
		CURRENT_OBJECT.position = Vector2(0,0)
		CURRENT_OBJECT.name = "PMA"
		Global.ITEM_HELD = CURRENT_OBJECT
		Global.CAN_PICKUP = false
		IS_HOLDING_ITEM = false
		debounce = false

func _on_pioneer_button_pressed():
	if IS_HOLDING_ITEM == false and not debounce:
		debounce = true
		IS_HOLDING_ITEM = true
		if not Global.SANDBOX_MODE:
			build_timer.wait_time = 2
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = true
			build_timer.wait_time = 3
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = false
		var CURRENT_OBJECT = spawnPioneer.instantiate()
		get_node("/root/Gameplay/Station").add_child(CURRENT_OBJECT)
		CURRENT_OBJECT.position = get_global_mouse_position()
		CURRENT_OBJECT.name = "PioneerModule"
		Global.ITEM_HELD = CURRENT_OBJECT
		Global.CAN_PICKUP = true
		IS_HOLDING_ITEM = false
		debounce = false

func _on_collaboration_button_pressed():
	if IS_HOLDING_ITEM == false and not debounce:
		debounce = true
		const spawnCollaboration = preload("res://Objects/collaboration_module.tscn")
		IS_HOLDING_ITEM = true
		if not Global.SANDBOX_MODE:
			build_timer.wait_time = 2
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = true
			build_timer.wait_time = 3
			build_timer.start()
			await build_timer.timeout
			get_node("/root/Gameplay/SmallRocket").visible = false
		var CURRENT_OBJECT = spawnCollaboration.instantiate()
		get_node("/root/Gameplay/Station").add_child(CURRENT_OBJECT)
		CURRENT_OBJECT.position = get_global_mouse_position()
		CURRENT_OBJECT.name = "CollaborationModule"
		Global.ITEM_HELD = CURRENT_OBJECT
		Global.CAN_PICKUP = true
		IS_HOLDING_ITEM = false
		debounce = false
