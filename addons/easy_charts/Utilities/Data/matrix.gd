tool
extends Reference
class_name Matrix

var _matrix : Array = []

func _init(matrix : Array = []) -> void:
	_matrix = matrix

func _to_string() -> String:
	var last_string_len : int
	for row in _matrix:
		for column in row:
			var string_len : int = str(column).length()
			last_string_len = string_len if string_len > last_string_len else last_string_len
	var string : String = "\n"
	for row_i in _matrix.size():
		for column_i in _matrix[row_i].size():
			string+="%*s" % [last_string_len+1 if column_i!=0 else last_string_len, _matrix[row_i][column_i]]
		string+="\n"
	return string

func insert_row(row : Array, index : int = _matrix.size()) -> void:
	assert(row.size() == _matrix[0].size(), "error: the row size must match matrix row size")
	_matrix.insert(index, row)

func insert_column(column : Array, index : int = _matrix[0].size()) -> void:
	assert(column.size() == _matrix.size(), "error: the column size must match matrix column size")
	for row_idx in column.size():
		_matrix[row_idx].insert(index, column[row_idx])

func to_array() -> Array:
	return _matrix.duplicate()

func get_size() -> Vector2:
	return Vector2(_matrix.size(), _matrix[0].size())

func get_column(column : int) -> Array:
	if column >= get_size()[1]: printerr("error")
	var column_array : Array = []
	for row in _matrix: column_array.append(row[column])
	return column_array

func get_row(row : int) -> Array:
	if row >= get_size()[0]: printerr("error")
	return _matrix[row]
#
#func multiply_int(_int : int) -> void:
#	_matrix = MatrixGenerator.multiply_int(self, _int).to_array()
#
#func multiply_float(_float : int) -> void:
#	_matrix = MatrixGenerator.multiply_float(self, _float).to_array()









