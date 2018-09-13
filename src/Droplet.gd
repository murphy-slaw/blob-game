extends RigidBody2D

onready var collider:CollisionShape2D = get_node("CollisionShape2D")
onready var sprite:Sprite = get_node("Sprite");
export var radius:float = 16 setget set_radius
export (float, 1, 100, 1) var max_impulse:float = 15
export var debug_draw:bool = false

var default_radius:float = radius
var puddle:Node2D = Node2D.new()
var nav:Navigation2D
var map:TileMap
var goal:Vector2
var goal_path:PoolVector2Array

func _ready():
    collider.shape.radius = radius * 0.4
    linear_velocity= polar2cartesian(0.1, randi() * 4 * PI)
    call_deferred('get_nav')
    call_deferred('get_goal')
    
func get_nav():
    nav = get_node("../Navigation2D")

func _physics_process(_delta):
    
#    update()
    goal = get_goal()
    var goal_vec:Vector2 =  (goal - position)
    var puddle_distance = (position - puddle.position).length_squared()
    var force = max(goal_vec.length_squared(), puddle_distance - pow(radius, 2))
    goal_vec = goal_vec.normalized() 
    goal_vec *= force
    var move:Vector2 = goal_vec * puddle.surface_tension
#    move = move.clamped(40)
    apply_central_impulse(move)
    
func _draw():
    if not debug_draw:
        return
    draw_set_transform_matrix(transform.inverse())
    if goal and goal != puddle.position:
        draw_line(position, goal, Color(1, 0, 0))
    if goal_path:
        draw_polyline(goal_path, Color(1, 0, 0))
    
func get_goal() -> Vector2:
    if not puddle:
        goal =  Vector2()
    var goal:Vector2 = puddle.position
    if nav and nav.has_method('get_simple_path'):
        var closest:Vector2 = nav.get_closest_point(position)
        var path:PoolVector2Array = nav.get_simple_path(closest, goal)
        if path:
            goal_path = path
            goal = path[1] # puddle.get_tile_center_point(path[1])
    return goal

func set_radius(r):
    default_radius = r
    _set_radius(r)
    
func _set_radius(r):
    radius = r
    if collider and collider.shape:
        collider.shape.radius = radius * 0.3
        sprite.update();
    update()
    

func get_random_normal()->Vector2:
    var vector = Vector2()
    vector.x += (randi() % 3) - 1
    vector.y += (randi() % 3) - 1
    return vector.normalized()

func _on_VisibilityNotifier2D_screen_exited():
    queue_free()