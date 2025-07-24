extends Node

func rnd_num(num : int) -> int:
	return randi() % num + 1
	
func rnd_num_str(num : int) -> String:
	return str(randi() % num + 1)
