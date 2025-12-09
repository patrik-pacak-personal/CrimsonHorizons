extends CanvasLayer

func _ready():
	SignalHub.item_built.connect(_on_main_item_built)
	$BuildMenu.visible = false
	
	# Initialize costs
	var houseEnergy = $BuildMenu/BuildContainer/Grid/HouseButton/VBoxContainer/HBoxContainer/HouseEnergyCost
	var houseMineral = $BuildMenu/BuildContainer/Grid/HouseButton/VBoxContainer/HBoxContainer/HouseMineralCost
	houseEnergy.text = str(Resources.building_costs["house"]["energy"])
	houseMineral.text = str(Resources.building_costs["house"]["minerals"])
	
	var mineEnergy = $BuildMenu/BuildContainer/Grid/MineButton/VBoxContainer/HBoxContainer/MineEnergyCost
	var mineMineral = $BuildMenu/BuildContainer/Grid/MineButton/VBoxContainer/HBoxContainer/MineMineralCost
	mineEnergy.text = str(Resources.building_costs["mine"]["energy"])
	mineMineral.text = str(Resources.building_costs["mine"]["minerals"])
	
	var farmEnergy = $BuildMenu/BuildContainer/Grid/FarmButton/VBoxContainer/HBoxContainer/FarmEnergyCost
	var farmMineral = $BuildMenu/BuildContainer/Grid/FarmButton/VBoxContainer/HBoxContainer/FarmMineralCost
	farmEnergy.text = str(Resources.building_costs["farm"]["energy"])
	farmMineral.text = str(Resources.building_costs["farm"]["minerals"])
	
	var generatorEnergy = $BuildMenu/BuildContainer/Grid/GeneratorButton/VBoxContainer/HBoxContainer/GeneratorEnergyCost
	var generatorEnergyMineral = $BuildMenu/BuildContainer/Grid/GeneratorButton/VBoxContainer/HBoxContainer/GeneratorMineralCost
	generatorEnergy.text = str(Resources.building_costs["generator"]["energy"])
	generatorEnergyMineral.text = str(Resources.building_costs["generator"]["minerals"])
	
	var turretEnergy = $BuildMenu/BuildContainer/Grid/TurretButton/VBoxContainer/HBoxContainer/TurretEnergyCost
	var turretMineral = $BuildMenu/BuildContainer/Grid/TurretButton/VBoxContainer/HBoxContainer/TurretMineralCost
	turretEnergy.text = str(Resources.building_costs["turret"]["energy"])
	turretMineral.text = str(Resources.building_costs["turret"]["minerals"])


func _on_main_item_built() -> void:
	$BuildMenu.visible = false
