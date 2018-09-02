extends KinematicBody2D
const Droplet = preload('res://Droplet.tscn')
export var droplet_count = 3
export var droplet_radius = 12
var droplets = []
var gravity = 7
var speed = 10
var lv = Vector2()
var default_surface_tension = 5
var surface_tension = default_surface_tension
var time = 0
func _ready():
    for i in range(droplet_count):
        spawn_droplet()
        
func spawn_droplet():
        var droplet = Droplet.instance()
        droplet.radius = droplet_radius + (4 - randi() % 8)
        add_child(droplet)

func get_nearest_droplet(pos):
    var nearest = null
    var min_distance = INF
    for droplet in get_droplets():
        var distance = (pos - droplet.position).length()
        if distance < min_distance:
            min_distance = distance
            nearest = droplet
    return nearest
    
func _process(delta):
    time += delta
    var move = Vector2()
    if Input.is_action_pressed('ui_left'):
        if is_on_wall() and $LeftRay.is_colliding():
            move += Vector2(0, -1) * speed
        else:
            move -= Vector2(1, 0) * speed
    elif Input.is_action_pressed('ui_right'):
        if is_on_wall() and $RightRay.is_colliding():
            move += Vector2(0, -1) * speed
        else:
            move += Vector2(1, 0) * speed
    if Input.is_action_pressed('ui_select'):
        surface_tension = 0
    elif Input.is_action_just_released('ui_select'):
        surface_tension = default_surface_tension
    var color = Color(.25,0.75,0)
    color.s = abs(lv.normalized().x - lv.normalized().y)
#    modulate = color
        
    lv += move
    move_and_slide(lv, Vector2(0, -1), 0, 5, deg2rad(50))
    lv *= 0.985
    if not is_on_floor():
        lv += Vector2(0,1) * gravity
        
    droplets = get_droplets()
    if droplets.size() < droplet_count:
        spawn_droplet()
    
func get_droplets():
    var droplets = []
    for child in get_children():
        if child.is_in_group('Droplets'):
            droplets.append(child)
    return droplets    
    
#func _draw():
#    draw_circle(Vector2(0,0), 64, Color(.1,1,1))