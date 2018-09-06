extends RigidBody2D

onready var collider = get_node("CollisionShape2D")
export var radius = 16 setget set_radius
var default_radius = radius
var max_distance = radius * 2
var time = 0
var puddle

func _ready():
    collider.shape.radius = radius * 0.9
    linear_velocity= polar2cartesian(0.1, randi() * 4 * PI)

func _physics_process(delta):
    var puddle_vec = position - puddle.position
    if puddle_vec.length() >  max_distance:
        queue_free()
        return
    var move = Vector2()
    if puddle.get('surface_tension'):
        var dist = puddle_vec.length()
        move -= puddle_vec * puddle.surface_tension
    if move.length() < 0.1:
        move = Vector2()
    apply_impulse(Vector2(), move)

    time += delta
    
    if time > 0.1:
        var scale_factor = (max_distance/2 - puddle_vec.length()) / (max_distance/2)
        var radius_adjusted = default_radius * clamp(scale_factor, 0.5, 1.0)
        if abs(radius - radius_adjusted) > 0.1:
            _set_radius(lerp(radius,radius_adjusted,0.1))
        time = 0
    
func set_radius(r):
    default_radius = r
    _set_radius(r)
    
func _set_radius(r):
    radius = r
    if collider and collider.shape:
        collider.shape.radius = radius * 0.3
    max_distance = r * 20
    update()
    
func _draw():
    draw_circle(Vector2(), radius, Color(1,1,1))

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()