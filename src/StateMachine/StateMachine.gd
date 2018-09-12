extends Object
class_name StateMachine

var states:Dictionary = {}
var state:State setget _set_state

func check_transitions()->void:
    var new_state:String = state.check_transitions()
    if new_state:
        print(new_state)
        state.exit()
        state = states[new_state]
        state.enter()

func add_state(state:State)->void:
    states[state.name] = state
    
func _set_state(state_name)->void:
    state = states[state_name]
    
func add_transition(state_name:String, function:String, destination_state_name:String)->void:
    states[state_name].add_transition(function, destination_state_name)
        
func _physics_process(_delta:float)->void:
    state._physics_process(_delta)

func _process(_delta:float)->void:
    state._process(_delta)
