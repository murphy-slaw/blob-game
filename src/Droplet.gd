extends RigidBody2D

onready var collider = get_node("CollisionShape2D")
onready var sprite = get_node("Sprite");
export var radius = 16 setget set_radius
var default_radius = radius
var max_distance = 300
var time = 0
var puddle = Node2D.new()
var nav = Node2D.new()
var map = Node2D.new()

func _ready():
    collider.shape.radius = radius * 0.4
    linear_velocity= polar2cartesian(0.1, randi() * 4 * PI)

func _physics_process(delta):
    var goal = puddle.position
    nav = get_node("../Navigation2D")
    if nav.has_method('get_simple_path'):
        var closest = nav.get_closest_point(position)
        var path = nav.get_simple_path(closest, goal)
        if path:
            goal = path[1]
    var puddle_vec = position - puddle.position
    var puddle_distance = puddle_vec.length()
    var goal_vec = position - goal
    
    goal_vec = linear_velocity.normalized() - goal_vec.normalized() * 25
    
    var move = Vector2()
    if puddle.get('surface_tension'):
        if puddle_distance <= 6 * radius:
            move = goal_vec * puddle.surface_tension
        else:
            move = goal_vec

    apply_central_impulse(move)
    
func set_radius(r):
    default_radius = r
    _set_radius(r)
    
func _set_radius(r):
    radius = r
    if collider and collider.shape:
        collider.shape.radius = radius * 0.3
        sprite.update();
    update()

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()