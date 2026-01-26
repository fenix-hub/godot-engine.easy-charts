extends Control
class_name Canvas

const RotatableLabel := preload("uid://dggg5ild73qdn")

@onready var _title_lbl: Label = $CanvasContainer/Title
@onready var _x_lbl: Label = $CanvasContainer/DataContainer/PlotContainer/XLabel
@onready var _y_lbl: RotatableLabel = $CanvasContainer/DataContainer/YLabel
@onready var _legend: FunctionLegend = $CanvasContainer/DataContainer/FunctionLegend


func prepare_canvas(chart_properties: ChartProperties) -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("chart_area", "Chart"))

	if chart_properties.show_title:
		update_title(chart_properties.title, get_theme_color("text_color", "Chart"))
	else:
		_title_lbl.hide()
	
	if chart_properties.show_x_label:
		update_x_label(chart_properties.x_label, get_theme_color("text_color", "Chart"))
	else:
		_x_lbl.hide()
	
	if chart_properties.show_y_label:
		update_y_label(
			chart_properties.y_label,
			get_theme_color("text_color", "Chart"),
			chart_properties.y_label_orientation
		)
	else:
		_y_lbl.hide()
	
	if chart_properties.show_legend:
		_legend.show()
	else:
		hide_legend()

func update_title(text: String, color: Color) -> void:
	_title_lbl.show()
	_update_canvas_label(_title_lbl, text, color)

func update_y_label(text: String, color: Color, orientation: Orientation) -> void:
	_y_lbl.show()
	_y_lbl.text = text
	_y_lbl.modulate = color
	_y_lbl.orientation = orientation

func update_x_label(text: String, color: Color) -> void:
	_x_lbl.show()
	_update_canvas_label(_x_lbl, text, color)

func _update_canvas_label(canvas_label: Label, text: String, color: Color) -> void:
	canvas_label.set_text(text)
	canvas_label.modulate = color

func hide_legend() -> void:
	_legend.hide()

func set_color(color: Color) -> void:
	get("theme_override_styles/panel").set("bg_color", color)

func set_frame_visible(visible: bool) -> void:
	get("theme_override_styles/panel").set("draw_center", visible)
