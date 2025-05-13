extends RefCounted
class_name ChartAxisDomain
## Represents the domain for an axis of a chart.

## The lower bound value
var lb: Variant

## The upper bound value
var ub: Variant

## True if any value on the axis has decimal places
var has_decimals: bool

## True if the domain has only discrete values. For now, this is only
## set to true in case the domain contains string values.
var is_discrete: bool

## True if the domain was specified via from_bounds().
var fixed: bool

## Callable to overwrite the label generation.
var labels_function: Callable

var _tick_count: int = -1

var _string_values: Array

static func from_bounds(lb: Variant, ub: Variant) -> ChartAxisDomain:
	var domain = ChartAxisDomain.new()
	domain.lb = lb
	domain.ub = ub
	domain.has_decimals = ECUtilities._has_decimals([[lb, ub]])
	domain.fixed = true
	domain.is_discrete = false
	return domain

static func from_values(value_arrays: Array, smooth_domain: bool) -> ChartAxisDomain:
	var domain = ChartAxisDomain.new()
	for value_array in value_arrays:
		if ECUtilities._contains_string(value_array):
			domain.lb = 0.0
			domain.ub = (value_array.size())
			domain.has_decimals = false
			domain.is_discrete = true
			domain.fixed = false
			domain._string_values = value_array
			domain._tick_count = value_array.size()
			return domain

	var min_max: Dictionary = ECUtilities._find_min_max(value_arrays)
	if not smooth_domain:
		domain.lb = min_max.min
		domain.ub = min_max.max
		domain.has_decimals = ECUtilities._has_decimals(value_arrays)
		domain.is_discrete = false
		domain.fixed = false
	else:
		domain.lb = ECUtilities._round_min(min_max.min)
		domain.ub = ECUtilities._round_max(min_max.max)
		domain.has_decimals = ECUtilities._has_decimals(value_arrays)
		domain.is_discrete = false
		domain.fixed = false

	return domain

func set_tick_count(tick_count: int) -> void:
	if is_discrete:
		printerr("You cannot set tick count for a discrete chart axis domain")

	_tick_count = tick_count

func get_tick_labels() -> PackedStringArray:
	if !labels_function.is_null():
		return range(_tick_count).map(func(i) -> String:
			var value = lerp(lb, ub, float(i) / float(_tick_count))
			return labels_function.call(value)
		)

	if is_discrete:
		return _string_values

	return range(_tick_count).map(func(i) -> String:
		var value = lerp(lb, ub, float(i) / float(_tick_count))
		return ECUtilities._format_value(value, false)
	)

func get_tick_label(value: Variant, labels_function: Callable) -> String:
	if !labels_function.is_null():
		return labels_function.call(value)

	if is_discrete:
		return value

	return ECUtilities._format_value(value, is_discrete)

func map_to(value_index: int, function_values: Array, to_domain: ChartAxisDomain) -> Variant:
	if is_discrete:
		return ECUtilities._map_domain(value_index, self, to_domain)

	return ECUtilities._map_domain(function_values[value_index], self, to_domain)
