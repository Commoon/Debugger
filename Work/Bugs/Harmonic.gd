extends Bug

export var speed_min: float = 200
export var speed_max: float = 600
export var amplitude_min: float = 100
export var amplitude_max: float = 160
export var period_min: float = 3
export var period_max: float = 6
export var flying_period := 0.0

var time := 0.0

export var start_pos: Vector2
export var direction: Vector2
var y_direction: Vector2
onready var speed := rand_range(speed_min, speed_max)
onready var period := rand_range(period_min, period_max)
onready var amplitude := rand_range(amplitude_min, amplitude_max)

func _ready():
    if self.bug_type < 0:
        start_pos = Utils.random_pos_border(Utils.Direction.Down)
        var end_pos = Utils.random_pos_border(Utils.get_direction(start_pos))
        direction = (end_pos - start_pos).normalized()
    y_direction = Vector2(-direction.y, direction.x)
    if self.bug_type < 0:
        var difficulty = pow(1 - (1 - (speed - speed_min) / (speed_max - speed_min)), 2)
        .start(start_pos, difficulty)
    else:
        .start_preset(self.bug_type)

func update_func(dt):
    time += dt
    var t = time
    if flying_period > 0:
        var n = floor(t / flying_period)
        t -= n * flying_period
        t = flying_period / 2 - abs(t - flying_period / 2)
    var y = amplitude * sin(2 * PI / period * time)
    var pos = start_pos + direction * t * speed
    pos += y_direction * y
    .set_rotate(pos - self.position)
    self.position = pos
