extends Node

export var bug_values := [30, 20, 10]
export var bug_radii := [20, 30, 40]
export var bug_probs := [20, 30, 50]
onready var bug_textures := [
    preload("res://Assets/Work/Bug/Bug-1.png"),
    preload("res://Assets/Work/Bug/Bug-2.png"),
    preload("res://Assets/Work/Bug/Bug-3.png")
]
onready var n_types = len(bug_values)
