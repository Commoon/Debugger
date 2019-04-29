extends Control

signal start_pressed
signal continue_pressed


func _on_Start_pressed():
    Utils.play_sound()
    $Agreement.visible = true

func _on_Continue_pressed():
    Utils.play_sound()
    emit_signal("continue_pressed")

func has_continue(yes: bool):
    $Continue.disabled = not yes

func _on_Agree_pressed():
    Utils.play_sound()
    emit_signal("start_pressed")
    $Agreement.visible = false

func _on_Background_gui_input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        $Agreement.visible = false
