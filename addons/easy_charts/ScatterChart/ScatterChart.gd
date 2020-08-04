tool
extends Chart

"""
[ScatterChart] - General purpose node for Scatter Charts

A scatter plot (also called a scatterplot, scatter graph, scatter chart, scattergram, or scatter diagram)
 is a type of plot or mathematical diagram using Cartesian coordinates to display values for typically two variables 
for a set of data. If the points are coded (color/shape/size), one additional variable can be displayed. 
The data are displayed as a collection of points, each having the value of one variable determining the position on 
the horizontal axis and the value of the other variable determining the position on the vertical axis.

/ source : Wikipedia /
"""

# ---------------------

func _get_property_list():
    return [
        # Chart Properties
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Properties/are_values_columns",
            "type": TYPE_BOOL
        },
        {
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "-1,100,1",
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Properties/labels_index",
            "type": TYPE_INT
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Properties/show_x_values_as_labels",
            "type": TYPE_BOOL
        },
        
        # Chart Display
        {
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "0.1,10",
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Display/x_decim",
            "type": TYPE_REAL
        },
        {
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": "0.1,10",
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Display/y_decim",
            "type": TYPE_REAL
        },
        
        # Chart Style
        { 
            "hint": 24, 
            "hint_string": "%d/%d:%s"%[TYPE_INT, PROPERTY_HINT_ENUM,
            PoolStringArray(PointShapes.keys()).join(",")],
            "name": "Chart_Style/points_shape", 
            "type": TYPE_ARRAY, 
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/function_colors",
            "type": TYPE_COLOR_ARRAY
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/box_color",
            "type": TYPE_COLOR
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/v_lines_color",
            "type": TYPE_COLOR
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/h_lines_color",
            "type": TYPE_COLOR
        },
        {
            "class_name": "Font",
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "Font",
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/font",
            "type": TYPE_OBJECT
        },
        {
            "class_name": "Font",
            "hint": PROPERTY_HINT_RESOURCE_TYPE,
            "hint_string": "Font",
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/bold_font",
            "type": TYPE_OBJECT
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/font_color",
            "type": TYPE_COLOR
        },
        {
            "hint": PROPERTY_HINT_ENUM,
            "hint_string": PoolStringArray(TemplatesNames.keys()).join(","),
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Style/template",
            "type": TYPE_INT
        },
        
        # Chart Modifiers
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Chart_Modifiers/invert_chart",
            "type": TYPE_BOOL
        },
    ]

func structure_datas(database : Array, are_values_columns : bool, x_values_index : int):
    # @x_values_index can be either a column or a row relative to x values
    # @y_values can be either a column or a row relative to y values
    self.are_values_columns = are_values_columns
    match are_values_columns:
        true:
            for row in database.size():
                var t_vals : Array
                for column in database[row].size():
                    if column == x_values_index:
                        var x_data = database[row][column]
                        if x_data.is_valid_float() or x_data.is_valid_integer():
                            x_datas.append(x_data as float)
                        else:
                            x_datas.append(x_data.replace(",",".") as float)
                    else:
                        if row != 0:
                            var y_data = database[row][column]
                            if y_data.is_valid_float() or y_data.is_valid_integer():
                                t_vals.append(y_data as float)
                            else:
                                t_vals.append(y_data.replace(",",".") as float)
                        else:
                            y_labels.append(str(database[row][column]))
                if not t_vals.empty():
                    y_datas.append(t_vals)
            x_label = str(x_datas.pop_front())
        false:
            for row in database.size():
                if row == x_values_index:
                    x_datas = (database[row])
                    x_label = x_datas.pop_front() as String
                else:
                    var values = database[row] as Array
                    y_labels.append(values.pop_front() as String)
                    y_datas.append(values)
            for data in y_datas:
                for value in data.size():
                    data[value] = data[value] as float
    
    # draw y labels
    var to_order : Array
    var to_order_min : Array
    for cluster in y_datas.size():
        # define x_chors and y_chors
        var ordered_cluster = y_datas[cluster] as Array
        ordered_cluster.sort()
        ordered_cluster = PoolIntArray(ordered_cluster)
        var margin_max = ordered_cluster[ordered_cluster.size()-1]
        var margin_min = ordered_cluster[0]
        to_order.append(margin_max)
        to_order_min.append(margin_min)
    
    to_order.sort()
    to_order_min.sort()
    var margin = to_order.pop_back()
    if not origin_at_zero:
        y_margin_min = to_order_min.pop_front()
    v_dist = y_decim * pow(10.0,str(margin).length()-2)
    var multi = 0
    var p = (v_dist*multi) + ((y_margin_min) if not origin_at_zero else 0)
    y_chors.append(p as String)
    while p < margin:
        multi+=1
        p = (v_dist*multi) + ((y_margin_min) if not origin_at_zero else 0)
        y_chors.append(p as String)
    
    # draw x_labels
    if not show_x_values_as_labels:
        to_order.clear()
        to_order = x_datas as PoolIntArray
        
        to_order.sort()
        margin = to_order.pop_back()
        if not origin_at_zero:
            x_margin_min = to_order.pop_front()
        h_dist = x_decim * pow(10.0,str(margin).length()-2)
        multi = 0
        p = (h_dist*multi) + ((x_margin_min) if not origin_at_zero else 0)
        x_labels.append(p as String)
        while p < margin:
            multi+=1
            p = (h_dist*multi) + ((x_margin_min) if not origin_at_zero else 0)
            x_labels.append(p as String)

