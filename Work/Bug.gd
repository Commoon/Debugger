extends Node2D

class_name Bug

var bug_type := -1

export var size_min := 0.9
export var size_max := 1.1

export var weight_coeff := 1.0

var started := false
var is_catched := false
var value := 0
onready var size = rand_range(size_min, size_max)
onready var sprite = $Sprite
onready var collider = $Physics/CollisionShape2D.shape as CircleShape2D


func update_func(dt):
    pass

func start(start_pos, difficulty=-1):
    self.position = start_pos
    self.started = true
    var i = int(floor((1 - difficulty) * BugTypes.n_types)) \
        if 0 <= difficulty and difficulty <= 1 else \
        Utils.multinomial(BugTypes.bug_probs)
    self.bug_type = i
    self.value = BugTypes.bug_values[i]
    self.sprite.texture = BugTypes.bug_textures[i]
    self.collider.radius = BugTypes.bug_radii[i]
    self.transform.scaled(Vector2.ONE * size)

func set_rotate(direction: Vector2):
    self.rotation = direction.angle()

func destroy():
    self.queue_free()

func _process(delta):
    if self.started and not self.is_catched:
        self.update_func(delta)
