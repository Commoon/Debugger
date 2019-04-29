extends Bug

export var speed_min: float = 200
export var speed_max: float = 600
export var amplitude_min: float = 100
export var amplitude_max: float = 160
export var period_min: float = 3
export var period_max: float = 6

var time := 0.0

onready var start_pos := Utils.random_pos_border(Utils.Direction.Down)
onready var end_pos := Utils.random_pos_border(Utils.get_direction(start_pos))
onready var direction := (end_pos - start_pos).normalized()
onready var y_direction := Vector2(-direction.y, direction.x)
onready var speed := rand_range(speed_min, speed_max)
onready var period := rand_range(period_min, period_max)
onready var amplitude := rand_range(amplitude_min, amplitude_max)

func _ready():
    var difficulty = pow(1 - (1 - (speed - speed_min) / (speed_max - speed_min)), 2)
    .start(start_pos, difficulty)

func update_func(dt):
    time += dt
    var y = amplitude * sin(2 * PI / period * time)
    var pos = start_pos + direction * time * speed
    pos += y_direction * y
    .set_rotate(pos - self.position)
    self.position = pos
