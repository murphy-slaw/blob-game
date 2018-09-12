extends KinematicBody2D

const StateMachine = preload("res://StateMachine/StateMachine.gd")
const State = preload("res://StateMachine/State.gd")
var brain = StateMachine.new()

const Droplet:PackedScene = preload('res://Droplet.tscn')

export var droplet_count:int = 3
export var droplet_radius:float = 12.0
export var default_surface_tension:float = 1.0 setget _set_surface_tension
export var brownian_motion_intensity:float = 1.0

export (bool) var debug_draw = false
export var center_bias:float = 0.25

export var gravity:float = 7.0
export var speed:float = 15.0
export var max_speed:float = 150.0

var lv:Vector2 = Vector2()
var radius:float
var droplets:Array = []
var overlapping_droplets:Dictionary = {}
var surface_tension:float = default_surface_tension
var blob_radius:float = pow(4 * radius, 2)

export (NodePath) var map_path
var map:TileMap
var nav:Navigation2D
var tile_size:Vector2

onready var left_ray:RayCast2D = get_node('LeftRay')
onready var right_ray:RayCast2D = get_node('RightRay')
onready var collider:CollisionShape2D = get_node('CollisionShape2D')

signal new_droplet

func _ready()-> void:
    radius = droplet_radius
    collider.shape.radius = radius
    if map_path:
        map = get_node(map_path)
        tile_size = map.cell_size
    prepare_brain()
    $OozeSprite.update()
    call_deferred('get_helpers')

func get_helpers()->void:
    if map_path:
        map = get_node(map_path)
    nav = get_node("../Navigation2D")
#func _process(_delta)->void:
#    var enclosing_rect:Rect2 = get_enclosing_rect()
#    var poly:PoolVector2Array = PoolVector2Array()
#    var point:Vector2 = Vector2(-enclosing_rect.size.x, -enclosing_rect.size.y) * 0.5
#    poly.append(point)
#    point += Vector2(enclosing_rect.size.x, 0)
#    poly.append(point)
#    point += Vector2(0, enclosing_rect.size.y)
#    poly.append(point)
#    point = Vector2(point.x - enclosing_rect.size.x , point.y)
#    poly.append(point)
#    $Polygon2D.polygon = poly
#    update()

func _physics_process(_delta)-> void:
    
    droplets = get_droplets()
    if droplets.size() < droplet_count:
        spawn_droplet()
    elif droplets.size() > droplet_count:
        droplets[0].queue_free()
   
    brain.check_transitions()
    brain._physics_process(_delta)
    var speed_cap:float = max_speed
    lv = lv.clamped(speed_cap)
	#warning-ignore:return_value_discarded
    move_and_slide(lv, Vector2(0, -1), true, false, 4, deg2rad(45))
    lv *= 0.97
 
func _draw()-> void:
    if not debug_draw:
        return
    draw_circle(Vector2(), radius, Color(1,0,0))
    var inv:Transform2D = get_global_transform().inverse()
    draw_set_transform_matrix(inv)
#    var tile_rect:Rect2 = get_tile_rect(position)
#    var smol_rect:Rect2 = Rect2(tile_rect.position + Vector2(16,16), tile_rect.size - Vector2(32,32))
#    draw_rect(tile_rect, Color(1, 1, 1), false)
#    draw_rect(smol_rect, Color(1,1,1), false)
    draw_rect(get_blob_rect(), Color(1,0,0), false)
    draw_rect(get_enclosing_rect(), Color(0,1,0), false)
    draw_polyline($Polygon2D.polygon, Color(1,1,1))
    
func prepare_brain()-> void:
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

func _set_surface_tension(t)->void:
    surface_tension = t
    default_surface_tension = t

