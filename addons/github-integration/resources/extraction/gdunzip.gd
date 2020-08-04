# MIT License
# 
# Copyright (c) 2018 Jelle Hermsen
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# 

# +-------------------------------------+
# |           _                 _       |
# |  __ _  __| |_   _ _ __  ___(_)_ __  |
# | / _` |/ _` | | | | '_ \|_  / | '_ \ |
# || (_| | (_| | |_| | | | |/ /| | |_) ||
# | \__, |\__,_|\__,_|_| |_/___|_| .__/ |
# | |___/                        |_|    |
# |                                     |
# +-------------------------------------+
# | A small GDScript that allows you to |
# | browse and uncompress zip files.    |
# +-------------------------------------+ 

# Example usage:
#
# - put gdunzip.gd somewhere in your Godot project
# - instance this scrip by using:
#   var gdunzip = load('res://LOCATION_IN_LIBRARY/gdunzip.gd').new()
# - load a zip file:
#   var loaded = gdunzip.load('res://PATH_TO_ZIP/test.zip')
# - if loaded is true you can try to uncompress a file:
#   var uncompressed = gdunzip.uncompress('PATH_TO_FILE_IN_ZIP/test.txt')
# - now you have got a PoolByteArray named "uncompressed" with the
#   uncompressed data for the given file
#
# You can iterate over the "files" variable from the gdunzip instance, to
# see all the available files:
# - for f in gdunzip.files:
#       print(f['file_name'])

# The path of the currently loaded zip file
var path

# A PoolByteArray with the contents of the zip file
var buffer

# The size of the currently loaded buffer
var buffer_size

# A dictionary with the files in the currently loaded zip file.
# It maps full file paths to dictionaries with meta file information:
#
# - compression_method: -1 if uncompressed or File.COMPRESSION_DEFLATE
# - file_name: the full path of the compressed file inside the zip
# - file_header_offset: the exact byte location of this file's compressed data
#                       inside the zip file
# - compressed_size
# - uncompressed_size
var files = {}

# The current position we're at inside the buffer
var pos = 0

# An instance of the inner Tinf class, which is a GDScript port of Jørgen
# Ibsen's excellent "tiny inflate library"
var tinf

# Initialize the gdunzip class
func _init():
	self.tinf = Tinf.new()

# Load a zip file with the given path. Returns a boolean denoting success.
func _load(path):
	if path == null:
		return false

	self.path = path
	self.pos = 0

	var file = File.new()

	if !file.file_exists(path):
		return false

	file.open(path, File.READ)
	var file_length = file.get_len()
	if file.get_32() != 0x04034B50:
		return false

	file.seek(0)
	self.buffer = file.get_buffer(file_length)
	self.buffer_size = self.buffer.size()
	file.close()

	if self.buffer_size < 22:
		# Definitely not a valid zip file
		return false

	# Fill in self.files with all the file data
	return self._get_files()

# Uncompress the given file. Returns false if uncompressing fails, or when the
# file isn't available in the currently loaded zip file.
func uncompress(file_name):
	if !(file_name in self.files):
		return false

	var f = self.files[file_name]
	self.pos = f['file_header_offset']
	self._skip_file_header()
	var uncompressed = self._read(f['compressed_size'])
	if f['compression_method'] == -1:
		return uncompressed
	return tinf.tinf_uncompress(f['uncompressed_size'], uncompressed)

# Returns a PoolByteArray with the compressed data for the given file.
# Returns false if it can't be found.
func get_compressed(file_name):
	if !(file_name in self.files):
		return false

	var f = self.files[file_name]
	self.pos = f['file_header_offset']
	self._skip_file_header()
	return self._read(f['compressed_size'])

