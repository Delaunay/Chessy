extends Spatial

onready var arrow = preload("res://assets/tile/path/Arrow.tscn")


export var show_start = true
export var show_end = true
var used = []

var prev_direction = {
	Vector3( 0, 0, +1): preload("res://assets/tile/path/arrows/s0-1.png"),	# UP
	Vector3( 0, 0, -1): preload("res://assets/tile/path/arrows/s0+1.png"),	# DOWN
	Vector3(+1, 0, -1): preload("res://assets/tile/path/arrows/s-1+1.png"),
	Vector3(+1, 0,  0): preload("res://assets/tile/path/arrows/s-10.png"),
	Vector3(-1, 0, +1): preload("res://assets/tile/path/arrows/s+1-1.png"),
	Vector3(-1, 0,  0): preload("res://assets/tile/path/arrows/s+10.png"),
}

var dest_direction = {
	Vector3( 0, 0, +1): preload("res://assets/tile/path/arrows/e0+1.png"),	# UP
	Vector3( 0, 0, -1): preload("res://assets/tile/path/arrows/e0-1.png"),	# DOWN
	Vector3(+1, 0, -1): preload("res://assets/tile/path/arrows/e+1-1.png"),
	Vector3(+1, 0,  0): preload("res://assets/tile/path/arrows/e+10.png"),
	Vector3(-1, 0, +1): preload("res://assets/tile/path/arrows/e-1+1.png"),
	Vector3(-1, 0,  0): preload("res://assets/tile/path/arrows/e-10.png"),
}

var start_tex = preload("res://assets/tile/path/arrows/start.png")
var end_tex = preload("res://assets/tile/path/arrows/end.png")
var empty_tex = preload("res://assets/tile/path/arrows/empty.png")
var arrow_mat = preload("res://assets/tile/path/ArrowMaterial.tres")
var mat_cache = {}
 

func compute_angle(a, b):
	var dot = (a.x * b.x + a.z * b.z)
	var aa = sqrt(a.x * a.x + a.z * a.z)
	var bb = sqrt(b.x * b.x + b.z * b.z)
	return rad2deg(acos(dot / (aa * bb)))


func new_tile(v1 , v2):
	var parrow = arrow.instance()
	parrow.set_material(get_material(v1, v2))
	return parrow


func add_tile(parrow, pos, grid_map):
	parrow.visible = false
	add_child(parrow)
	used.append(parrow)
	parrow.set_global_transform(Transform())
	parrow.translate(grid_map.map_to_world(pos.x, pos.y, pos.z))
	parrow.visible = true


func get_material(d1, d2):
	var result = mat_cache.get([d1, d2])

	if result == null:
		var tex1 = empty_tex
		var tex2 = empty_tex
		
		if d1 is String:
			if d1 == 'start':
				tex1 = start_tex
			elif d1 == 'end':
				tex2 = end_tex
		else:
			tex1 = prev_direction.get(d1)
			tex2 = dest_direction.get(d2)
		
		result = arrow_mat.duplicate()
		result.set_shader_param("tex_frg_2", tex1)
		result.set_shader_param("tex_frg_3", tex2)
		mat_cache[[d1, d2]] = result

	return result


func show_path(path, grid_map):
	clear()

	# Add the start and last tiles
	if len(path) >= 2:
		if show_start:
			var v = path[0] - path[1]
			v.y = 0
			var parrow = new_tile('start', null)
			add_tile(parrow, path[0], grid_map)
			
		if show_end:
			var v = path[-1] - path[-2]
			v.y = 0
			var parrow = new_tile('end', null)
			add_tile(parrow, path[-1], grid_map)

		for k in range(1, len(path) - 1):
			var p = path[k - 1]
			var c = path[k]
			var n = path[k + 1]
			
			var v1 = p - c
			var v2 = c - n

			var parrow = new_tile(v1, v2)
			add_tile(parrow, c, grid_map)


func clear():
	while len(used) > 0:
		var u = used.pop_back()
		u.visible = false
		remove_child(u)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var center = null

func sort_winding(a, b):
	var a1 = fmod(rad2deg(atan2(a.x - center.x, a.z - center.z)) + 360.0, 360.0)
	var a2 = fmod(rad2deg(atan2(b.x - center.x, b.z - center.z)) + 360.0, 360.0)
	return a1 > a2


func hex_mid(c, size, i):
	if i == null:
		return c

	var angle_deg = 60 * i - 30
	var angle_rad = PI / 180 * angle_deg
	return Vector3(c.x + size * cos(angle_rad), c.y, c.z + size * sin(angle_rad))


func draw_rectangle(im, points):
	# because of winding order we need to sort our vertices
	center = (points[0] + points[2]) / 2.0
	points.sort_custom(self, "sort_winding")

	im.add_vertex(points[0])
	im.add_vertex(points[1])
	im.add_vertex(points[2])
	
	im.add_vertex(points[0])
	im.add_vertex(points[2])
	im.add_vertex(points[3])


var direction_mid = {
	Vector3( 1, 0,  0): 0,
	Vector3( 1, 0, -1): 1,
	Vector3( 0, 0, -1): 2,
	Vector3(-1, 0,  0): 3,
	Vector3(-1, 0,  1): 4,
	Vector3( 0, 0,  1): 5,
}


func old_draw_path(path, grid_map):
	if len(path) == 0:
		return

	var im = $Draw

	im.clear()
	# im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	im.begin(Mesh.PRIMITIVE_TRIANGLES, null)

	var prev
	var w = 0.5 / 2
	var offset = Vector3(w, 0, 0)

	var p1
	var p2

	for k in range(len(path)):
		var n = path[k] + Vector3(0, 1, 0)
		var next = grid_map.map_to_world(n.x, n.y, n.z) + Vector3(0, 0.10, 0)
		
		if prev == null:
			p1 = next - offset
			p2 = next + offset
		else:
			var rectangle = [p1, p2, next + offset, next - offset]
			draw_rectangle(im, rectangle)
			p1 = next - offset
			p2 = next + offset
		

		prev = next

	im.end()
