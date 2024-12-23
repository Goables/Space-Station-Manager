extends Panel

@onready var panel = $"."
@onready var tab_bar = $"../TabBar"
@onready var utility_tab_bar = $UtilityTabBar
@onready var oxygen_stats = $AtmospherePanel/OxygenStats
@onready var co_2_stats = $AtmospherePanel/CO2Stats
@onready var overview_panel = $OverviewPanel
@onready var supply_panel = $SupplyPanel
@onready var panels = [
	$OverviewPanel,      # 0
	$AtmospherePanel,    # 1
	$SupplyPanel,        # 2
	$CrewPanel,          # 3
	$PowerPanel,         # 4
	$LaunchPanel         # 5
]

func _on_tab_bar_tab_clicked(tab):
	if Global.MODULE_ONE:
		if panel.visible == true:
			panel.visible = false
		else:
			if tab == 1:
				panel.visible = true
	if tab == 2:
		if Global.BUILD_MODE_ENABLED == false:
			var texture = preload("res://Textures/Exit Build Mode Icon.png")
			print("turned on")
			tab_bar.set_tab_disabled(0, true)
			tab_bar.set_tab_disabled(1, true)
			tab_bar.set_tab_icon(2, texture)
			Global.BUILD_MODE_ENABLED = true
			get_node("/root/Gameplay/CanvasLayer/BuildModeMenu").visible = true
			return
		if Global.BUILD_MODE_ENABLED == true:
			var texture = preload("res://Textures/Build Mode Icon.png")
			print("turned off")
			tab_bar.set_tab_disabled(0, false)
			tab_bar.set_tab_disabled(1, false)
			tab_bar.set_tab_icon(2, texture)
			Global.BUILD_MODE_ENABLED = false
			get_node("/root/Gameplay/CanvasLayer/BuildModeMenu").visible= false
			return

func _on_utility_tab_bar_tab_clicked(tab):
	for i in range(panels.size()):
		panels[i].visible = (i == tab)  # Set only the selected panel to visible
	if oxygen_stats.visible == true:
		updateLabels_Atmo()
	if overview_panel.visible == true:
		updateLabels_Over()
	if supply_panel.visible == true:
		updateLabels_Supply()

func updateLabels_Atmo():
	oxygen_stats.bbcode_text = "CURRENT STATION OXYGEN LEVEL: [color=#00baf1]"+str(Global.TOTAL_OXYGEN)+"[/color] \nMAXIMUM STATION OXYGEN CAPABILITY: [color=#00baf1]"+str(Global.MAX_OXYGEN)+"[/color]" # +"\nCHANGE: "+str(Global.CHANGE_OXYGEN)
	co_2_stats.bbcode_text = "CURRENT STATION CO2 LEVEL: [color=#11d617]"+str(Global.TOTAL_CO2)+"[/color] \nMAXIMUM STATION CO2 CAPABILITY: [color=#11d617]"+str(Global.MAX_CO2)+"[/color]" # +"\nCHANGE: "+str(Global.CHANGE_CO2)

func updateLabels_Over():
	overview_panel.get_node("SpeedLabel").text = "Station Speed:\n27,400 km/h (17,025 mph)"
	overview_panel.get_node("OrbitsLabel").text = "Orbits Completed:\n"+str(Global.ORBITS_COMPLETED)

func updateLabels_Supply():
	var item_list = $SupplyPanel/ItemList
	for supply in Global.SUPPLIES:
		if supply.resource == "Food":
			item_list.get_node("FoodButton").text = "Food: " + str(supply.quantity)
			break
		if supply.resource == "Water":
			item_list.get_node("WaterButton").text = "Water: " + str(supply.quantity)
			break
		if supply.resource == "Waste":
			item_list.get_node("WasteButton").text = "Waste: " + str(supply.quantity)
			break
		if supply.resource == "Fuel":
			item_list.get_node("FuelButton").text = "Fuel: " + str(supply.quantity)
			break
		if supply.resource == "Tools":
			item_list.get_node("ToolsButton").text = "Tools: " + str(supply.quantity)
			break
		if supply.resource == "Science Equipment":
			item_list.get_node("ScienceButton").text = "Sci. Equip.: " + str(supply.quantity)
			break

func _on_food_button_pressed():
	changeSupplyText("Food", "Space chow! From vacuum-sealed noodles to suspiciously cube-shaped meat. Yum?")

func _on_water_button_pressed():
	changeSupplyText("Water", "Hydration pods for drinking, cleaning, or splash fights during zero-G downtime.")

func _on_waste_button_pressed():
	changeSupplyText("Waste",  "Yesterday's burritos, tomorrow's compost... or a space-age mystery blob.")

func _on_fuel_button_pressed():
	changeSupplyText("Fuel", "Rocket juice! Powers your station or that experimental coffee maker.")

func _on_tools_button_pressed():
	changeSupplyText("Tools", "Wrenches, screwdrivers, and that one thing that looks like it fixes everything but never does.")

func _on_science_button_pressed():
	changeSupplyText("Science Equipment", "Beakers, probes, and a very official clipboard for doodling equations.")

func changeSupplyText(title, desc):
	supply_panel.get_node("ItemLabel").text = title
	supply_panel.get_node("ItemDescLabel").text = desc
