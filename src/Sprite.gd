extends Sprite

func _ready():
    call_deferred('update')

func update():
    var radius = get_parent().radius * 2
    scale = Vector2(radius, radius)  / texture.get_size()