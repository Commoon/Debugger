extends Control

signal ended

var over := false

func _ready():
    $AnimationPlayer.play("Opening")

func end():
    over = true
    emit_signal("ended")

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        if not over:
            emit_signal("ended")