func build_chart():
    SIZE = get_size()
    origin = Vector2(OFFSET.x,SIZE.y-OFFSET.y)

func calculate_pass():
    if invert_chart:
        x_chors = y_labels as PoolStringArray
    else:
        if show_x_values_as_labels:
            x_chors = x_datas as PoolStringArray
        else:
            x_chors = x_labels
    
    # calculate distance in pixel between 2 consecutive values/datas
    x_pass = (SIZE.x - OFFSET.x) / (x_chors.size()-1)
    y_pass = origin.y / (y_chors.size()-1)

func calculate_coordinates():
    x_coordinates.clear()
    y_coordinates.clear()
    point_values.clear()
    point_positions.clear()
    
    if invert_chart:
        for column in y_datas[0].size():
            var single_coordinates : Array
            for row in y_datas:
                if origin_at_zero:
                    single_coordinates.append((row[column]*y_pass)/v_dist)
                else:
                    single_coordinates.append((row[column] - y_margin_min)*y_pass/v_dist)
            y_coordinates.append(single_coordinates)
    else:
        for cluster in y_datas:
            var single_coordinates : Array
            for value in cluster.size():
                if origin_at_zero:
                    single_coordinates.append((cluster[value]*y_pass)/v_dist)
                else:
                    single_coordinates.append((cluster[value] - y_margin_min)*y_pass/v_dist)
            y_coordinates.append(single_coordinates)
    
    if show_x_values_as_labels:
        for x in x_datas.size():
            x_coordinates.append(x_pass*x)
    else:
        for x in x_datas.size():
            if origin_at_zero:
                if invert_chart:
                    x_coordinates.append(x_pass*x)
                else:
                    x_coordinates.append(x_datas[x]*x_pass/h_dist)
            else:
                x_coordinates.append((x_datas[x] - x_margin_min)*x_pass/h_dist)
    
    for f in functions:
        point_values.append([])
        point_positions.append([])
    
    if invert_chart:
        for function in y_coordinates.size():
            for function_value in y_coordinates[function].size():
                if are_values_columns:
                    point_positions[function_value].append(Vector2(x_coordinates[function]+origin.x, origin.y-y_coordinates[function][function_value]))
                    point_values[function_value].append([x_datas[function_value],y_datas[function_value][function]])
                else:
                    point_positions[function].append(Vector2(x_coordinates[function_value]+origin.x,origin.y-y_coordinates[function][function_value]))
                    point_values[function].append([x_datas[function_value],y_datas[function_value][function]])
    else:
        for cluster in y_coordinates.size():
            for y in y_coordinates[cluster].size():
                if are_values_columns:
                    point_values[y].append([x_datas[cluster],y_datas[cluster][y]])
                    point_positions[y].append(Vector2(x_coordinates[cluster]+origin.x,origin.y-y_coordinates[cluster][y]))
                else:
                    point_values[cluster].append([x_datas[y],y_datas[cluster][y]])
                    point_positions[cluster].append(Vector2(x_coordinates[y]+origin.x,origin.y-y_coordinates[cluster][y]))

func _draw():
    clear_points()
    
    draw_grid()
    draw_chart_outlines()
    
    var defined_colors : bool = false
    if function_colors.size():
        defined_colors = true
    
    for _function in point_values.size():
        var PointContainer : Control = Control.new()
        Points.add_child(PointContainer)
        
        for function_point in point_values[_function].size():
            var point : Point = point_node.instance()
            point.connect("_point_pressed",self,"point_pressed")
            point.connect("_mouse_entered",self,"show_data")
            point.connect("_mouse_exited",self,"hide_data")
            
            point.create_point(points_shape[_function], function_colors[function_point if invert_chart else _function], 
            Color.white, point_positions[_function][function_point], 
            point.format_value(point_values[_function][function_point], false, false), 
            y_labels[function_point if invert_chart else _function] as String)
            
            PointContainer.add_child(point)

func draw_grid():
    # ascisse
    for p in x_chors.size():
        var point : Vector2 = origin+Vector2((p)*x_pass,0)
        # v grid
        draw_line(point,point-Vector2(0,SIZE.y-OFFSET.y),v_lines_color,0.2,true)
        # ascisse
        draw_line(point-Vector2(0,5),point,v_lines_color,1,true)
        draw_string(font,point+Vector2(-const_width/2*x_chors[p].length(),font_size+const_height),x_chors[p],font_color)
    
    # ordinate
    for p in y_chors.size():
        var point : Vector2 = origin-Vector2(0,(p)*y_pass)
        # h grid
        draw_line(point,point+Vector2(SIZE.x-OFFSET.x,0),h_lines_color,0.2,true)
        # ordinate
        draw_line(point,point+Vector2(5,0),h_lines_color,1,true)
        draw_string(font,point-Vector2(y_chors[p].length()*const_width+font_size,-const_height),y_chors[p],font_color)

func draw_chart_outlines():
    draw_line(origin,SIZE-Vector2(0,OFFSET.y),box_color,1,true)
    draw_line(origin,Vector2(OFFSET.x,0),box_color,1,true)
    draw_line(Vector2(OFFSET.x,0),Vector2(SIZE.x,0),box_color,1,true)
    draw_line(Vector2(SIZE.x,0),SIZE-Vector2(0,OFFSET.y),box_color,1,true)
