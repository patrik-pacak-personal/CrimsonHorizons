extends CanvasLayer

func _on_ready() -> void:
	var peopleGoal = $Panel/HBoxContainer/VBoxContainer/PeopleContainer/peopleGoal
	peopleGoal.text = str(Resources.default_resources["peopleGoal"])
	reloadResources()
	SignalHub.update_resources_ui.connect(reloadResources)

func reloadResources():
	var people = $Panel/HBoxContainer/VBoxContainer/PeopleContainer/peopleCount
	people.text = str(Resources.people)
	
	var minerals = $Panel/HBoxContainer/VBoxContainer/MineralsContainer/mineralsCount
	minerals.text = str(Resources.minerals)
	
	var energy = $Panel/HBoxContainer/VBoxContainer2/EnergyContainer/energyCount
	energy.text = str(Resources.energy)
	
	var food = $Panel/HBoxContainer/VBoxContainer2/FoodContainer/foodCount
	food.text = str(Resources.food)
