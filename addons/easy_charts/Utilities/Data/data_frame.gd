tool
extends Reference
class_name DataFrame

var _data_matrix : Matrix
var _index : PoolStringArray = []
var _header : PoolStringArray = []
var _dataframe : Array = []
var _dataset : Array = []

func _init(data_matrix : Matrix, index : PoolStringArray, header : PoolStringArray) -> void:
	if data_matrix.get_size()[1] == header.size(): header.insert(0,"")
	if index.empty() : for value in range(data_matrix.get_size().x) : index.append("f%s"%value)
	self._data_matrix = data_matrix
	self._index = index
	self._header = header
	self._dataset = build_dataset(data_matrix.to_array(), index, header)
	self._dataframe = build_dataframe_from_matrix(data_matrix, index, header)

func build_dataset(data : Array, index : PoolStringArray, header : PoolStringArray) -> Array:
	var dataset : Array = [Array(header)]
	for i in range(index.size()):
		var set : Array = data[i].duplicate()
		set.insert(0, index[i])
		dataset.append(set)
	return dataset

func build_dataframe(data : Array, index : PoolStringArray, header : PoolStringArray) -> Array:
	var dataframe : Array = [Array(header)]
	for row_i in range(data.size()): dataframe.append([index[row_i]]+data[row_i])
	return dataframe

func build_dataframe_from_matrix(data_matrix : Matrix, index : PoolStringArray, header : PoolStringArray) -> Array:
	var data : Array = data_matrix.to_array()
	return build_dataframe(data, index, header)

func insert_column(header_n : String, column : Array, index : int = _dataframe[0].size()) -> void:
	assert(column.size()+1 == _dataframe.size(), "error: the column size must match the dataframe column size")
	_header.insert(index, header_n)
	_data_matrix.insert_column(column, index-1)
	self._dataframe = build_dataframe_from_matrix(_data_matrix, _index, _header)

func insert_row(index_n : String, row : Array, index : int = _dataframe.size()) -> void:
	assert(row.size()+1 == _dataframe[0].size(), "error: the row size must match the dataframe row size")
	_index.insert(index-1, index_n)
	_data_matrix.insert_row(row, index-1)
	self._dataframe = build_dataframe_from_matrix(_data_matrix, _index, _header)

func get_matrix() -> Matrix:
	return _data_matrix

func get_dataframe() -> Array:
	return _dataframe

func get_dataset() -> Array:
	return _dataset

func get_index() -> PoolStringArray:
	return _index


func _to_string() -> String:
	var last_string_len : int
	for row in _dataframe:
		for column in row:
			var string_len : int = str(column).length()
			last_string_len = string_len if string_len > last_string_len else last_string_len
	var string : String = ""
	for row_i in _dataframe.size():
		for column_i in _dataframe[row_i].size():
			string+="%*s" % [last_string_len+1, _dataframe[row_i][column_i]]
		string+="\n"
	return string

# ...............................................................................
func get_column_h(header : String) -> Array:
	var header_i : int = -1
	var array : Array = []
	for header_ix in range(_dataframe[0].size()):
		if _dataframe[0][header_ix] == header: header_i = header_ix; continue
	if header_i!=-1: for row in _dataframe: array.append(row[header_i])
	return array

func get_row_i(index : String) -> Array:
	var index_i : int
	for row in _dataframe: if row[0] == index: return row
	return []

func _get(_property : String):
	if _property.split(";").size() == 2:
		var property : PoolStringArray = _property.split(";")
		pass
	elif _property.split(":").size() == 2:
		var property : PoolStringArray = _property.split(":")
		if int(property[0]) == 0: return get_row_i(property[1])
		else: return get_column_h(property[1])





