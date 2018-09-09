extends RigidBody2D

onready var collider = get_node("CollisionShape2D")
onready var sprite = get_node("Sprite");
export var radius = 16 setget set_radius
var default_radius = radius
var max_distance = 300
var time = 0
var puddle = Node2D.new()
var nav = Node2D.new()

func _ready():
    collider.shape.radius = radius * 0.4
    linear_velocity= polar2cartesian(0.1, randi() * 4 * PI)

func _physics_process(delta):
    var goal = puddle.position
    nav = get_node("../Navigation2D")
    if nav.has_method('get_simple_path'):
        var path = nav.get_simple_path(position, goal)
        if path:
            goal = path[1]
    var puddle_vec = position - goal
    var move = Vector2()
    if puddle.get('surface_tension'):
        move -= puddle_vec * puddle.surface_tension
    apply_impulse(Vector2(), move)
    
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