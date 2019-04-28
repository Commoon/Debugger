extends Node2D

class_name Bug

export var size_min := 1.0
export var size_max := 1.0
export var value := 10
export var weight_coeff := 1.0

var started := false
var is_catched := false
onready var size = rand_range(size_min, size_max)


func update_func(dt):
    pass

func start(start_pos):
    self.position = start_pos
    self.started = true
    self.transform.scaled(Vector2.ONE * size)

func set_rotate(direction: Vector2):
    self.rotation = direction.angle()

func destroy():
    self.queue_free()

func _process(delta):
    if self.started and not self.is_catched:
        self.update_func(delta)
