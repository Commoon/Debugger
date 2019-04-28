extends Node2D

class_name Work

const MAX_TIME = 60.0
const MAX_LIFE = 100.0

export var life_usage_factor = 0.04
export var life_usage_miss = 20.0
var life_usage_current := 0.0
var life := MAX_LIFE setget set_life
var time := MAX_TIME setget set_time
var score := 0 setget set_score
var target_score := 0 setget set_target_score

var started := false

enum BugType {
    Linear, Harmonic, Polygon
}

var bug_type_probs := []
var n_bugs := 0

signal game_over

onready var bug_prefab := preload("res://Work/Bug.tscn")
onready var bug_scripts := {
    BugType.Linear: preload("res://Work/Bugs/Linear.gd"),
    BugType.Harmonic: preload("res://Work/Bugs/Harmonic.gd"),
    BugType.Polygon: preload("res://Work/Bugs/Polygon.gd")
}
onready var player := $Player
onready var bugs := $Bugs
onready var life_bar := $UI/Life


func _process(delta):
    if self.started:
        self.time -= delta

func start(stage_setting):
    self.target_score = stage_setting["target_score"]
    self.bug_type_probs = stage_setting["bug_types"]
    self.n_bugs = stage_setting["n_bugs"]
    for i in range(self.n_bugs):
        generate_bug()
    get_tree().paused = false
    self.started = true

func set_life(value):
    life = value
    life_bar.value = value / MAX_LIFE * life_bar.max_value
    print("Life: ", life)
    if life <= 0:
        self.end(false)

func set_time(value):
    time = value
    if time <= 0:
        self.end(true)

func set_score(value):
    score = value
    print("Score: ", score)

func set_target_score(value):
    target_score = value

func generate_bug():
    var r = randf() * 100
    var i = 0
    while i < len(bug_type_probs) and r > bug_type_probs[i]:
        r -= bug_type_probs[i]
        i += 1
    if i == len(bug_type_probs):
        i -= 1
    var bug = self.bug_prefab.instance()
    bug.set_script(self.bug_scripts[i])
    bug.connect("tree_exiting", self, "_on_Bug_tree_exiting")
    bugs.call_deferred("add_child", bug)

func _on_Bug_tree_exiting():
    generate_bug()

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

func _on_Player_catched(bug: Bug):
    self.life_usage_current = (bug.global_position - player.position).length() * self.life_usage_factor

func _on_Player_missed():
    self.life_usage_current = self.life_usage_miss
    
func _on_Player_attack_over():
    self.life -= self.life_usage_current
    self.life_usage_current = 0.0

func end(timeup):
    self.started = false
    get_tree().paused = true
    emit_signal("game_over", timeup)
    