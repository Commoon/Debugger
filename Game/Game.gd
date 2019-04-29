extends Node2D

class_name GameManager

enum SceneType {
    Unknown,
    Opening,
    Title,
    Work,
    Shop,
    Ending
}
var current_scene_type = SceneType.Unknown setget set_scene_type

onready var opening_prefab := preload("res://Title/Opening.tscn")
onready var work_prefab := preload("res://Work/Work.tscn")
onready var shop_prefab := preload("res://Shop/Shop.tscn")
onready var title_prefab := preload("res://Title/Title.tscn")
onready var result_list_prefab := preload("res://Work/ResultList.tscn")
onready var bgm_resources := {
    SceneType.Opening: null,
    SceneType.Title: preload("res://Assets/Audio/BGM-Title_Shop.ogg"),
    SceneType.Shop: preload("res://Assets/Audio/BGM-Title_Shop.ogg"),
    SceneType.Work: preload("res://Assets/Audio/BGM-Work.ogg"),
    SceneType.Ending: preload("res://Assets/Audio/BGM-Ending.ogg")
}
var current_scene: Node = null

var accumulated_score := 0
var current_score := 0
var money_balance := 0
var last_life := 0
var current_level := 0
var buffs := [0, 0]
var n_coffee := 0
var paused := false

var stage_settings = [
    { "target_score": 80, "bugs": "res://Stages/Stage1.tscn" },
    { "target_score": 80, "bugs": "res://Stages/Stage2.tscn" },
    { "target_score": 90, "bugs": "res://Stages/Stage3.tscn" },
    { "target_score": 90, "bugs": "res://Stages/Stage4.tscn" },
    { "target_score": 100, "bugs": "res://Stages/Stage5.tscn" },
    { "target_score": 100, "bug_trajs": [30, 40, 30], "n_bugs": 6 },
    { "target_score": 110, "bug_trajs": [10, 45, 45], "n_bugs": 5 },
    { "target_score": 110, "bug_trajs": [20, 40, 40], "n_bugs": 5 }
]
onready var n_stages = len(stage_settings)
onready var scene_container = $Scene
onready var confirm_dialog = $ConfirmDialog
onready var confirm_dialog_text = $ConfirmDialog/Dialog/Text
onready var bgm_player = $BGMPlayer


func set_scene_type(value):
    current_scene_type = value
    var stream = bgm_resources[value]
    if bgm_player.stream == stream and bgm_player.playing:
        return
    bgm_player.stream = stream
    if bgm_player.stream != null:
        bgm_player.play()

func switch_scene(new_scene, type):
    if self.current_scene != null:
        self.current_scene.queue_free()
    self.current_scene = new_scene
    self.current_scene_type = type
    get_tree().paused = false
    Engine.time_scale = 1.0
    self.scene_container.add_child(new_scene)

func _on_buy(in_life_shop, item_id, item, shop):
    if in_life_shop:
        if item["price"] <= last_life:
            last_life -= item["price"]
            buffs[item_id] += 1
    else:
        if item["price"] <= money_balance:
            money_balance -= item["price"]
            if item_id == 0:
                n_coffee += 1
    shop.start(last_life, money_balance, buffs, n_coffee)

func prepare_stage(level=1):
    if level == 1:
        start_stage(1)
        return
    var shop = shop_prefab.instance()
    shop.connect("buy", self, "_on_buy", [shop])
    shop.connect("next_day", self, "start_stage", [level])
    switch_scene(shop, SceneType.Shop)
    shop.start(last_life, money_balance, buffs, n_coffee)

func start_stage(level=1):
#    while n_stages < level:
#        stage_settings.push_back({
#            "target_score": floor(n_stages / 2) * 10 + 80,
#            "bug_trajs": [30, 40, 30], "n_bugs": 5
#        })
#        n_stages = len(stage_settings)
#    var stage_setting = stage_settings[level-1]
    var stage_setting = stage_settings[(level-1) % n_stages].duplicate()
    stage_setting["target_score"] = floor((level - 1) / 2) * 10 + 80
    self.current_level = level
    var work = self.work_prefab.instance()
    work.connect("game_over", self, "_on_game_over")
    switch_scene(work, SceneType.Work)
    work.start(level, current_score, buffs, n_coffee, stage_setting)

