extends KinematicBody2D

onready var collider = get_node("CollisionShape2D")
onready var area = get_node("Area2D")
onready var area_coll = get_node("Area2D/CollisionShape2D")
onready var parent = get_parent()
var lv = polar2cartesian(1, randi() * 4 * PI)
export var radius = 16 setget set_radius
var default_radius = radius
onready var poly = build_regular_poly(Vector2(), radius, 12)
var max_speed = 200
var time = 0

func _ready():
    collider.shape.radius = radius * 0.3
    area_coll.shape.radius = radius + 6

func _physics_process(delta):
    if position.length() >  radius * 20:
        queue_free()
        return
    var move = Vector2()
    move += parent.gravity * Vector2(0, 0.1)
    var neighbors = area.get_overlapping_bodies()
    if parent.get('surface_tension'):
        var vec = self.position
        var dist = vec.length()
        move -= vec
        
        for neighbor in neighbors:
            if neighbor.is_in_group('Droplets'):
                var pal_vec = position - neighbor.position
                if pal_vec.length() > 4:
                    move -= pal_vec * 0.01
#                    break

        time += delta
        if time > 5:
            print(move)
            time = 0 
        
    if move.length() < 0.01:
        move = Vector2()
    lv += move
    lv = lv.clamped(max_speed)
    move_and_slide(lv, Vector2(0, -1))
    lv *= 0.99
    
func set_radius(r):
    default_radius = r
    _set_radius(r)
    
func _set_radius(r):
    radius = r
    if collider and collider.shape:
        collider.shape.radius = radius * 0.3
        area_coll.shape.radius = radius + 2
        poly = build_regular_poly(Vector2(), radius, 32)
    update()
    
func build_regular_poly(center, radius, num_points = 8):
    var points = PoolVector2Array()

    for i in range(num_points+1):
        var angle_point = deg2rad(i * 360 / num_points - 90)
        points.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    return points
    
func _draw():
    draw_circle(Vector2(), radius, Color(1,1,1))