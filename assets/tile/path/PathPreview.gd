extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var path_left_right = preload("res://assets/tile/path/PathLeftRight.tscn")
onready var path_left_top = preload("res://assets/tile/path/PathLeftTop.tscn")
onready var path_left_bot = preload("res://assets/tile/path/PathLeftBot.tscn")
onready var arrow = preload("res://assets/tile/path/Arrow.tscn")

enum {
	STRAIGHT,
	TURN_RIGHT,
	TURN_LEFT,
	START,
	END
}


export var show_start = false
export var show_end = false
var used = []

func make_tile(kind):
	var new_tile
	
	if kind == STRAIGHT:
		new_tile = path_left_right.instance()

	elif kind == TURN_LEFT:
		new_tile = path_left_top.instance()
	
	# catch all for now
	else:
		new_tile = path_left_right.instance()
	
	new_tile.visible = false
	add_child(new_tile)
	used.append(new_tile)
	return new_tile


var straight_offset = 180
var dir2angle = {
	Vector3( 0, 0, -1):  60 + straight_offset,
	Vector3( 0, 0,  1):  60,
	Vector3( 1, 0, -1):   0 + straight_offset,
	Vector3(-1, 0,  1):   0,
	Vector3( 1, 0,  0): -60 + straight_offset,
	Vector3(-1, 0,  0): -60
}

# set for directional path 
var turn_offset = 180
var turn2angle = {
	Vector3( 1, 0, 0): 0,
	Vector3(0, 0,  1): 120 + turn_offset,
	Vector3(-1, 0, 1): 60 + turn_offset,
	Vector3(-1, 0, 0): 0 + turn_offset,
	
	Vector3(1, 0, -1): -120,
	Vector3(0, 0, -1): -60 + turn_offset,
}


var turn_left = {
	Vector3( 1, 0, 0): TURN_LEFT,
	Vector3(0, 0,  1): TURN_LEFT,
	Vector3(-1, 0, 1): TURN_LEFT,
}

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


func _add_tile(kind, pos, angle, grid_map):
	var new_tile = make_tile(kind)
	new_tile.set_global_transform(Transform())
	new_tile.translate(grid_map.map_to_world(pos.x, pos.y, pos.z))
	new_tile.rotate(Vector3(0, 1, 0), deg2rad(angle))
	new_tile.visible = true


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


func _show_path(path, grid_map):
	clear()

	var kind = null
	var angle = 0

	# Add the start and last tiles
	if len(path) >= 2:
		if show_start:
			var v = path[0] - path[1]
			v.y = 0
			_add_tile(START, path[0], dir2angle.get(v), grid_map)
			
		if show_end:
			var v = path[-1] - path[-2]
			v.y = 0
			_add_tile(END, path[-1], dir2angle.get(v), grid_map)

	for k in range(1, len(path) - 1):
		var p = path[k - 1]
		var c = path[k]
		var n = path[k + 1]
		
		var v1 = p - c
		var v2 = c - n
		
		var turn_angle = compute_angle(v1, v2)
		var is_turning = abs(turn_angle) > 0.01
	
		if is_turning:
			kind = TURN_LEFT
			var v = v1 - v2
			v.y = 0
			print('T', v, v1, v2)
			angle = turn2angle.get(v, 0)
		else:
			kind = STRAIGHT
			var v = c - p
			v.y = 0
			print('S ', v)
			angle = dir2angle.get(v)
	
		_add_tile(kind, c, angle, grid_map)


func clear():
	while len(used) > 0:
		var u = used.pop_back()
		u.visible = false
		remove_child(u)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func old_clear_path():
	$Draw.clear()


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
