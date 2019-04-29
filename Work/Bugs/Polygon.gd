extends Bug

export var speed_min: float = 200
export var speed_max: float = 600
export var velocity_min := 0.7
export var velocity_max := 1.3
export var n_vertices: int = 4
export var cycled := false

onready var speed := rand_range(speed_min, speed_max)

export var vertices := []
var velocities := []
var direction: Vector2


func _ready():
    if len(vertices) == 0:
        velocities = []
        vertices.push_back(Utils.random_pos_border())
        velocities.push_back(speed)
        for i in range(n_vertices):
            var x = Utils.random_pos_area()
            vertices.push_back(x)
            velocities.push_back(speed * rand_range(velocity_min, velocity_max))
        vertices.push_back(Utils.random_pos_border())
        velocities.push_back(speed * rand_range(velocity_min, velocity_max))
        var difficulty = pow(1 - (1 - (speed - speed_min) / (speed_max - speed_min)), 2)
        .start(vertices[0], difficulty)
    else:
        velocities = []
        while len(velocities) < len(vertices):
            velocities.push_back(speed * rand_range(velocity_min, velocity_max))
        .start_preset(self.bug_type)
    move_to_next()

func move_to_next():
    var current_pos = vertices.pop_front()
    var current_v = velocities.pop_front()
    if cycled:
        vertices.push_back(current_pos)
        velocities.push_back(current_v)
    elif len(vertices) == 0:
        return
    direction = (vertices[0] - current_pos).normalized()
    .set_rotate(direction)

func update_func(dt):
    var to_move = direction * velocities[0] * dt
    var new_pos = self.position + to_move
    if len(vertices) > 0 and (vertices[0] - new_pos).dot(to_move) <= 0:
        new_pos = vertices[0]
        move_to_next()
    self.position = new_pos
