extends RigidBody2D

onready var collider = get_node("CollisionShape2D")
onready var sprite = get_node("Sprite");
export var radius = 16 setget set_radius
var default_radius = radius
var max_distance = 200
var time = 0
var puddle = Node2D.new()

func _ready():
    collider.shape.radius = radius * 0.4
    linear_velocity= polar2cartesian(0.1, randi() * 4 * PI)

func _physics_process(delta):
    var puddle_vec = position - puddle.position
    if puddle_vec.length() >  max_distance:
        queue_free()
        return
    var move = Vector2()
    if puddle.get('surface_tension'):
#        var dist = max(puddle_vec.length(), 4 * radius) - 4 * radius
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
    
#func _draw():
#    draw_circle(Vector2(), radius, Color(1,1,1))

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()