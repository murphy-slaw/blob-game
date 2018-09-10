extends Sprite

func _ready():
    pass
extends Sprite

func _ready():
    update();

func update():
    var radius = get_parent().radius * 2.5
    scale = Vector2(radius, radius)  / texture.get_size()