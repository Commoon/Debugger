extends Node2D

class_name GameManager

onready var work_prefab := preload("res://Work/Work.tscn")
onready var title_prefab := preload("res://Game/Title.tscn")
var current_stage: Node = null

var score := 0

var stage_settings = [
    { "target_score": 50, "bug_types": [100], "n_bugs": 6 },
    { "target_score": 100, "bug_types": [50, 50], "n_bugs": 5 },
    { "target_score": 150, "bug_types": [25, 25, 50], "n_bugs": 3 },
    { "target_score": 200, "bug_types": [30, 40, 30], "n_bugs": 4 }
]
onready var n_stages = len(stage_settings)
var level := 0

func switch_scene(new_scene):
    if self.current_stage != null:
        self.current_stage.queue_free()
    self.current_stage = new_scene
    self.add_child(new_scene)

func start_stage(level=1):
    while n_stages < level:
        var t = floor(log(level - n_stages)) * 5 + 50
        stage_settings.push_back({
            "target_score": stage_settings[n_stages-1]["target_score"] + t,
            "bug_types": [30, 40, 30], "n_bugs": 5
        })
        n_stages = len(stage_settings)
    self.level = level
    var stage_setting = stage_settings[level-1]
    var work = self.work_prefab.instance()
    work.connect("game_over", self, "_on_game_over")
    switch_scene(work)
    work.start(stage_setting)

func _on_game_over(timeup: bool):
    var new_scene = null
    if timeup:
        print("Time Up!")
    else:
        new_scene = load("res://Endings/Exhausted.tscn").instance()
    switch_scene(new_scene)

func get_saved_level():
    return 3  # TODO

func start_title():
    var title = title_prefab.instance()
    title.connect("start_pressed", self, "start_stage", [1])
    title.connect("continue_pressed", self, "start_stage", [self.get_saved_level()])
    switch_scene(title)

func _ready():
    start_title()
