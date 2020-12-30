#extends Object
#class_name ChartObject
#
#"""
#[ChartObject] :: Class
#
#this class is used to store all the functions that Chart, Chart2D and Chart3D custom instances
#will share in-between.
#Chart classes will extend this class.
#"""
#
#enum PointShapes { Dot, Triangle, Square, Cross }
#enum TemplatesNames { Default, Clean, Gradient, Minimal, Invert }
#
#class Chart extends Control:
#	var CHART_TYPE : String = "Chart"
#	enum PointShapes { Dot, Triangle, Square, Cross }
#	enum TemplatesNames { Default, Clean, Gradient, Minimal, Invert }
#
#	export (PoolColorArray) var function_colors = [Color("#1e1e1e")]
#	export (Array, PointShapes) var points_shape : Array = [PointShapes.Dot]
#
#	var functions : int = 0
#
#	func calculate_colors():
#		if function_colors.empty() or function_colors.size() < functions:
#			for function in functions:
#				function_colors.append(Color("#1e1e1e"))
#
#	func set_shapes():
#		if points_shape.empty() or points_shape.size() < functions:
#			for function in functions:
#				points_shape.append(PointShapes.Dot)
#
#
#class Chart2D extends Node2D:
#	var CHART_TYPE : String = "Chart2D"
#	enum PointShapes { Dot, Triangle, Square, Cross }
#	enum TemplatesNames { Default, Clean, Gradient, Minimal, Invert }
