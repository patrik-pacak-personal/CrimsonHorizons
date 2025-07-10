extends CanvasLayer


func _on_resources_changed() -> void:
	reloadResources()


func _on_ready() -> void:
	var people = $Panel/HBoxContainer/VBoxContainer/PeopleContainer/peopleGoal
	people.text = str(Data.resources["peopleGoal"])
	
	reloadResources()

func reloadResources():
	var people = $Panel/HBoxContainer/VBoxContainer/PeopleContainer/peopleCount
	people.text = str(Data.resources["people"])
	
	var minerals = $Panel/HBoxContainer/VBoxContainer/MineralsContainer/mineralsCount
	minerals.text = str(Data.resources["minerals"])
	
	var energy = $Panel/HBoxContainer/VBoxContainer2/EnergyContainer/energyCount
	energy.text = str(Data.resources["energy"])
	
	var food = $Panel/HBoxContainer/VBoxContainer2/FoodContainer/foodCount
	food.text = str(Data.resources["food"])
