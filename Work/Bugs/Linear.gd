extends Bug

export var speed_min: float = 200
export var speed_max: float = 600

onready var speed := rand_range(speed_min, speed_max)
var direction: Vector2

func _ready():
    var start_pos = Utils.random_pos_border(Utils.Direction.Down)
    var start_dir = Utils.get_direction(start_pos)
    var end_pos = Utils.random_pos_border(start_dir)
    direction = (end_pos - start_pos).normalized()
    var difficulty = pow(1 - (1 - (speed - speed_min) / (speed_max - speed_min)), 2)
    .start(start_pos, difficulty)
    .set_rotate(direction)


func update_func(dt):
    self.position += self.speed * dt * direction
