extends Node

signal resources_changed()

func _ready():
	SignalHub.on_reset.connect(ResetResources)
	SignalHub.give_resources.connect(give_resources)

var default_resources = {
	"minerals": 200,
	"energy": 300,
	"food": 10,
	"people": 0,
	"peopleGoal" :100
}

var houses =0;
var mines =0;
var generators =0;
var turrets = 0;
var farms = 0;

var _minerals = default_resources["minerals"]
var minerals:
	get:
		return _minerals
	set(value):
		if value != _minerals:
			_minerals = value
			SignalHub.update_resources_ui.emit()

var _people = default_resources["people"]
var people:
	get:
		return _people
	set(value):
		if value != _people:
			_people = value
			SignalHub.update_resources_ui.emit()

var _food = default_resources["food"]
var food:
	get:
		return _food
	set(value):
		if value != _food:
			_food = value
			SignalHub.update_resources_ui.emit()
			
var _energy = default_resources["energy"]
var energy:
	get:
		return _energy
	set(value):
		if value != energy:
			_energy = value
			SignalHub.update_resources_ui.emit()
		
func ResetResources():
	minerals = default_resources["minerals"]
	energy = default_resources["energy"]
	food = default_resources["food"]
	people = default_resources["people"]

func get_resource_by_key(key: String) -> int:
	match key:
		Constants.MineralsString:
			return minerals
		Constants.EnergyString:
			return energy		
		Constants.FoodString:
			return food
		Constants.PeopleString:
			return people
		_:
			print("Unknown resource key: ", key)
			return -1

func pay_resources(building_name: String):
	var building = get_building_cost_object(building_name)

	for key in building.keys():
		var amount = building[key]
		match key:
			Constants.MineralsString:
				minerals -= amount
			Constants.EnergyString:
				energy -= amount
			Constants.FoodString:
				food -= amount
			Constants.PeopleString:
				people -= amount			
				
func can_pay(building_name: String) -> bool:
	var building = get_building_cost_object(building_name)

	for key in building.keys():
		var cost = building[key]
		var available = get_resource_by_key(key)

		if available == -1:
			print("Missing or unknown resource:", key)
			return false
		if available < cost:
			print("Not enough", key, "- needed:", cost, "available:", available)
			return false

	return true
	
	
func get_building_cost_object(item_name:String) -> Dictionary:
	if item_name.length() <= 1:
		print("Invalid building name.")
		return {}
	# Step 1: Remove the last letter
	var base_name = item_name.substr(0, item_name.length() - 1)

	# Step 2: Look up building data
	if not building_costs.has(base_name):
		print("No building data for:", base_name)
		return {}

	return building_costs[base_name]
	
func give_resources() -> void:
	var required_farms = int(ceil(houses / 2.0))
	if farms >= required_farms and farms != 0:
		people = houses * building_gains["house"]
	minerals  =minerals + mines * building_gains["mine"]	
	energy = energy + generators * building_gains["generator"]
	food = farms * building_gains["farm"]
	

var building_costs = {
	"house": {
		"energy": 5,
		"minerals": 15
	},
	"farm": {
		"energy": 5,
		"minerals": 10
	},
	"generator": {
		"energy": 15,
		"minerals": 10 
	},
	"mine": {
		"energy": 15,
		"minerals": 25
	},
	"turret": {
		"energy": 5,
		"minerals":25
	}
}

var building_gains = {
	"house": 15,
	"farm": 30,
	"generator": 10,
	"mine": 15
}

var actions_costs = {
	"fire_artillery": {
		"energy": 5
	}
}
