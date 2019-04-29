extends Node2D

class_name CustomText

enum Align {
    Left, Right, Center
}

export var font_size := 80 setget set_size
export var text := "" setget set_text
export var aligned := Align.Left setget set_aligned
const DEFAULT_SIZE = 80
const FONT_WIDTH = 58
var l = len(text)
var char_sprites = []
onready var original_pos := self.position


func set_size(value):
    font_size = value
    self.scale = Vector2.ONE * value / DEFAULT_SIZE
    
func set_text(value):
    var new_l = len(value)
    var i = 0
    while i < l and i < new_l:
        if text[i] != value[i]:
            char_sprites[i].texture = null if value[i] == " " else Utils.CHAR_TEXTURES[value[i]]
        i += 1
    if i == l:
        while i < new_l:
            var sprite = null
            sprite = Sprite.new()
            sprite.position = Vector2.RIGHT * FONT_WIDTH * i
            self.add_child(sprite)
            sprite.texture = null if value[i] == " " else Utils.CHAR_TEXTURES[value[i]]
            char_sprites.push_back(sprite)
            i += 1
    else:
        while i < l:
            self.remove_child(char_sprites[i])
            char_sprites[i].queue_free()
            i += 1
        while i > new_l:
            char_sprites.pop_back()
            i -= 1
    text = value
    l = new_l
    update_aligned()

func set_aligned(value):
    aligned = value
    update_aligned()

func update_aligned():
    if original_pos == null:
        return
    match aligned:
        Align.Left:
            pass
        Align.Right:
            self.position = original_pos + Vector2.LEFT * FONT_WIDTH * (l - 1) * self.scale
        Align.Center:
            self.position = original_pos + Vector2.LEFT * FONT_WIDTH * (l - 1) / 2 * self.scale

func _ready():
    update_aligned()
