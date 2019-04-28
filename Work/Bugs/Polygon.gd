extends Bug

export var speed_min: float = 200
export var speed_max: float = 400
export var n_vertices: int = 4
export var cycled := false

onready var speed := rand_range(speed_min, speed_max)

var vertices := []
var direction: Vector2


func _ready():
    self.value = 20
    self.weight_coeff = 1.0
    vertices.push_back(Utils.random_pos_border())
    for i in range(n_vertices):
        var x = Utils.random_pos_area()
        vertices.push_back(x)
    vertices.push_back(Utils.random_pos_border())
    .start(vertices[0])
    move_to_next()

func move_to_next():
    var current_pos = vertices.pop_front()
    if cycled:
        vertices.push_back(current_pos)
    elif len(vertices) == 0:
        return
    direction = (vertices[0] - current_pos).normalized()
    .set_rotate(direction)

func update_func(dt):
    var to_move = direction * speed * dt
    var new_pos = self.position + to_move
    if len(vertices) > 0 and (vertices[0] - new_pos).dot(to_move) <= 0:
        new_pos = vertices[0]
        move_to_next()
    self.position = new_pos
