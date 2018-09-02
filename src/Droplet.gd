extends KinematicBody2D

onready var collider = get_node("CollisionShape2D")
onready var area = get_node("Area2D")
onready var area_coll = get_node("Area2D/CollisionShape2D")
onready var parent = get_parent()
var lv = polar2cartesian(1, randi() * 4 * PI)
export var radius = 16 setget set_radius
onready var poly = build_regular_poly(Vector2(), radius, 12)

func _ready():
    collider.shape.radius = radius * 0.3
    area_coll.shape.radius = radius + 2

func _physics_process(delta):
    if position.length() > 10 * radius:
        queue_free()
        return
    var move = Vector2()
    var pal
    var neighbors = area.get_overlapping_bodies()
    for neighbor in neighbors:
        if neighbor.is_in_group('Droplets'):
            pal = neighbor
            break
    if pal:
        move += (self.position - pal.position).normalized()
    if parent.get('surface_tension'):
        move *= parent.surface_tension
        var vec = self.position
        move -= vec.normalized() * sqrt(vec.length()) * sign(parent.surface_tension)
        move += Vector2(0,1) * parent.gravity * 0.1
    lv += move
    move_and_slide(lv, Vector2(0, -1), 5, 2, deg2rad(10))
    lv *= 0.95

func set_radius(r):
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
#    draw_colored_polygon(poly,Color(1,1,1))
    draw_circle(Vector2(), radius, Color(1,1,1))