extends RigidBody2D

func _ready():
    $CollisionPolygon2D.polygon = $Gear2D.get_collision_poly()
    pass
    
func _physics_process(delta):
    $Label.text = str(angular_velocity)
    $Gear2D.texture_rotation = - fmod(rotation, (2*PI))