# Parse the zip file's central directory and fill self.files with all the
# file info
func _get_files():
	# Locate starting position of central directory
	var eocd_offset = buffer.size() - 22

	while (
		eocd_offset > 0
		&& not (buffer[eocd_offset+3] == 0x06
			&& buffer[eocd_offset+2] == 0x05
			&& buffer[eocd_offset+1] == 0x4B
			&& buffer[eocd_offset] == 0x50
		)
	):
		eocd_offset -= 1

	# Set the central directory start offset
	self.pos = (
		buffer[eocd_offset + 19] << 24
		| buffer[eocd_offset + 18] << 16
		| buffer[eocd_offset + 17] << 8
		| buffer[eocd_offset + 16]
	)

	# Get all central directory records, and fill self.files
	# with all the file information
	while (
		buffer[pos + 3] == 0x02
		&& buffer[pos + 2] == 0x01
		&& buffer[pos + 1] == 0x4B
		&& buffer[pos] == 0x50
	):
		var raw = _read(46)
		var header = {
			'compression_method': '',
			'file_name': '',
			'compressed_size': 0,
			'uncompressed_size': 0,
			'file_header_offset': -1,
		}

		if raw[10] == 0 && raw[11] == 0:
			header['compression_method'] = -1
		else:
			header['compression_method'] = File.COMPRESSION_DEFLATE

		header['compressed_size'] = (
			raw[23] << 24
			| raw[22] << 16
			| raw[21] << 8
			| raw[20]
		)

		header['uncompressed_size'] = (
			raw[27] << 24
			| raw[26] << 16
			| raw[25] << 8
			| raw[24]
		)

		header['file_header_offset'] = (
			 raw[45] << 24
			| raw[44] << 16
			| raw[43] << 8
			| raw[42]
		)

		var file_name_length = raw[29] << 8 | raw[28]
		var extra_field_length = raw[31] << 8 | raw[30]
		var comment_length = raw[33] << 8 | raw[32]

		var raw_end = _read(file_name_length + extra_field_length + comment_length)
		if !raw_end:
			return false

		header['file_name'] = (
			raw_end.subarray(0, file_name_length - 1).get_string_from_utf8()
		)
		self.files[header['file_name']] = header

	return true

# Read a given number of bytes from the buffer, and return it as a
# PoolByteArray
func _read(length):
	var result = buffer.subarray(pos, pos + length - 1)
	if result.size() != length:
		return false
	pos = pos + length
	return result

# Skip the given number of bytes in the buffer. Advancing "pos".
func _skip(length):
	pos += length

# This function skips the file header information, when "pos" points at a file
# header inside the buffer.
func _skip_file_header():
	var raw = _read(30)
	if !raw:
		return false

	var file_name_length = raw[27] << 8 | raw[26]
	var extra_field_length = raw[29] << 8 | raw[28]

	var raw_end = _skip(file_name_length + extra_field_length)


