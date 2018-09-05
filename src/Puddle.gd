extends KinematicBody2D

const Droplet = preload('res://Droplet.tscn')
export var droplet_count = 3
export var droplet_radius = 12
export (bool) var debug_draw = false
var droplets = []

var gravity = 7
var speed = 15
var max_speed = 350
var lv = Vector2()

export var default_surface_tension = 1.0 setget _set_surface_tension
var surface_tension = default_surface_tension

export (NodePath) var map_path
var map
var tile_size

func _ready():
    map = get_node(map_path)
    tile_size = map.cell_size

func _set_surface_tension(t):
    surface_tension = t
    default_surface_tension = t

func spawn_droplet():
        var droplet = Droplet.instance()
        droplet.puddle = self
        droplet.radius = droplet_radius #+ (4 - randi() % 8)
        get_parent().add_child(droplet)
        droplet.global_position = get_spawn_point()
                
func get_tile_rect():
    if map:
        var tile_pos = map.world_to_map(position)
        var world_pos = map.map_to_world(tile_pos)
        return Rect2(world_pos, tile_size)
        
func get_spawn_point():
    var tile_rect = get_tile_rect()
    return tile_rect.position + (tile_rect.size * 0.5)
    
func _physics_process(delta):
    var move = get_blob_vector().normalized() * 2
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
                droplet.radius = lerp(droplet.radius, droplet_radius * 3, 0.1) 
    elif Input.is_action_just_released('ui_select'):
        for droplet in get_droplets():
                droplet.radius = droplet_radius
    var color = Color(.25,0.75,0)
    color.s = abs(lv.normalized().x - lv.normalized().y)
        
    lv += move
    lv = lv.clamped(max_speed)
    
    move_and_slide(lv, Vector2(0, -1), 0)
    lv *= 0.98
    if not is_on_floor():
        lv += Vector2(0,1) * gravity
        
    droplets = get_droplets()
    if droplets.size() < droplet_count:
        spawn_droplet()
    update()
    
func get_blob_vector():
    var blob_vec = Vector2()
    for droplet in get_droplets():
        blob_vec += droplet.linear_velocity
    return blob_vec
    
func get_droplets():
    var droplets = []
    for child in get_parent().get_children():
        if child.is_in_group('Droplets'):
                droplets.append(child)
    return droplets    
    
func _draw():
    if not debug_draw:
        return
    var inv = get_global_transform().inverse()
    draw_set_transform_matrix(inv)
    var tile_rect = get_tile_rect()
    var smol_rect = Rect2(tile_rect.position + Vector2(16,16), tile_rect.size - Vector2(32,32))
    draw_rect(tile_rect, Color(1, 1, 1), false)
    draw_rect(smol_rect, Color(1,1,1), false)