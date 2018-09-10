extends Object
class_name StateMachine

var states = {}
var state setget _set_state

func check_transitions():
    var new_state = state.check_transitions()
    if new_state:
        state.exit()
        state = states[new_state]
        state.enter()

func add_state(state):
    states[state.name] = state
    print(states)
    
func _set_state(state_name):
    state = states[state_name]
    
func add_transition(state, function, destination_state):
    states[state].add_transition(function, destination_state)
        
func _physics_process(delta):
    state._physics_process(delta)

func _process(delta):
    state._process(delta)
