extends Button

func _on_ready() -> void:
	self.connect("pressed", func() -> void:
		SignalHub.build_requested.emit(Constants.GeneratorString)
	)
