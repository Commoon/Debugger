extends Node2D

class_name Bug

export var bug_type := -1 setget set_bug_type
export var size_min := 0.9
export var size_max := 1.1
export var weight_coeff := 1.0  # No use currently.
export var auto_respawn := false
export var respawn_time := 1.0

var started := false
var is_catched := false
var value := 0
onready var size = rand_range(size_min, size_max)
onready var sprite = $Sprite
onready var collider = $Physics/CollisionShape2D.shape as CircleShape2D
var backup = null


func update_func(dt):
    pass

func set_bug_type(value):
    bug_type = value
    if value == -1 or not self.started:
        return
    self.value = BugTypes.bug_values[bug_type]
    self.sprite.texture = BugTypes.bug_textures[bug_type]
    self.collider.radius = BugTypes.bug_radii[bug_type]

func start(start_pos, difficulty=-1):
    self.position = start_pos
    var i = int(floor((1 - difficulty) * BugTypes.n_types)) \
        if 0 <= difficulty and difficulty <= 1 else \
        Utils.multinomial(BugTypes.bug_probs)
    start_preset(i)

func start_preset(bug_type):
    self.started = true
    self.transform.scaled(Vector2.ONE * size)
    self.bug_type = bug_type

func set_rotate(direction: Vector2):
    self.rotation = direction.angle()

func destroy():
    self.queue_free()

func _process(delta):
    if self.started and not self.is_catched:
        self.update_func(delta)
