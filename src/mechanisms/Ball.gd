tool
extends RigidBody2D

export var radius = 16

func _ready():
    $CollisionShape2D.shape.radius = radius
    update()

func _draw():
    draw_circle(Vector2(), radius, Color8(3,6,51))