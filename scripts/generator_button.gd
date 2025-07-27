extends Button

func _on_ready() -> void:
	self.connect("pressed", func() -> void:
		#This 0 here is added since every building has multiple variants, but generator is only 1
		SignalHub.build_requested.emit(Constants.GeneratorString + "0")
	)
