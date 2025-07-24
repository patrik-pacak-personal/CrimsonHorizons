extends Node

signal resources_changed()

var houses =0;
var mines =0;
var generators =0;
var turrets = 0;
var farms = 0;

func ResetResources():
	resources["minerals"] = 40
	resources["energy"] = 30
	resources["population"] = 0
	resources["food"] = 0

var resources = {
	"minerals": 40,
	"energy": 30,
	"food": 10,
	"people": 0,
	"peopleGoal" :100
}

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
