extends Object
class_name State

var transitions = {}
var target = null
var name = 'base state'

func _init(object):
    target = object
    
func enter():
    pass
    
func exit():
    pass
    
func _process(delta):
    pass
    
func _physics_process(delta):
    pass

func add_transition(function, state):
    transitions[function] = state
    
func check_transitions():
    for fname in transitions.keys():
        if call(fname):
            print('transition %s succeeded' % fname)
            return transitions[fname]