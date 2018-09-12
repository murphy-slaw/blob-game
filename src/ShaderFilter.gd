extends Polygon2D

func _process(_delta):
    transform = get_viewport().canvas_transform.inverse()