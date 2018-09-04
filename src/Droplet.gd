extends RigidBody2D

onready var collider = get_node("CollisionShape2D")
onready var parent = get_parent()
export var radius = 16 setget set_radius
var default_radius = radius
var max_distance = radius * 15
var time = 0

func _ready():
    collider.shape.radius = radius * 0.4

func _physics_process(delta):
    if position.length() >  radius * 15:
        queue_free()
        return
    var move = Vector2()
    if parent.get('surface_tension'):
        var vec = self.position
        var dist = vec.length()
        move -= vec * parent.surface_tension
    if move.length() < 0.1:
        move = Vector2()
    apply_impulse(Vector2(), move)
    
    time += delta
    if time > 1:
        var scale_factor = (max_distance - position.length()) / max_distance
        var radius_adjusted = default_radius * clamp(scale_factor, 0.1 ,1)
        if abs(radius - radius_adjusted) > 0.1:
            _set_radius( default_radius * clamp(scale_factor, 0.05, 1) )
        time = 0
    
func set_radius(r):
    default_radius = r
    _set_radius(r)
    
func _set_radius(r):
    radius = r
    if collider and collider.shape:
        collider.shape.radius = radius * 0.3
    update()
    
func _draw():
    draw_circle(Vector2(), radius, Color(1,1,1))