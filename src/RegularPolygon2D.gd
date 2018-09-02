tool
extends Polygon2D

export var num_vertices = 4 setget set_num_vertices
export var radius = 1 setget set_radius
export var line_width = 1.0 setget set_line_width
export var line_color = Color(1, 1, 1, 1) setget set_line_color
export var bake = false setget set_bake

func _ready():
    polygon = build_regular_poly(Vector2(), radius, num_vertices)
    update()

func build_regular_poly(center, radius, num_points = 8):
    var points = PoolVector2Array()

    for i in range(num_points+1):
        var angle_point = deg2rad(i * 360 / num_points - 90)
        points.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    return points

func set_num_vertices(i):
    num_vertices = i
    update()
    
func set_radius(i):
    radius = i
    update()
    
func set_line_width(f):
    line_width = f
    update()

func set_line_color(c):
    line_color = c
    update()

func update():
    polygon = build_regular_poly(Vector2(), radius, num_vertices)
    .update()

func _draw():
#    for p in polygon:
#        p *= get_parent().scale
    draw_polyline(polygon, line_color, line_width, antialiased)
    
func set_bake(b):
    if b:
        generate_baked()

func generate_baked():
    var new_poly = Polygon2D.new()
    new_poly.polygon = polygon
    new_poly.rotation = rotation
    new_poly.position = position
    get_parent().add_child(new_poly)
    new_poly.set_owner(get_tree().get_edited_scene_root())

    