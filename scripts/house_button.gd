extends Button

func _on_ready() -> void:
	self.connect("pressed", func() -> void:
		SignalHub.build_requested.emit(Constants.HouseString + Utilities.rnd_num_str(3))
	)
