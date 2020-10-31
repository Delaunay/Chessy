extends Spatial

onready var arrow = preload("res://assets/tile/path/Arrow.tscn")


export var show_start = false
export var show_end = false
var used = []


func compute_angle(a, b):
	var dot = (a.x * b.x + a.z * b.z)
	var aa = sqrt(a.x * a.x + a.z * a.z)
	var bb = sqrt(b.x * b.x + b.z * b.z)
	return rad2deg(acos(dot / (aa * bb)))


func add_tile(parrow, pos, grid_map):
	parrow.visible = false
	add_child(parrow)
	used.append(parrow)
	parrow.set_global_transform(Transform())
	parrow.translate(grid_map.map_to_world(pos.x, pos.y, pos.z))
	parrow.visible = true


func show_path(path, grid_map):
	clear()
	
	# Add the start and last tiles
	if len(path) >= 2:
		for k in range(1, len(path) - 1):
			var p = path[k - 1]
			var c = path[k]
			var n = path[k + 1]
			
			var v1 = p - c
			var v2 = c - n
		
			var parrow = arrow.instance()
			parrow.__init__(v1, v2)
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
