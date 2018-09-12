tool

extends Polygon2D

export var chamfer = 2 setget _set_chamfer
export (float) var radius = 10 setget _set_radius
export (float) var tooth_length = 2.5 setget _set_tooth_length
export (int) var num_teeth = 5 setget _set_num_teeth
export (int) var refinement = 16 setget _set_refinement
export (bool) var straight_teeth = false setget _set_straight_teeth
export (bool) var start_on_tooth = false setget _set_start_on_tooth

func _set_chamfer(c):
    chamfer = c
    update()

func _set_radius(r):
    radius = r
    update()
    
func _set_tooth_length(t):
    tooth_length = t
    update()
    
func _set_num_teeth(n):
    num_teeth = n
    update()

func _set_refinement(r):
    refinement = r
    update()
    
func _set_straight_teeth(b):
    straight_teeth = b
    update()
    
func _set_start_on_tooth(b):
    start_on_tooth = b
    update()

func update():
    polygon = build_gear(Vector2(), radius, tooth_length, num_teeth)
    uv = build_gear(Vector2(), radius - 4, 0 , num_teeth)
    if is_inside_tree() and texture:
        var tsize = texture.get_size()
        texture_scale.x = tsize.x / radius / 2
        texture_scale.y = tsize.y / radius / 2
        texture_offset = Vector2(radius, radius)
    .update()
    
func get_collision_poly():
    return build_gear(Vector2(), radius, tooth_length, num_teeth, 1)

func _ready():
    update()
    
func add_circle_arc(points_arc, center, radius, angle_from, angle_to, refinement):
    var nb_points = refinement

    for i in range(nb_points+1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
    return points_arc

    
func build_gear(center, radius, tooth_length, num_teeth=5, ref=refinement):
    
    var tooth_ref = ref
    if straight_teeth:
        tooth_ref = 1
    
    var points = PoolVector2Array()
    
    var dtheta = PI/num_teeth;
    var dtheta_degrees = rad2deg(dtheta)
    var tooth_width = radius * dtheta - chamfer;
    var alpha = tooth_width / (radius + tooth_length)
    var alpha_degrees = rad2deg(alpha)
    var phi = (dtheta - alpha) / 2
    
    var theta = -dtheta / 2
    if start_on_tooth:
        theta = dtheta / 2
    
    for _i in range(num_teeth):
        var degrees = rad2deg(theta)
        points = add_circle_arc(points, center, radius, degrees, degrees + dtheta_degrees, ref)
        theta += dtheta
        
        degrees = rad2deg(theta + phi)
        points = add_circle_arc(points, center, radius + tooth_length, degrees, degrees + alpha_degrees, tooth_ref)
        theta += dtheta
    
    return points