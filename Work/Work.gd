extends Node2D

class_name Work

const MAX_TIME = 120.0
const MAX_LIFE = 100.0

var life := MAX_LIFE setget set_life
var time := MAX_TIME setget set_time
var score := 0 setget set_score
export var target_score := 30 setget set_target_score

var started := false

enum BugType {
    Linear, Harmonic
}

signal game_over

onready var bug_prefab := preload("res://Work/Bug.tscn")
onready var bug_scripts := {
    BugType.Linear: preload("res://Work/Bugs/Linear.gd"),
    BugType.Harmonic: preload("res://Work/Bugs/Harmonic.gd")
}
onready var player := $Player


func _process(delta):
    if self.started:
        self.time -= delta

func start(target_score):
    get_tree().paused = false
    self.started = true
    self.target_score = target_score

func set_life(value):
    life = value

func set_time(value):
    time = value
    if time <= 0:
        self.end(true)

func set_score(value):
    score = value
    print("Score: ", score)

func set_target_score(value):
    target_score = value

func _on_Bug_tree_exiting():
    var t = self.bug_prefab.instance()
    t.set_script(self.bug_scripts[BugType.Harmonic])
    t.connect("tree_exiting", self, "_on_Bug_tree_exiting")
    $Bugs.add_child(t)

func _input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        var direction = event.position - self.player.position
        self.player.attack(direction.normalized())

func _on_Walls_body_entered(body):
    var bug = body.get_parent()
    if bug is Bug:
        (bug as Bug).destroy()

func _on_Player_debugged(bug: Bug):
    self.score += bug.value
    bug.destroy()

func end(timeup):
    self.started = false
    get_tree().paused = true
    emit_signal("game_over", timeup, self.score)
