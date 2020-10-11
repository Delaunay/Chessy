extends GridMap


var highlighted_tiles = []
var base_axial_direction = [
	Vector3(+1, 0, 0), Vector3(+1, 0, -1), Vector3(0, 0, -1), 
	Vector3(-1, 0, 0), Vector3(-1, 0, +1), Vector3(0, 0, +1), 
]
var axial_direction = neigboors()


func neigboors():
	# generates list of immediate neighboors
	var neighs = []
	
	for dir in base_axial_direction:
		for i in [1, 0, -1]:
			neighs.append(dir + Vector3(0, i, 0))
	
	return neighs


# Called when the node enters the scene tree for the first time.
func _ready():
	load_map()
	$GameMode.__init__(self)
	$GameMode.new_faction('X')
	$Tactician.__init__('X', self, $GameMode)


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


# TODO: move this to the GridMap Script
func select_move_path(start, end):
	# select_move_path(Vector3( 1, 0, 1), Vector3(0, 0, 0))
	if start == end:
		return []
		
	if get_cell_item(start.x, start.y, start.z) == GridMap.INVALID_CELL_ITEM:
		print("start ", start, " is not on the map")
		return []
		
	if get_cell_item(end.x, end.y, end.z) == GridMap.INVALID_CELL_ITEM:
		print("end ", end, " is not on the map")
		return []
	
	var frontier = []
	frontier.append(start)
	
	var came_from = {}
	var current = null
	came_from[start] = null

	while len(frontier) != 0:
		current = frontier.pop_front()
		
		if current == end:
			break

		for dir in base_axial_direction:
			for i in [0, 1, -1]:
				var next = current + dir + Vector3(0, i, 0)
				
				if next in came_from:
					continue
				
				if get_cell_item(next.x, next.y, next.z) == GridMap.INVALID_CELL_ITEM:
					continue
					
				if next in $GameMode.unit_positions:
					if next == end:
						return []

					continue
				
				frontier.append(next)
				came_from[next] = current
				break

	# print(came_from)
	var path = []
	
	while current != start:
		path.append(current)
		current = came_from[current]
	
	path.append(start)
	path.invert()
	return path


func highlight_pos_circle(cell):
	# highlight an area around the character for testing purposes
	for dir in base_axial_direction:
		# check current level then one higher then one lower
		for i in [0, 1, -1]:
			var neigh = cell + dir + Vector3(0, i, 0)

			if get_cell_item(neigh.x, neigh.y, neigh.z) == GridMap.INVALID_CELL_ITEM:
				continue
					
			set_cell_data(neigh.x, neigh.y, neigh.z, Color(1, 0, 0, 0))
			# we found one tile in that direction no need to check other levels
			break
	

func clear_highlighted_tiles():
	for highlight in highlighted_tiles:
		set_cell_data(highlight.x, highlight.y, highlight.z, Color(0, 0, 0, 0))
	highlighted_tiles = []


func show_unit_range(cell, unit_range):
	clear_highlighted_tiles()

	# breadth-first search given our unit range
	if get_cell_item(cell.x, cell.y, cell.z) == GridMap.INVALID_CELL_ITEM:
		return null

	# we keep the depth because tile types will influence the range
	var pending = [[0, cell]]
	while len(pending) > 0:
		var data = pending.pop_front()

		var d = data[0]
		var c = data[1]

		for dir in base_axial_direction:
			var highlight = null

			for i in [0, 1, -1]:
				var neigh = c + dir + Vector3(0, i, 0)

				if get_cell_item(neigh.x, neigh.y, neigh.z) == GridMap.INVALID_CELL_ITEM:
					continue
				
				highlight = neigh

				if d + 1 < unit_range:
					pending.append([d + 1, highlight])
				
				highlighted_tiles.append(highlight)
				set_cell_data(highlight.x, highlight.y, highlight.z, Color(1, 0, 0, 0))
				break
	
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