func _on_game_over(timeup: bool, work: Work):
    if timeup:
        var result_list = result_list_prefab.instance()
        result_list.connect("dismissed", self, "_on_result_list_dismissed", [result_list])
        scene_container.add_child(result_list)
        result_list.start(money_balance, BugTypes.bug_values, work.bug_counts, work.life, work.score, work.target_score)
    else:
        var dead = load("res://Endings/Dead.tscn").instance()
        dead.connect("back_pressed", self, "_on_endings_back")
        switch_scene(dead, SceneType.Ending)

func _on_endings_back():
    start_title()

func _on_result_list_dismissed(success, new_balance, result_list):
    scene_container.remove_child(result_list)
    if success:
        var work = self.current_scene as Work
        accumulated_score += work.score
        current_score = work.score - work.target_score
        money_balance = new_balance
        last_life = work.life
        buffs = work.buffs
        n_coffee = work.coffee_count
        save_data()
        prepare_stage(current_level + 1)
    else:
        var fired = load("res://Endings/Fired.tscn").instance()
        fired.connect("back_pressed", self, "_on_endings_back")
        switch_scene(fired, SceneType.Ending)

func save_data():
    var data = {
        "version": Utils.VERSION_NUMBER,
        "accumulated_score": accumulated_score,
        "score": current_score,
        "money": money_balance,
        "life": last_life,
        "level": current_level,
        "buffs": buffs,
        "coffee": n_coffee
    }
    var save_file = File.new()
    save_file.open(Utils.SAVE_FILENAME, File.WRITE)
    save_file.store_line(to_json(data))
    save_file.close()

func get_saved_data():
    var save_file = File.new()
    if not save_file.file_exists(Utils.SAVE_FILENAME):
        return null
    save_file.open(Utils.SAVE_FILENAME, File.READ)
    var data = parse_json(save_file.get_line())
    save_file.close()
    if not data.has("version") or data["version"] != Utils.VERSION_NUMBER:
        return null
    return data

func load_saved_data():
    var data = get_saved_data()
    if data == null:
        return
    var level = int(data["level"])
    accumulated_score = int(data["accumulated_score"])
    current_score = int(data["score"])
    last_life = int(data["life"])
    money_balance = int(data["money"])
    buffs = data["buffs"]
    n_coffee = int(data["coffee"])
    prepare_stage(level + 1)

func clear_cached():
    accumulated_score = 0
    current_score = 0
    money_balance = 0
    last_life = 0
    current_level = 0
    buffs = [0, 0]
    n_coffee = 0

func start_title():
    clear_cached()
    var title = title_prefab.instance()
    title.has_continue(get_saved_data() != null)
    title.connect("start_pressed", self, "start_stage", [1])
    title.connect("continue_pressed", self, "load_saved_data")
    switch_scene(title, SceneType.Title)

func show_opening():
    var opening = opening_prefab.instance()
    opening.connect("ended", self, "_on_opening_ended")
    switch_scene(opening, SceneType.Opening)

func _on_opening_ended():
    start_title()

func _ready():
    Utils.audio_player = $SEPlayer
    show_opening()

func pause():
    paused = true
    get_tree().paused = true
    if self.current_scene_type == SceneType.Title:
        confirm_dialog_text.text = "Sure to Exit?"
    else:
        confirm_dialog_text.text = "Return to Title?"
    confirm_dialog.visible = true
    
func resume():
    confirm_dialog.visible = false
    paused = false
    get_tree().paused = false

func _input(event):
    if not paused and event is InputEventKey and event.scancode == KEY_ESCAPE:
        pause()

func _on_No_pressed():
    resume()

func _on_Yes_pressed():
    if self.current_scene_type == SceneType.Title:
        get_tree().quit()
    else:
        start_title()
        resume()
