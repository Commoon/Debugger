extends Node2D

class_name GameManager

onready var work_prefab := preload("res://Work/Work.tscn")
var current_stage: Work = null


func start_stage():
    self.current_stage = self.work_prefab.instance()
    self.add_child(current_stage)
    self.current_stage.connect("game_over", self, "_on_game_over")

func _on_game_over(timeup: bool, score: int):
    self.current_stage.queue_free()
    if timeup:
        print("Time Up!")

func _ready():
    start_stage()
