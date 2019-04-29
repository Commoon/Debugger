extends Node

var timers := {}
var time := 0.0
var ids := 0


func _ready():
    pass


func _process(delta):
    time += delta
    var to_call = []
    for id in timers:
        if timers[id]["time"] <= time:
            to_call.push_back(id)
    for id in to_call:
        if is_instance_valid(timers[id]["invoker"]):
            timers[id]["invoker"].call_deferred(timers[id]["callback"], timers[id]["arg"])
        timers.erase(id)

func set_timeout(delay, invoker, callback, arg=null):
    ids += 1
    timers[ids] = {
        "time": time + delay,
        "invoker": invoker,
        "callback": callback,
        "arg": arg
    }