extends Control

@onready var chart: Chart = $Chart

# Called when the node enters the scene tree for the first time.
func _ready():
	var x: PackedFloat32Array = [0.0, 10.0, 20.0]
	var y: PackedFloat32Array = [0.0, 10.0, 20.0]
	
	var chart_properties: ChartProperties = ChartProperties.new()
	chart_properties.show_tick_labels = false
	chart_properties.draw_ticks = false
	
	var f: Function = Function.new(x, y, "", 
	{ 
		marker = Function.Marker.CROSS,
		type = Function.Type.SCATTER,
#		interpolation = Function.Interpolation.STAIR
		
	})
	chart.plot([f], chart_properties)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
