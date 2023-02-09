extends Reference
class_name ColorMaps

enum Type {
	VIRIDIS,
	INFERNO,
	MAGMA,
	PLASMA
}

static func get_colormap(type: int) -> Gradient:
	var gradient: Gradient = Gradient.new()
	match type:
		Type.VIRIDIS:
			gradient.set_color(0, Color("#fde725"))
			gradient.set_color(1, Color("#440154"))
			gradient.add_point(0.25, Color("#5ec962"))
			gradient.add_point(0.5, Color("#21918c"))
			gradient.add_point(0.85, Color("#3b528b"))
		Type.INFERNO:
			gradient.set_color(0, Color("#fcffa4"))
			gradient.set_color(1, Color("#000004"))
			gradient.add_point(0.25, Color("#f98e09"))
			gradient.add_point(0.5, Color("#bc3754"))
			gradient.add_point(0.85, Color("#57106e"))
		Type.MAGMA:
			gradient.set_color(0, Color("#fcfdbf"))
			gradient.set_color(1, Color("#000004"))
			gradient.add_point(0.25, Color("#fc8961"))
			gradient.add_point(0.5, Color("#b73779"))
			gradient.add_point(0.85, Color("#51127c"))
		Type.PLASMA:
			gradient.set_color(0, Color("#f0f921"))
			gradient.set_color(4, Color("#0d0887"))
			gradient.add_point(0.25, Color("#f89540"))
			gradient.add_point(0.5, Color("#cc4778"))
			gradient.add_point(0.85, Color("#7e03a8"))
	return gradient
