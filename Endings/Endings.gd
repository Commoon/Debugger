extends Control

signal back_pressed

func _on_Back_pressed():
    emit_signal("back_pressed")
