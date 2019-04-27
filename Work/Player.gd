extends Node2D

class_name Player

signal debugged

export var attack_speed: float = 450
export var return_speed: float = 800
export var catch_speed: float = 500

var attacking := 0
var direction: Vector2

var current_bug: Bug = null

onready var attacking_point := $AttackingPoint
var tongue_in_body := true


func attack(direction):
    if self.attacking > 0:
        return
    self.direction = direction
    self.attacking = 1

func _physics_process(delta):
    if self.attacking == 1:
        self.attacking_point.position += self.direction * delta * self.attack_speed
    elif self.attacking == 2:
        self.attacking_point.position -= self.direction * delta * self.return_speed
    elif self.attacking == 3:
        if not is_instance_valid(self.current_bug):
            return
        self.attacking_point.position -= self.direction * delta * self.catch_speed * self.current_bug.weight_coeff
        self.current_bug.global_position = self.attacking_point.global_position

func _on_AttackingPoint_body_entered(body):
    if self.attacking != 1:
        return
    var bug = body.get_parent()
    if bug is Bug:
        bug = bug as Bug
        bug.is_catched = true
        self.current_bug = bug
        self.attacking = 3
        if self.tongue_in_body:
            self.eat()

func _on_AttackingPoint_area_entered(area: Area2D):
    if self.attacking == 1 and area.get_collision_layer_bit(Utils.Layer.Wall):
        self.attacking = 2

func eat():
    self.attacking_point.position = Vector2.ZERO
    self.attacking = 0
    if self.current_bug != null:
        self.current_bug.visible = false
        emit_signal("debugged", self.current_bug)
        self.current_bug = null
    

func _on_Body_area_entered(area):
    if area.get_parent() != self:
        return
    self.tongue_in_body = true
    if self.attacking == 2 or self.attacking == 3:
        self.eat()

func _on_Body_area_exited(area):
    if area.get_parent() != self:
        return
    self.tongue_in_body = false
