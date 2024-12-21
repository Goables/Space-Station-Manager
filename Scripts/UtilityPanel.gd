extends Panel

@onready var panel = $"."
@onready var tab_bar = $"../TabBar"
@onready var oxygen_stats = $AtmospherePanel/OxygenStats
@onready var co_2_stats = $AtmospherePanel/CO2Stats

@onready var panels = [
	$OverviewPanel,      # 0
	$AtmospherePanel,    # 1
	$SupplyPanel,        # 2
	$CrewPanel,          # 3
	$PowerPanel,         # 4
	$LaunchPanel         # 5
]

func _physics_process(delta):
	if oxygen_stats.visible == true:
		updateLabels()

func _on_tab_bar_tab_clicked(tab):
	if panel.visible == true:
		panel.visible = false
	else:
		if tab == 1:
			panel.visible = true

func _on_utility_tab_bar_tab_clicked(tab):
	print(tab)
	for i in range(panels.size()):
		panels[i].visible = (i == tab)  # Set only the selected panel to visible

func _on_oxygen_stats_visibility_changed():
	if oxygen_stats.visible == true:
		updateLabels()

func updateLabels():
	oxygen_stats.text = "CURRENT STATION OXYGEN LEVEL: "+str(Global.TOTAL_OXYGEN)+"\nMAXIMUM STATION OXYGEN CAPABILITY: "+str(Global.MAX_OXYGEN)
	co_2_stats.text = "CURRENT STATION CO2 LEVEL: "+str(Global.TOTAL_CO2)+"\nMAXIMUM STATION CO2 CAPABILITY: "+str(Global.MAX_CO2)
