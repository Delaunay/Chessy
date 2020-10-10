extends GridMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	load_map()
	pass # Replace with function body.


func snap_to_grid(pos, offset=1):
	var cell = world_to_map(pos)
	cell.y -= offset

	# make sure that a cell exist under the map position
	if get_cell_item(cell.x, cell.y, cell.z) == GridMap.INVALID_CELL_ITEM:
		return null

	return map_to_world(cell.x, cell.y, cell.z)


func square_map(radius, rot=22):
	for i in range(radius):
		for j in range(radius):
			var points = [
				Vector3( i, 0,  j),
				Vector3(-i, 0,  j),
				Vector3( i, 0, -j),
				Vector3(-i, 0, -j),
			]
			
			for p in points:
				set_cell_item(p.x, p.y, p.z, 0, rot)


func hex_distance(a, b):
	return (abs(a[0] - b[0]) + abs(a[0] + a[2] - b[0] - b[2]) + abs(a[2] - b[2])) / 2


func circle_map(radius, rot=22):
	for i in range(radius):
		for j in range(radius):
			var points = [
				Vector3( i, 0,  j),
				Vector3(-i, 0,  j),
				Vector3( i, 0, -j),
				Vector3(-i, 0, -j),
			]
			
			for p in points:
				if hex_distance(Vector3(0, 0, 0), p) <= radius:
					set_cell_item(p.x, p.y, p.z, 0, rot)


func load_map():
	clear()
	circle_map(10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
