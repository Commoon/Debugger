extends Node2D

class_name Work

const MAX_TIME := 60.0
const MAX_LIFE := 100.0
const BUFF1 := [1.0, 0.8, 0.7, 0.65, 0.6, 0.55, 0.5]
const BUFF2 := [1.0, 1.2, 1.4, 1.55, 1.7, 1.85, 2.0]

export var life_usage_factor := 0.03
export var slacking_off_scale := 4.0
export var coffee_buff := 15.0
var min_time := 0
var life_usage_current := 0.0
var life := MAX_LIFE setget set_life
var time := MAX_TIME setget set_time
var score := 0 setget set_score
var target_score := 0 setget set_target_score
var bug_counts := []
var buffs := [0, 0] setget set_buffs
var coffee_count setget set_coffee
var attack_life_scale := 1.0
var attack_speed_scale := 1.0
var level

var started := false
var is_slacking_off := false

enum BugType {
    Linear, Harmonic, Polygon, Circle
}

var bug_traj_probs := []
var n_bugs := 0

signal game_over

onready var bug_prefab := preload("res://Work/Bug.tscn")
onready var bug_scripts := {
    BugType.Linear: preload("res://Work/Bugs/Linear.gd"),
    BugType.Harmonic: preload("res://Work/Bugs/Harmonic.gd"),
    BugType.Polygon: preload("res://Work/Bugs/Polygon.gd"),
    BugType.Circle: preload("res://Work/Bugs/Circle.gd")
}
onready var player := $Player
onready var bugs_node := $Bugs
onready var life_bar := $UI/Life
onready var hour_hand := $UI/Clock/Hour
onready var mouse_pos: Vector2 = player.position + Vector2.UP
onready var bug_count_labels := [
    $UI/BugCounts/Count1,
    $UI/BugCounts/Count2,
    $UI/BugCounts/Count3
]
onready var coffee_count_label := $UI/CoffeeCounts/CountLabel
onready var current_score_label := $UI/CurrentScore
onready var coffee_drunk := false
onready var target_point := $TargetPoint
onready var goofing_off := $UI/GoofingOff
onready var drink_prompt := $UI/DrinkPrompt

var bugs_presets := {}


func _process(delta):
    if self.started:
        self.time -= delta

func start(level, score, buffs, n_coffee, stage_setting):
    self.target_score = stage_setting["target_score"]
    if stage_setting.has("bugs") and stage_setting["bugs"] != null:
        var bugs_node = load(stage_setting["bugs"]).instance() as Node2D
        var bugs = bugs_node.get_children()
        self.n_bugs = len(bugs)
        bugs_presets = {}
        for bug in bugs:
            bug.connect("tree_exiting", self, "_on_Bug_tree_exiting", [bug])
            if bug.auto_respawn:
                bugs_presets[bug.name] = bug.duplicate()
        self.bugs_node.add_child(bugs_node)
    else:
        self.bug_traj_probs = stage_setting["bug_trajs"]
        self.n_bugs = stage_setting["n_bugs"]
        for i in range(self.n_bugs):
            generate_bug()
    bug_counts = []
    for i in range(BugTypes.n_types):
        bug_counts.push_back(0)
    get_tree().paused = false
    self.started = true
    goofing_off.visible = false
    $UI/Level/Number.text = str(level)
    self.level = level
    self.score = score
    self.buffs = buffs
    self.coffee_count = n_coffee

func set_life(value):
    life = value
    var x = value / MAX_LIFE * life_bar.max_value
    if x < 2:
        x = 2
    life_bar.value = x
    if life <= 0:
        self.end(false)

func set_time(value):
    time = value
    hour_hand.rotation_degrees = (MAX_TIME - value) / MAX_TIME * 360 - 90
    if coffee_count > 0 and not coffee_drunk and time - min_time <= 15 and \
            score < target_score and not drink_prompt.visible:
        drink_prompt.show()
        drink_prompt.get_node("AnimationPlayer").play("Flash")
    if time <= min_time:
        self.end(true)