func spawn_droplet()->void:
        yield(get_tree(), 'idle_frame')
        var droplet:RigidBody2D = Droplet.instance()
        droplet.puddle = self
        droplet.nav = nav
        droplet.radius = droplet_radius #+ (4 - randi() % 8)
        droplet.global_position = get_spawn_point()
        droplet.add_to_group('Droplets')
        emit_signal('new_droplet', droplet)
                
    
func get_tile_rect(pos)-> Rect2:
    if map:
        var tile_pos:Vector2 = map.world_to_map(pos)
        var world_pos:Vector2 = map.map_to_world(tile_pos)
        return Rect2(world_pos, tile_size)
    else:
        return Rect2(position, Vector2(32,32))
        
func get_tile_center_point(pos:Vector2) -> Vector2:
    var tile_rect:Rect2 = get_tile_rect(pos)
    return tile_rect.position + (tile_rect.size * 0.5)
    
func get_spawn_point()-> Vector2:
    return get_tile_center_point(position)
    
func get_blob_vector()-> Vector2:
    var blob_vec:Vector2 = Vector2()
    for droplet in get_droplets():
        blob_vec += droplet.linear_velocity.normalized()
    return blob_vec
    
func get_blob_rect()-> Rect2:
    var blob_rect:Rect2 = Rect2(position, Vector2(2,2))
    for droplet in get_droplets():
        if (position - droplet.position).length_squared() < blob_radius:
            blob_rect = blob_rect.expand(droplet.position)
    return blob_rect
    
func get_enclosing_rect()-> Rect2:
    var blob_rect:Rect2 = get_blob_rect()
    var blob_size:Vector2 = Vector2(2.0 * radius, 2.0 * radius)
    blob_rect.size += blob_size * 8.0
    blob_rect.position -= blob_size
    return blob_rect
    
func get_blob_center()-> Vector2:
    var blob_rect:Rect2 = get_blob_rect()
    return blob_rect.position + blob_rect.size * 0.5
    
func get_droplets()-> Array:
    var droplets:Array = []
    for child in get_parent().get_children():
        if child.is_in_group('Droplets'):
                droplets.append(child)
    return droplets  
    
func can_move()-> bool:
    return overlapping_droplets.size() > 2
	
func get_center_bias_vec()->Vector2:
	return (position - get_blob_center()) * center_bias

func _on_Area2D_body_entered(body)-> void:
    if body.is_in_group('Droplets'):
        overlapping_droplets[body] = 1


func _on_Area2D_body_exited(body)-> void:
    if overlapping_droplets.has(body):
		#warning-ignore:return_value_discarded
        overlapping_droplets.erase(body)

#
# StateMachine States
#

class Idle extends State:
    
    func _init(_object).(_object)->void:
        name = 'idle'
        
    func _physics_process(_delta):
        if target.is_on_floor():
            target.lv -= target.get_center_bias_vec()
        target.lv += Vector2(0,1) * target.gravity
        
    func on_move()-> bool:
        return (
                Input.is_action_pressed('ui_left') or 
                Input.is_action_pressed('ui_right')
                ) and target.can_move()
                
                
class MoveState extends State:
    
    func _init(_object).(_object):
        pass
    
    func on_no_input()-> bool:
        return not (
                Input.is_action_pressed('ui_left') or 
                Input.is_action_pressed('ui_right')
                )
                
    func on_frozen():
        return not target.can_move()
    
    
class Moving extends MoveState:
    
    func _init(_object).(_object):
        name = 'moving'
        
    func _physics_process(_delta) -> void:
        var move:Vector2 = Vector2()
        var blob_pos:Vector2 = target.get_blob_center()
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
    
    func _init(_object).(_object):
        name = 'climbing'
        
    func _physics_process(_delta):
        var move:Vector2 = Vector2()
        
        if ((Input.is_action_pressed('ui_left') and target.left_ray.is_colliding())
             or (Input.is_action_pressed('ui_right') and target.right_ray.is_colliding())):
                move += Vector2(0, -1) * target.speed
        target.lv += move
                
    func on_left_wall():
        return not target.is_on_wall()