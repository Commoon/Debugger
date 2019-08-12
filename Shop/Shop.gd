extends Control

signal next_day
signal buy

var life_shop = [
    { "price": 30, "description": "Life gets stronger." },
    { "price": 30, "description": "Speed up debugging." }
]

var money_shop = [
    { "price": 80, "description": "Work longer." }
]

var selected_in_life_shop := false
var selected_item_id := -1
var life := 0
var money := 0
var buffs := [0, 0]
var n_coffee := 0

onready var dialog = $Dialog

func _ready():
    $Dumbbell.connect("pressed", self, "_on_item_pressed", [
        true, 0, $Dumbbell/DialogPos
    ])
    $FoamRoller.connect("pressed", self, "_on_item_pressed", [
        true, 1, $FoamRoller/DialogPos
    ])
    $Coffee.connect("pressed", self, "_on_item_pressed", [
        false, 0, $Coffee/DialogPos
    ])
    dialog.visible = false

func start(life, money, buffs, n_coffee):
    self.life = life
    self.money = money
    self.buffs = buffs
    self.n_coffee = n_coffee

func _on_NextDay_pressed():
    $Transition.show()

func _on_item_pressed(in_life_shop, item_id, pos_node):
    var item = (life_shop if in_life_shop else money_shop)[item_id]
    dialog.get_node("Label").text = item["description"] + "\n" + (
        ("Exercise times: " + str(buffs[item_id])) if in_life_shop else ("Bought: " + str(n_coffee))
    ) + "\n" + (
        "Spend Life to exercise." if in_life_shop else "Purchase with Salary."
    )
    dialog.rect_position = pos_node.global_position + Vector2.UP * dialog.rect_size.y + \
        (Vector2.LEFT * dialog.rect_size.x if not in_life_shop else Vector2.ZERO)
    dialog.get_node("Background").flip_h = not in_life_shop
    var balance = life if in_life_shop else money
    dialog.get_node("Buy").disabled = item["price"] > balance
    dialog.get_node("Price").text = str(item["price"]) + "/" + str(balance)
    selected_in_life_shop = in_life_shop
    selected_item_id = item_id
    Utils.play_sound()
    $Transition.visible = false
    dialog.visible = true


func _on_Buy_pressed():
    if selected_item_id == -1:
        return
    var item = (life_shop if selected_in_life_shop else money_shop)[selected_item_id]
    var balance = life if selected_in_life_shop else money
    if item["price"] > balance:
        return
    dialog.visible = false
    Utils.play_sound(Utils.SoundEffect.Shop)
    emit_signal("buy", selected_in_life_shop, selected_item_id, item)


func _unhandled_input(event):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
        dialog.visible = false


func _on_Transition_pressed():
    emit_signal("next_day")
