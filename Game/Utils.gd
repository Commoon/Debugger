extends Node

enum Direction {
    Unknown = 0,
    Up = 1,
    Down = -1,
    Left = 2,
    Right = -2
}

enum Layer {
    Player = 0,
    Bug = 1,
    Wall = 2
}

const IN_WIDTH = 1280
const IN_HEIGHT = 960
const OUT_LEFT = -5
const OUT_RIGHT = IN_WIDTH - OUT_LEFT
const OUT_UP = -5
const OUT_DOWN = IN_HEIGHT - OUT_UP
const OUT_WIDTH = OUT_RIGHT - OUT_LEFT
const OUT_HEIGHT = OUT_DOWN - OUT_UP

func _ready():
    randomize()

func get_direction(pos: Vector2) -> int:
    if pos.x == OUT_LEFT:
        return Direction.Left
    elif pos.y == OUT_UP:
        return Direction.Up
    elif pos.x == OUT_RIGHT:
        return Direction.Right
    elif pos.y == OUT_DOWN:
        return Direction.Down
    return Direction.Unknown

func random_pos_border(exclude=Direction.Unknown) -> Vector2:
    var r = (OUT_WIDTH + OUT_HEIGHT) * 2 * randf()
    var d = Vector2(OUT_LEFT, OUT_DOWN - r) if r < OUT_HEIGHT else \
        Vector2(r - OUT_HEIGHT + OUT_LEFT, OUT_UP) if r < OUT_HEIGHT + OUT_WIDTH else \
        Vector2(OUT_RIGHT, r - OUT_HEIGHT - OUT_WIDTH + OUT_UP) if r < OUT_HEIGHT * 2 + OUT_WIDTH else \
        Vector2(OUT_RIGHT - (r - OUT_HEIGHT * 2 - OUT_WIDTH), OUT_DOWN)
    return random_pos_border(exclude) if get_direction(d) == exclude else d

func random_pos_area(area=Rect2(0, 0, IN_WIDTH, IN_HEIGHT)) -> Vector2:
    return Vector2(randf(), randf()) * area.size + area.position
