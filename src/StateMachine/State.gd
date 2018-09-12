extends Object
class_name State

var transitions:Dictionary = {}
var target:Node2D
var name:String = 'base state'

func _init(object):
    target = object
    
func enter()->void:
    pass
    
func exit()->void:
    pass
    
func _process(_delta:float)->void:
    pass
    
func _physics_process(_delta:float)->void:
    pass

func add_transition(function:String, state_name:String)->void:
    transitions[function] = state_name
    
func check_transitions()->String:
    for fname in transitions.keys():
        if call(fname):
            return transitions[fname]
    return ""