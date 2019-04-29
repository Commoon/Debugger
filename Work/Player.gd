extends Node2D

class_name Player

signal attack_over
signal missed
signal catched
signal debugged

export var attack_speed: float = 450
export var return_speed: float = 800
export var catch_speed: float = 600
export var body_radius := 70

var attacking := 0
var direction: Vector2

var speed_scale := 1.0

var current_bug: Bug = null

onready var body := $Body
onready var tongue := $Body/Tongue
onready var attacking_point := $AttackingPoint
var tongue_in_body := true

onready var slacking_off_sprites := [
    $"SlackingOff-Phone",
    $"SlackingOff-ZZZ"
]
var slacking_off := -1


func attack(direction):
    if slacking_off >= 0 or self.attacking > 0:
        return
    self.direction = direction
    self.attacking = 1

func slack_off(ok):
    if ok and slacking_off == -1:
        slacking_off = int(floor(randf() * len(slacking_off_sprites)))
        body.visible = false
        slacking_off_sprites[slacking_off].visible = true
    elif not ok and slacking_off >= 0:
        slacking_off_sprites[slacking_off].visible = false
        body.visible = true
        slacking_off = -1

func rotate(phi: float):
    self.rotation = phi + PI / 2

func set_speed_scale(scale: float):
    self.speed_scale = scale

func _physics_process(delta):
    delta *= speed_scale
    if self.attacking == 1:
        self.attacking_point.global_position += self.direction * delta * self.attack_speed
    elif self.attacking == 2:
        self.attacking_point.global_position -= self.direction * delta * self.return_speed
    elif self.attacking == 3:
        if not is_instance_valid(self.current_bug):
            return
        self.attacking_point.global_position -= self.direction * delta * self.catch_speed * self.current_bug.weight_coeff * self.current_bug.size
        self.current_bug.global_position = self.attacking_point.global_position
    var l = (self.attacking_point.global_position - self.global_position).length() - body_radius
    tongue.offset = Vector2.UP * l / 2
    tongue.region_rect.size.y = l

func _on_AttackingPoint_body_entered(body):
    if self.attacking != 1:
        return
    var bug = body.get_parent()
    if bug is Bug:
        bug = bug as Bug
        bug.is_catched = true
        self.current_bug = bug
        self.attacking = 3
        emit_signal("catched", bug)
        if self.tongue_in_body:
            self.eat()

func _on_AttackingPoint_area_entered(area: Area2D):
    if self.attacking == 1 and area.get_collision_layer_bit(Utils.Layer.Wall):
        self.attacking = 2
        emit_signal("missed")

func eat():
    self.attacking_point.position = Vector2.UP * body_radius
    self.attacking = 0
    if self.current_bug != null:
        self.current_bug.visible = false
        emit_signal("debugged", self.current_bug)
        self.current_bug = null
    

func _on_Body_area_entered(area):
    if area.get_parent() != self:
        return
    self.tongue_in_body = true
    emit_signal("attack_over")
    if self.attacking == 2 or self.attacking == 3:
        self.eat()

func _on_Body_area_exited(area):
    if area.get_parent() != self:
        return
    self.tongue_in_body = false
