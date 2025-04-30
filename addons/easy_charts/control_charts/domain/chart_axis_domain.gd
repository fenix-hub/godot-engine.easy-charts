extends RefCounted
class_name ChartAxisDomain
## Represents the domain for an axis of a chart.

## The lower bound value
var lb: Variant

## The upper bound value
var ub: Variant

## True if any value on the axis has decimal places
var has_decimals: bool

## True f this domain has only discrete values. For now, this is only
## set to true in case the domain contains string values.
var is_discrete: bool

## ???
var fixed: bool

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

func get_tick_label(value: Variant, labels_function: Callable) -> String:
	if labels_function.is_null():
		return ECUtilities._format_value(value, is_discrete)
	elif is_discrete:
		return _string_values[value]
	else:
		return labels_function.call(value)
