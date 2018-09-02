extends Node2D

func _ready():
    var bounds = $TileMap.get_used_rect()
    bounds.position = $TileMap.map_to_world(bounds.position)
    bounds.size = $TileMap.map_to_world(bounds.size)
    print(bounds)
    $Puddle/Camera2D.limit_left = bounds.position.x
    $Puddle/Camera2D.limit_right = bounds.end.x
    $Puddle/Camera2D.limit_top = bounds.position.y
    $Puddle/Camera2D.limit_bottom = bounds.end.y