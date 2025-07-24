extends Button

func _on_ready() -> void:
	self.connect("pressed", func() -> void:
		SignalHub.build_requested.emit(Constants.MineString + str(rnd_num()))
	)
	
func rnd_num() -> int:
	return randi() % 2 + 1
