extends Control
class_name Canvas

@onready var _title_lbl: HSeparator = $CanvasContainer/Title
@onready var _x_lbl: HSeparator = $CanvasContainer/DataContainer/PlotContainer/XLabel
@onready var _y_lbl: VSeparator = $CanvasContainer/DataContainer/YLabel
@onready var _legend: FunctionLegend = $CanvasContainer/DataContainer/FunctionLegend

func _ready():
	pass

func prepare_canvas() -> void:
	var chart_properties: ChartProperties = get_owner().chart_properties
	set_color(chart_properties.colors.frame)
	set_frame_visible(chart_properties.draw_frame)
	
	_title_lbl.visible = chart_properties.show_title and not chart_properties.title.is_empty()
	_x_lbl.visible = chart_properties.show_x_label and not chart_properties.x_label.is_empty()
	_y_lbl.visible = chart_properties.show_y_label and not chart_properties.y_label.is_empty()
	_legend.visible = chart_properties.show_legend


func set_color(color: Color) -> void:
	get("theme_override_styles/panel").set("bg_color", color)

func set_frame_visible(visible: bool) -> void:
	get("theme_override_styles/panel").set("draw_center", visible)

