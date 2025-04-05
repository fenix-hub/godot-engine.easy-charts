extends LinePlotter
class_name AreaPlotter

var base_color: Color = Color.WHITE

func _init(function: Function) -> void:
    super(function)
    
    self.base_color = function.get_color()
    pass

func _draw_areas() -> void:
    var box: Rect2 = get_box()
    var fp_augmented: PackedVector2Array = []
    match function.get_interpolation():
        Function.Interpolation.LINEAR:
            fp_augmented = points_positions
        Function.Interpolation.STAIR:
            fp_augmented = _get_stair_points()
        Function.Interpolation.SPLINE:
            fp_augmented = _get_spline_points()
        Function.Interpolation.NONE, _:
            return
    
    fp_augmented.push_back(Vector2(fp_augmented[-1].x, box.end.y + 80))
    fp_augmented.push_back(Vector2(fp_augmented[0].x, box.end.y + 80))
    
    # Precompute the scaling factor for the remap.
    var end_y = box.end.y
    var pos_y = box.position.y
    var scale = 0.5 / (pos_y - end_y)
    
    # Pre-allocate the PackedColorArray based on the number of points.
    var point_count = fp_augmented.size()
    var colors = PackedColorArray()
    colors.resize(point_count)
    
    # Compute alpha for each point and assign the color.
    for i in range(point_count):
        var point: Vector2 = fp_augmented[i]
        var alpha: float = (point.y - end_y) * scale
        colors[i] = Color(base_color, alpha)
    
    # Draw the polygon with the computed colors.
    draw_polygon(fp_augmented, colors)

func _draw() -> void:
    super._draw()
    _draw_areas()
