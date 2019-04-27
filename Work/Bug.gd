extends Node2D

class_name Bug

var started := false
var value := 10
var is_catched := false
var weight_coeff := 1.0


func update_func(dt):
    pass

func start(start_pos):
    self.position = start_pos
    self.started = true

func destroy():
    self.queue_free()

func _process(delta):
    if self.started and not self.is_catched:
        self.update_func(delta)