# The inner Tinf class is a pretty straight port from Jørgen Ibsen's excellent
# "tiny inflate library". It's written in an imperative style and I have tried
# to stay close to the original. I added two helper functions, and had to make
# some minor additions to support "faux pointer arithmetic".
#
# I have created a TINF_TREE and TINF_DATA dictionary to serve as structs. I
# use "duplicate" to make an instance from these structs.
class Tinf:
	# ----------------------------------------
	# -- GDscript specific helper functions --
	# ----------------------------------------
	func make_pool_int_array(size):
		var pool_int_array = PoolIntArray()
		pool_int_array.resize(size)
		return pool_int_array

	func make_pool_byte_array(size):
		var pool_byte_array = PoolByteArray()
		pool_byte_array.resize(size)
		return pool_byte_array

	# ------------------------------
	# -- internal data structures --
	# ------------------------------

	var TINF_TREE = {
		'table': make_pool_int_array(16),
		'trans': make_pool_int_array(288),
	}

	var TINF_DATA = {
		'source': PoolByteArray(),
		# sourcePtr is an "int" that's used to point at a location in "source".
		# I added this since we don't have pointer arithmetic in GDScript.
		'sourcePtr': 0,

		'tag': 0,
		'bitcount': 0,

		'dest': PoolByteArray(),
		'destLen': 0,

		# "Faux pointer" to dest.
		'destPtr': 0,

		'ltree': TINF_TREE.duplicate(),
		'dtree': TINF_TREE.duplicate()
	}

	const TINF_OK = 0
	const TINF_DATA_ERROR = -3

	# ---------------------------------------------------
	# -- uninitialized global data (static structures) --
	# ---------------------------------------------------

	var sltree = TINF_TREE.duplicate() # fixed length/symbol tree
	var sdtree = TINF_TREE.duplicate() # fixed distance tree

	var base_tables = {
		# extra bits and base tables for length codes
		'length_bits': make_pool_byte_array(30),
		'length_base': make_pool_int_array(30),

		# extra bits and base tables for distance codes
		'dist_bits': make_pool_byte_array(30),
		'dist_base': make_pool_int_array(30)
	}

	var clcidx = PoolByteArray([
	   16, 17, 18, 0, 8, 7, 9, 6,
	   10, 5, 11, 4, 12, 3, 13, 2,
	   14, 1, 15])

	# -----------------------
	# -- utility functions --
	# -----------------------

	# build extra bits and base tables
	# bits: PoolByteArray
	# base: PoolIntArray
	# delta: int
	# first: int
	func tinf_build_bits_base(target, delta, first):
		var i = 0
		var sum = first

		for i in range(0, delta):
			base_tables[target + '_bits'][i] = 0

		for i in range(0, 30 - delta):
			base_tables[target + '_bits'][i + delta] =  i / delta

		for i in range(0, 30):
			base_tables[target + '_base'][i] = sum
			sum += 1 << base_tables[target + '_bits'][i]

	# build the fixed huffman trees
	# lt: TINF_TREE
	# rt: TINF_TREE
	func tinf_build_fixed_trees(lt, dt):
		var i = 0

		for i in range(0, 7):
			lt['table'][i] = 0

		lt['table'][7] = 24
		lt['table'][8] = 152
		lt['table'][9] = 112

		for i in range(0, 24):
			lt['trans'][i] = 256 + i
		for i in range(0, 144):
			lt['trans'][24 + i] =  i
		for i in range(0, 8):
			lt['trans'][24 + 144 + i] = 280 + i
		for i in range(0, 112):
			lt['trans'][24 + 144 + 8 + i] =  144 + i

		for i in range(0, 5):
			dt['table'][i] = 0

		dt['table'][5] = 32

		for i in range(0, 32):
			dt['trans'][i] = i

	# given an array of code lengths, build a tree
	# t: TINF_TREE
	# lengths: PoolByteArray
	# num: int
	func tinf_build_tree(t, lengths, num):
		var offs = make_pool_int_array(16)
		var i = 0
		var sum = 0

		# clear code length count table
		for i in range(0,16):
			t['table'][i] = 0

		# scan symbol lengths, and sum code length counts
		for i in range(0, num):
			t['table'][lengths[i]] += 1

		t['table'][0] = 0

		for i in range(0,16):
			offs[i] = sum
			sum += t['table'][i]

		for i in range(0, num):
			if lengths[i]:
				t['trans'][offs[lengths[i]]] = i
				offs[lengths[i]] += 1

	# ----------------------
	# -- decode functions --
	# ----------------------

	# get one bit from source stream
	# d: TINF_DATA
	# returns: int
	func tinf_getbit(d):
		var bit = 0

		d['bitcount'] -= 1
		if !(d['bitcount'] + 1) :
			d['tag'] = d['source'][d['sourcePtr']]
			d['sourcePtr'] += 1
			d['bitcount'] = 7

		bit = d['tag'] & 0x01
		d['tag'] >>= 1
		return bit


	# read a num bit value from a stream and add base
	# d: TINF_DATA
	# num: int
	# base: int
	func tinf_read_bits(d, num, base):
		var val = 0

		if num:
			var limit = 1 << num
			var mask = 1

			while mask < limit:
				if tinf_getbit(d):
					val += mask
				mask *= 2

		return val + base

	# given a data stream and a tree, decode a symbol
	# d: TINF_DATA
	# t: TINF_TREE
	func tinf_decode_symbol(d, t):
		var sum = 0
		var cur = 0
		var length = 0

		while true:
			cur = 2 * cur + tinf_getbit(d)
			length += 1
			sum += t['table'][length]
			cur -= t['table'][length]
			if cur < 0:
				break
		return t['trans'][sum + cur]

	# given a data stream, decode dynamic trees from it
	# d: TINF_DATA
	# lt: TINF_TREE
	# dt: TINF_TREE
	func tinf_decode_trees(d, lt, dt):
		var code_tree = TINF_TREE.duplicate()
		var lengths = make_pool_byte_array(288 + 32)
		var hlit = 0
		var hdist = 0
		var hclen = 0
		var i = 0
		var num = 0
		var length = 0

		# get 5 bits HLIT (257-286)
		hlit = tinf_read_bits(d, 5, 257)

		# get 5 bits HDIST (1-32)
		hdist = tinf_read_bits(d, 5, 1)

		# get 4 bits HCLEN (4-19)
		hclen = tinf_read_bits(d, 4, 4)

		for i in range(0, 19):
			lengths[i] = 0

		for i in range(0, hclen):
			var clen = tinf_read_bits(d, 3, 0)
			lengths[clcidx[i]] = clen

		# build code length tree
		tinf_build_tree(code_tree, lengths, 19)

		while num < hlit + hdist:
			var sym = tinf_decode_symbol(d, code_tree)

			match sym:
				16:
					var prev = lengths[num - 1]
					length = tinf_read_bits(d, 2, 3)
					while length != 0:
						lengths[num] = prev
						num += 1
						length -= 1
				17:
					length = tinf_read_bits(d, 3, 3)
					while length != 0:
					   lengths[num] = 0
					   num += 1
					   length -= 1
				18:
					length = tinf_read_bits(d, 7, 11)
					while length != 0:
						lengths[num] = 0
						num += 1
						length -= 1
				_:
					lengths[num] = sym
					num += 1

		# build dynamic trees
		tinf_build_tree(lt, lengths, hlit)
		tinf_build_tree(dt, lengths.subarray(hlit, lengths.size() - 1), hdist)

	# -----------------------------
	# -- block inflate functions --
	# -----------------------------

	# given a stream and two trees, inflate a block of data
	# d: TINF_DATA
	# lt: TINF_TREE
	# dt: TINF_TREE
	func tinf_inflate_block_data(d, lt, dt):
		var start = d['destPtr']

		while true:
			var sym = tinf_decode_symbol(d, lt)

			if sym == 256:
				d['destLen'] += d['destPtr'] - start
				return TINF_OK

			if sym < 256:
				d['dest'][d['destPtr']] = sym
				d['destPtr'] += 1
			else:
				var length = 0
				var dist = 0
				var offs = 0
				var i = 0
				var ptr = d['destPtr']

				sym -= 257

				length = tinf_read_bits(d, base_tables['length_bits'][sym], base_tables['length_base'][sym])
				dist = tinf_decode_symbol(d, dt)

				# possibly get more bits from distance code
				offs = tinf_read_bits(d, base_tables['dist_bits'][dist], base_tables['dist_base'][dist])

				for i in range(0, length):
					d['dest'][ptr + i] = d['dest'][ptr + (i - offs)]

				d['destPtr'] += length


	# inflate an uncompressed block of data */
	# d: TINF_DATA
	func tinf_inflate_uncompressed_block(d):
		var length = 0
		var invlength = 0
		var i = 0

		# get length
		length = d['source'][d['sourcePtr'] + 1]
		length = 256 * length + d['source'][d['sourcePtr']]

		# get one's complement of length
		invlength = d['source'][d['sourcePtr'] + 3]
		invlength = 256 * invlength + d['source'][d['sourcePtr'] + 2]

		if length != ~invlength & 0x0000FFFF:
			return TINF_DATA_ERROR

		d['sourcePtr'] += 4

		i = length
		while i:
			d['dest'][d['destPtr']] = d['source'][d['sourcePtr']]
			d['destPtr'] += 1
			d['sourcePtr'] += 1
			i -= 1

		d['bitcount'] = 0
		d['destLen'] += length

		return TINF_OK


	# inflate a block of data compressed with fixed huffman trees
	# d: TINF_DATA
	# returns: int
	func tinf_inflate_fixed_block(d):
		# decode block using fixed trees
		return tinf_inflate_block_data(d, sltree, sdtree)


	# inflate a block of data compressed with dynamic huffman trees
	# d: TINF_DATA
	# returns: int
	func tinf_inflate_dynamic_block(d):
		# decode trees from stream
		tinf_decode_trees(d, d['ltree'], d['dtree'])

		# decode block using decoded trees
		return tinf_inflate_block_data(d, d['ltree'], d['dtree'])

	# ----------------------
	# -- public functions --
	# ----------------------

	func _init():
	   # build fixed huffman trees
	   tinf_build_fixed_trees(sltree, sdtree)

	   # build extra bits and base tables
	   tinf_build_bits_base('length', 4, 3)
	   tinf_build_bits_base('dist', 2, 1)

	   # fix a special case
	   base_tables['length_bits'][28] = 0
	   base_tables['length_base'][28] = 258


	# inflate stream from source to dest
	func tinf_uncompress(destLen, source):
		var d = TINF_DATA.duplicate()
		var dest = make_pool_byte_array(destLen)
		var sourceSize = source.size()
		d['source'] = source
		d['dest'] = dest

		destLen = 0

		while true:
			var btype = 0
			var res = 0

			# Skip final block flag
			tinf_getbit(d)

			# read block type (2 bits)
			btype = tinf_read_bits(d, 2, 0)
			match btype:
				0:
					# decompress uncompressed block
					res = tinf_inflate_uncompressed_block(d)
				1:
					# decompress block with fixed huffman trees
					res = tinf_inflate_fixed_block(d)
				2:
					# decompress block with dynamic huffman trees
					res = tinf_inflate_dynamic_block(d)
				_:
					return false

			if res != TINF_OK:
				return false

			# When we have consumed the entire source, we're done
			if d['sourcePtr'] >= sourceSize:
				break

		return d['dest']
