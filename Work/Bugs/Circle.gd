extends Bug

export var speed_min: float = 200
export var speed_max: float = 600
export var radius_min: float = 50
export var radius_max: float = 80
export var mirrored_x := false
export var mirrored_y := false

var time := 0.0

export var center: Vector2
var y_direction: Vector2
onready var speed := rand_range(speed_min, speed_max)
onready var radius := rand_range(radius_min, radius_max)
onready var omega := speed / radius
onready var mirrored := Vector2(-1 if mirrored_x else 1, -1 if mirrored_y else 1)

func _ready():
    if self.bug_type < 0:
        center = Utils.random_pos_area()
        var difficulty = pow(1 - (1 - (speed - speed_min) / (speed_max - speed_min)), 2)
        .start(center, difficulty)
    else:
        if center == Vector2.ZERO:
            center = self.position
        .start_preset(self.bug_type)

func update_func(dt):
    time += dt
    var x = center.x + cos(omega * time) * radius * mirrored.x
    var y = center.y + sin(omega * time) * radius * mirrored.y
    var pos = Vector2(x, y)
    .set_rotate(pos - self.position)
    self.position = pos
