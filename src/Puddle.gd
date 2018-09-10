extends KinematicBody2D

const StateMachine = preload("res://StateMachine.gd")
const State = preload("res://State.gd")

class Idle extends "res://State.gd":
    
    func _init(object).(object):
        name = 'idle'
        
    func _physics_process(delta):
        target.lv -= target.position - target.get_blob_center()
        target.lv += Vector2(0,1) * target.gravity
        
    func on_move():
        return (
                Input.is_action_pressed('ui_left') or 
                Input.is_action_pressed('ui_right')
                ) and target.can_move()
                
                
class MoveState extends "res://State.gd":
    
    func _init(object).(object):
        pass
    
    func on_no_input():
        return not (
                Input.is_action_pressed('ui_left') or 
                Input.is_action_pressed('ui_right')
                )
                
    func on_frozen():
        return not target.can_move()
    
    
class Moving extends MoveState:
    
    func _init(object).(object):
        name = 'moving'
        
    func _physics_process(delta):
        var move = Vector2()
        var blob_pos = target.get_blob_center()
        if Input.is_action_pressed('ui_left'):
            move -= target.position - blob_pos
            move -= Vector2(1, 0) * target.speed
        elif Input.is_action_pressed('ui_right'):
            move -= target.position - blob_pos
            move += Vector2(1, 0) * target.speed
            
        target.lv += move
            
    func on_start_climb():
        return target.is_on_wall() and (
            target.left_ray.is_colliding() or
            target.right_ray.is_colliding()
            )
            
   
class Climbing extends MoveState:
    
    func _init(object).(object):
        name = 'climbing'
        
    func _physics_process(delta):
        var move = Vector2()
        
        if ((Input.is_action_pressed('ui_left') and target.left_ray.is_colliding())
             or (Input.is_action_pressed('ui_right') and target.right_ray.is_colliding())):
                move += Vector2(0, -1) * target.speed
        target.lv += move
                
    func on_left_wall():
        return not target.is_on_wall()

var brain = StateMachine.new()

const Droplet = preload('res://Droplet.tscn')
export var droplet_count = 3
export var droplet_radius = 12
var radius = droplet_radius
export (bool) var debug_draw = false
export var droplet_inertia = 0.1
var default_droplet_inertia = droplet_inertia
var droplets = []
var overlapping_droplets = {}

export var gravity = 7
export var speed = 15
export var max_speed = 150
var lv = Vector2()

export var default_surface_tension = 1.0 setget _set_surface_tension
var surface_tension = default_surface_tension

export (NodePath) var map_path
var map
var tile_size

onready var left_ray = get_node('LeftRay')
onready var right_ray = get_node('RightRay')

func _ready():
    radius = droplet_radius
    if map_path:
        map = get_node(map_path)
        tile_size = map.cell_size
    var viewport_size = get_viewport_rect().size * 0.5
    $Polygon2D.polygon = PoolVector2Array([
        Vector2(-viewport_size.x, -viewport_size.y),
        Vector2(viewport_size.x, -viewport_size.y),
        Vector2(viewport_size.x, viewport_size.y),
        Vector2(-viewport_size.x, viewport_size.y)
        ])
    prepare_brain()
    $Sprite2.update()
        
func prepare_brain():
    brain.add_state(Idle.new(self))
    brain.add_state(Moving.new(self))
    brain.add_state(Climbing.new(self))
    brain.state = 'idle'
    
    brain.add_transition('idle', 'on_move', 'moving')
    
    brain.add_transition('moving', 'on_no_input', 'idle')
    brain.add_transition('moving', 'on_start_climb', 'climbing')
    brain.add_transition('moving', 'on_frozen', 'idle')
    
    brain.add_transition('climbing', 'on_no_input', 'idle')
    brain.add_transition('climbing', 'on_left_wall', 'moving')
    brain.add_transition('climbing', 'on_frozen', 'idle')

func _set_surface_tension(t):
    surface_tension = t
    default_surface_tension = t

func spawn_droplet():
        var droplet = Droplet.instance()
        droplet.puddle = self
        droplet.nav = get_node("../Navigation2D")
        droplet.radius = droplet_radius #+ (4 - randi() % 8)
        get_parent().add_child(droplet)
        droplet.global_position = get_spawn_point()
                
func get_tile_rect(pos):
    if map:
        var tile_pos = map.world_to_map(pos)
        var world_pos = map.map_to_world(tile_pos)
        return Rect2(world_pos, tile_size)
    else:
        return Rect2(position, Vector2(32,32))
        
func get_spawn_point():
    var tile_rect = get_tile_rect(position)
    return tile_rect.position + (tile_rect.size * 0.5)
    
func _physics_process(delta):
    
    droplets = get_droplets()
    if droplets.size() < droplet_count:
        spawn_droplet()
   
    brain.check_transitions()
    brain._physics_process(delta)
    var speed_cap = max_speed
    lv = lv.clamped(speed_cap)
    move_and_slide(lv, Vector2(0, -1))
    lv *= 0.97
 
    
func get_blob_vector():
    var blob_vec = Vector2()
    for droplet in get_droplets():
        blob_vec += droplet.linear_velocity.normalized()
    return blob_vec
    
func get_blob_center():
    var blob_rect = Rect2(position, Vector2(1,1))
    for droplet in get_droplets():
        blob_rect.expand(droplet.position)
    return blob_rect.position + blob_rect.size * 0.5
    
func get_droplets():
    var droplets = []
    for child in get_parent().get_children():
        if child.is_in_group('Droplets'):
                droplets.append(child)
    return droplets  
    
func can_move():
    return overlapping_droplets.size() > 2  
    
func _draw():
    if not debug_draw:
        return
    draw_circle(Vector2(), 16, Color(1,0,0))
    var inv = get_global_transform().inverse()
    draw_set_transform_matrix(inv)
    var tile_rect = get_tile_rect(position)
    var smol_rect = Rect2(tile_rect.position + Vector2(16,16), tile_rect.size - Vector2(32,32))
    draw_rect(tile_rect, Color(1, 1, 1), false)
    draw_rect(smol_rect, Color(1,1,1), false)


func _on_Area2D_body_entered(body):
    if body.is_in_group('Droplets'):
        overlapping_droplets[body] = 1


func _on_Area2D_body_exited(body):
    if overlapping_droplets.has(body):
        overlapping_droplets.erase(body)