func set_score(value):
    score = value
    current_score_label.text = str(score)
    if score >= target_score and not goofing_off.visible:
        goofing_off.show()
        goofing_off.get_node("AnimationPlayer").play("Flash")

func set_coffee(value):
    coffee_count = value
    coffee_count_label.text = str(coffee_count)

func set_buffs(value):
    buffs = value
    attack_life_scale = BUFF1[int(clamp(value[0], 0, len(BUFF1) - 1))]
    attack_speed_scale = BUFF2[int(clamp(value[0], 0, len(BUFF2) - 1))]
    player.set_speed_scale(attack_speed_scale)

func set_target_score(value):
    target_score = value
    $UI/TargetScore.text = "/" + str(target_score)

func generate_bug():
    var i = Utils.multinomial(bug_traj_probs)
    var bug = self.bug_prefab.instance()
    bug.set_script(self.bug_scripts[i])
    bug.connect("tree_exiting", self, "_on_Bug_tree_exiting", [bug])
    bugs_node.call_deferred("add_child", bug)

func _on_Bug_tree_exiting(bug: Bug):
    if not bug.auto_respawn:
        generate_bug()
    else:
        Timers.set_timeout(bug.respawn_time, self, "respawn", bug.name)

func respawn(bug_name):
    var new_bug = bugs_presets[bug_name].duplicate()
    new_bug.connect("tree_exiting", self, "_on_Bug_tree_exiting", [new_bug])
    bugs_node.call_deferred("add_child", new_bug)
    
func rotate_player():
    var direction = mouse_pos - self.player.position
    self.player.rotate(direction.angle())

func _input(event):
    if event is InputEventMouseMotion:
        mouse_pos = event.position
        if self.player.attacking == 0:
            rotate_player()
    elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        var direction = (event.position - self.player.position)
        if direction.length() <= player.body_radius + 16 or not self.player.can_attack():
            return
        direction = direction.normalized()
        target_point.position = event.position + direction * 16
        target_point.visible = true
        Utils.play_sound(Utils.SoundEffect.Tongue)
        self.player.attack(direction)
    elif event is InputEventKey:
        if event.scancode == KEY_Z:
            if player.attacking > 0:
                return
            if not is_slacking_off and event.is_pressed():
                Engine.time_scale = slacking_off_scale
                is_slacking_off = true
                player.slack_off(true)
            elif is_slacking_off and not event.is_pressed():
                Engine.time_scale = 1.0
                is_slacking_off = false
                player.slack_off(false)
        elif event.scancode == KEY_SPACE:
            if coffee_count > 0 and not coffee_drunk:
                coffee_drunk = true
                self.coffee_count -= 1
                min_time -= coffee_buff

func _on_Walls_body_entered(body):
    var bug = body.get_parent()
    if bug is Bug:
        (bug as Bug).destroy()

func inc_bug_counts(type):
    bug_counts[type] += 1
    bug_count_labels[type].text = str(bug_counts[type])

func _on_Player_debugged(bug: Bug):
    inc_bug_counts(bug.bug_type)
    self.score += bug.value
    bug.destroy()

func _on_Player_catched(bug: Bug):
    target_point.visible = false
    Utils.play_sound(Utils.SoundEffect.Hit)
    self.life_usage_current = (bug.global_position - player.position).length() * self.life_usage_factor

func _on_Player_missed(pos: Vector2):
    target_point.visible = false
    self.life_usage_current = (pos - player.position).length() * self.life_usage_factor
    
func _on_Player_attack_over():
    self.life -= self.life_usage_current * attack_life_scale
    self.life_usage_current = 0.0
    rotate_player()

func end(timeup):
    if is_slacking_off:
        Engine.time_scale = 1.0
    self.started = false
    get_tree().paused = true
    life = floor(life)
    if life == 0:
        life = 1
    emit_signal("game_over", timeup, self)
