tool
extends Reference
class_name MatrixGenerator

# Generates a Matrix with random values between [from; to] with a given @size (rows, columns)
static func random_float_range(size : Vector2, from : float, to : float, _seed : int = 1234) -> Matrix:
	seed(_seed)
	randomize()
	var array : Array = []
	for row in range(size.x):
		var matrix_row : Array = []
		for column in range(size.y): matrix_row.append(rand_range(from,to))
		array.append(matrix_row)
	return Matrix.new(array)

# Generates a Matrix giving an Array (Array must by Array[Array])
static func from_array(array : Array = []) -> Matrix:
	var matrix : Array = []
	matrix.append(array)
	return Matrix.new(matrix)

# Generates a sub-Matrix giving a Matrix, a @from Array [row_i, column_i] and a @to Array [row_j, column_j]
static func sub_matrix(_matrix : Matrix, from : Array, to : Array) -> Matrix:
	if to[0] > _matrix.get_size().x or to[1] > _matrix.get_size().y: 
		printerr("%s is not an acceptable size for the submatrix, giving a matrix of size %s"%[to, _matrix.get_size()])
		return Matrix.new()
	var array : Array = []
	for rows_i in range(from[0],to[0]): array.append(_matrix.to_array()[rows_i].slice(from[1], to[1]))
	return Matrix.new(array)

# Duplicates a given Matrix
static func duplicate(_matrix : Matrix) -> Matrix:
	return Matrix.new(_matrix.to_array().duplicate())

# Transpose a given Matrix
static func transpose(_matrix : Matrix) -> Matrix:
	var array : Array = []
	array.resize(_matrix.get_size().y)
	var row : Array = []
	row.resize(_matrix.get_size().x)
	for x in array.size():
		array[x] = row.duplicate()
	for i in range(_matrix.get_size().x):
		for j in range(_matrix.get_size().y):
			array[j][i] = (_matrix.to_array()[i][j])
	return Matrix.new(array)

# Calculates the dot product (A*B) matrix between two Matrixes
static func dot(_matrix1 : Matrix, _matrix2 : Matrix) -> Matrix:
	if _matrix1.get_size().y != _matrix2.get_size().x: 
		printerr("matrix1 number of columns: %s must be the same as matrix2 number of rows: %s"%[_matrix1.get_size().y, _matrix2.get_size().x])
		return Matrix.new()
	var array : Array = []
	for x in range(_matrix1.get_size().x):
		var row : Array = []
		for y in range(_matrix2.get_size().y):
			var sum : float
			for k in range(_matrix1.get_size().y):
				sum += (_matrix1.to_array()[x][k]*_matrix2.to_array()[k][y])
			row.append(sum)
		array.append(row)
	return Matrix.new(array)

# Calculates the hadamard (element-wise product) between two Matrixes
static func hadamard(_matrix1 : Matrix, _matrix2 : Matrix) -> Matrix:
	if _matrix1.get_size() != _matrix2.get_size(): 
		printerr("matrix1 size: %s must be the same as matrix2 size: %s"%[_matrix1.get_size(), _matrix2.get_size()])
		return Matrix.new()
	var array : Array = []
	for x in range(_matrix1.to_array().size()):
		var row : Array = []
		for y in range(_matrix1.to_array()[x].size()):
			row.append(_matrix1.to_array()[x][y] * _matrix2.to_array()[x][y])
		array.append(row)
	return Matrix.new(array)

# Multiply a given Matrix for an int value
static func multiply_int(_matrix1 : Matrix, _int : int) -> Matrix:
	var array : Array = _matrix1.to_array().duplicate()
	for x in range(_matrix1.to_array().size()):
		for y in range(_matrix1.to_array()[x].size()):
			array[x][y]*=_int
			array[x][y] = int(array[x][y])
	return Matrix.new(array)

# Multiply a given Matrix for a float value
static func multiply_float(_matrix1 : Matrix, _float : float) -> Matrix:
	var array : Array = _matrix1.to_array().duplicate()
	for x in range(_matrix1.to_array().size()):
		for y in range(_matrix1.to_array()[x].size()):
			array[x][y]*=_float
	return Matrix.new(array)



