extends KinematicBody2D
const Droplet = preload('res://Droplet.tscn')
export var droplet_count = 3
export var droplet_radius = 12
var droplets = []
var gravity = 7
var speed = 10
var max_speed = 350
var lv = Vector2()
export var default_surface_tension = 1.0 setget _set_surface_tension
var surface_tension = default_surface_tension

func _set_surface_tension(t):
    surface_tension = t
    default_surface_tension = t

func spawn_droplet():
        var droplet = Droplet.instance()
        droplet.radius = droplet_radius #+ (4 - randi() % 8)
        add_child(droplet)
        var spawn_vec = Vector2()
        if is_on_floor():
            spawn_vec.y -= 1
        if is_on_wall():
            if $RightRay.is_colliding():
                spawn_vec.x -= 1
            elif $LeftRay.is_colliding():
                spawn_vec.x += 1
        droplet.global_position = global_position
        droplet.global_position += spawn_vec * droplet_radius
    
func _physics_process(delta):
    var move = Vector2()
    if Input.is_action_pressed('ui_left'):
        if is_on_wall() and $LeftRay.is_colliding():
            move += Vector2(0, -1) * speed
        else:
            move -= Vector2(1, 0) * speed * 2
    elif Input.is_action_pressed('ui_right'):
        if is_on_wall() and $RightRay.is_colliding():
            move += Vector2(0, -1) * speed * 2
        else:
            move += Vector2(1, 0) * speed
    if Input.is_action_pressed('ui_select'):
        for droplet in get_droplets():
                droplet.radius = lerp(droplet.radius, droplet_radius * 4, 0.1) 
    elif Input.is_action_just_released('ui_select'):
        for droplet in get_droplets():
                droplet.radius = droplet_radius
    var color = Color(.25,0.75,0)
    color.s = abs(lv.normalized().x - lv.normalized().y)
        
    lv += move
    lv = lv.clamped(max_speed)
    
    move_and_slide(lv, Vector2(0, -1), 0)
    lv *= 0.99
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