extends Control

class_name ResultList

signal dismissed

const SUCCESS_TEXTURE = preload("res://Assets/Work/ResultList/Pass.png")
const FAILURE_TEXTURE = preload("res://Assets/Work/ResultList/Fail.png")

export var pause_time := 0.2
var started := false
var finished := false
var new_balance := 0
var score := 0
var time := 0.0
var n_elements := 0
var now := 0
onready var dialog = $Dialog
onready var score_node = $Dialog/Score
onready var pass_node = $Dialog/Pass
var success := false


func _ready():
    self.visible = false


func start(balance, bug_values, bug_counts, life, score, target_score):
    finished = false
    started = false
    time = 0
    var elements = dialog.get_children()
    n_elements = len(elements)
    for each in elements:
        each.visible = false
    $Dialog/CurrentBalance.text = str(balance)
    new_balance = balance
    for i in range(3):
        var c = str(i + 1)
        var x = bug_values[i] * bug_counts[i]
        get_node("Dialog/Bug" + c + "-Icon/Bug" + c + "-Score").text = str(bug_values[i]) + " *"
        get_node("Dialog/Bug" + c + "-Count").text = str(bug_counts[i])
        get_node("Dialog/Bug" + str(i+1)).text = str(x)
        new_balance += x
    $Dialog/NewBalance.text = str(new_balance)
    $Dialog/Life.text = str(life) + "/100"
    $"Dialog/Life-Bar".value = life
    score_node.text = "/" + str(target_score)
    self.score = score
    success = score >= target_score
    $Dialog/Pass.texture = SUCCESS_TEXTURE if success else FAILURE_TEXTURE
    self.visible = true
    started = true
    now = 0


func _input(event):
    if finished and event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        self.visible = false
        emit_signal("dismissed", success, new_balance)


func _process(delta):
    if started:
        time += delta
        while time > pause_time:
            if now < n_elements - 1:
                dialog.get_child(now).visible = true
            elif now < n_elements:
                score_node.text = str(score) + score_node.text
            elif now == n_elements + 2:
                pass_node.visible = true
                started = false
                finished = true
                return
            now += 1
            time -= pause_time
