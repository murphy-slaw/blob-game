extends RigidBody2D

func _ready():
    $CollisionPolygon2D.polygon = $Gear2D.get_collision_poly()
    
func _physics_process(_delta):
    $Label.text = str(angular_velocity)
    $Gear2D.texture_rotation = - fmod(rotation, (2*PI))
