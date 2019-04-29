extends Control

signal start_pressed
signal continue_pressed


func _on_Start_pressed():
    emit_signal("start_pressed")

func _on_Continue_pressed():
    emit_signal("continue_pressed")

func has_continue(yes: bool):
    $Continue.disabled = not yes
