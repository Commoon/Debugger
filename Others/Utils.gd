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

const VERSION_NUMBER = "0.2.5"
const SAVE_FILENAME = "user://data.save"

const CHAR_TEXTURES = {
    "0": preload("res://Assets/Others/Numbers/0.png"),
    "1": preload("res://Assets/Others/Numbers/1.png"),
    "2": preload("res://Assets/Others/Numbers/2.png"),
    "3": preload("res://Assets/Others/Numbers/3.png"),
    "4": preload("res://Assets/Others/Numbers/4.png"),
    "5": preload("res://Assets/Others/Numbers/5.png"),
    "6": preload("res://Assets/Others/Numbers/6.png"),
    "7": preload("res://Assets/Others/Numbers/7.png"),
    "8": preload("res://Assets/Others/Numbers/8.png"),
    "9": preload("res://Assets/Others/Numbers/9.png"),
    "*": preload("res://Assets/Others/Numbers/m.png"),
    "/": preload("res://Assets/Others/Numbers/d.png"),
    "=": preload("res://Assets/Others/Numbers/=.png")
}

enum SoundEffect {
    Hit, Select, Shop, Tongue
}
onready var sound_effect_resources = {
    SoundEffect.Hit: preload("res://Assets/Audio/Hit.wav"),
    SoundEffect.Select: preload("res://Assets/Audio/Select.wav"),
    SoundEffect.Shop: preload("res://Assets/Audio/Shop.wav"),
    SoundEffect.Tongue: preload("res://Assets/Audio/Tongue.wav"),
}
var audio_player: AudioStreamPlayer = null

func play_sound(type=SoundEffect.Select):
    if audio_player == null:
        return
    audio_player.stream = sound_effect_resources[type]
    audio_player.play()

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

func multinomial(probs: Array):
    var r = randf() * 100;
    var i = 0
    var n = len(probs)
    while i < n and r >= probs[i]:
        r -= probs[i]
        i += 1
    if i == n:
        i -= 1
    return i
