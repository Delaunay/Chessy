extends Spatial


var grid_map: GridMap = null
var characters = {}
var cell_size = null
var selection_cell = null
var selection = null
var unit_selected = false

onready var character_asset = preload("res://assets/character/Character.tscn")

var base_axial_direction = [
	Vector3(+1, 0, 0), Vector3(+1, 0, -1), Vector3(0, 0, -1), 
	Vector3(-1, 0, 0), Vector3(-1, 0, +1), Vector3(0, 0, +1), 
]


func neigboors():
	# generates list of immediate neighboors
	var neighs = []
	
	for dir in base_axial_direction:
		for i in [1, 0, -1]:
			neighs.append(dir + Vector3(0, i, 0))
			
	return neighs


var axial_direction = neigboors()


func highlight_pos_circle(cell):
	# highlight an area around the character for testing purposes
	for dir in base_axial_direction:
		# check current level then one higher then one lower
		for i in [0, 1, -1]:
			var neigh = cell + dir + Vector3(0, i, 0)

			if grid_map.get_cell_item(neigh.x, neigh.y, neigh.z) == GridMap.INVALID_CELL_ITEM:
				continue
				 
			grid_map.set_cell_data(neigh.x, neigh.y, neigh.z, Color(1, 0, 0, 0))
			# we found one tile in that direction no need to check other levels
			break


func create_character(pos):
	#  insert a new charater on the map
	var map_pos = grid_map.world_to_map(pos)
	if grid_map.get_cell_item(map_pos.x, map_pos.y, map_pos.z) == GridMap.INVALID_CELL_ITEM:
		print("could not create character on ", map_pos, " x ", pos)
		return
		
	var world_pos = grid_map.map_to_world(map_pos.x, map_pos.y, map_pos.z)
	
	var instance = character_asset.instance()
	characters[map_pos] = instance
	
	$Units.add_child(instance)
	var translate = world_pos + Vector3(0, grid_map.get_cell_size().y, 0)
	instance.translate(translate / instance.scale)

	# highlight_pos_circle(map_pos)
	print("pos", pos)
	return map_pos


func add_units():
	# TODO: move this when the grid map is loaded
	var positions = [
		Vector3( 0, 0,  0),
		# --
		Vector3( 6, 0,  0),
		Vector3(-6, 0,  0),
		Vector3( 0, 0,  6),
		Vector3( 0, 0, -6),
		# --
		Vector3( 6, 0,  6),
		Vector3(-6, 0,  6),
		Vector3(-6, 0, -6),
		Vector3( 6, 0, -6)
	]
	
	for p in positions:
		var cell = create_character(p)
		
	# var path = select_move_path(Vector3( 0, 0, 0), Vector3(2, 0, 2))
	# draw_path(select_move_path(Vector3( 0, 0, 0), Vector3(2, 0, 2)))


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()

	if not parent is GridMap:
		print('Error! tactician needs to be a child of GridMap')

	grid_map = parent
	cell_size = grid_map.cell_size
	
	add_units()
	$HUD/UnitInfo.visible = false


func snap_to_grid(pos, offset=1):
	var cell = grid_map.world_to_map(pos)
	cell.y -= offset

	# make sure that a cell exist under the map position
	if grid_map.get_cell_item(cell.x, cell.y, cell.z) == GridMap.INVALID_CELL_ITEM:
		return null

	return grid_map.map_to_world(cell.x, cell.y, cell.z)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func display(obj = null):
	# TODO move this to the UnitInfo script
	var display_container = $HUD/UnitInfo/VBoxContainer/Preview/Viewport/DisplayWorld/Container

	for child in display_container.get_children():
		display_container.remove_child(child)
		
	if obj:
		display_container.add_child(obj)
		$HUD/UnitInfo.visible = true
	else:
		$HUD/UnitInfo.visible = false


func select_object(event, pos, collision):
	var cell = grid_map.world_to_map(pos)
	var obj = null

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		# TODO: move this logic into an editor plugin to place entities
		# on the grid map
		# create_character(pos)
		clear_highlighted_tiles()

		if collision.collider is GridMap:
			selection = null
			unit_selected = false
			$Draw.clear()
		else:
			selection = collision.collider
			obj = character_asset.instance()

			if cell in characters:
				unit_selected = true
				selection_cell = cell
				show_unit_range(cell, 2)
			else:
				$Draw.clear()
				unit_selected = false
				selection_cell = null

		display(obj)


var highlighted_tiles = []


func clear_highlighted_tiles():
	for highlight in highlighted_tiles:
		grid_map.set_cell_data(highlight.x, highlight.y, highlight.z, Color(0, 0, 0, 0))
	highlighted_tiles = []


func show_unit_range(cell, unit_range):
	clear_highlighted_tiles()

	# breadth-first search given our unit range
	if grid_map.get_cell_item(cell.x, cell.y, cell.z) == GridMap.INVALID_CELL_ITEM:
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

				if grid_map.get_cell_item(neigh.x, neigh.y, neigh.z) == GridMap.INVALID_CELL_ITEM:
					continue
				
				highlight = neigh

				if d + 1 < unit_range:
					pending.append([d + 1, highlight])
				
				highlighted_tiles.append(highlight)
				grid_map.set_cell_data(highlight.x, highlight.y, highlight.z, Color(1, 0, 0, 0))
				break
	
	return


# TODO: move this to the GridMap Script
func select_move_path(start, end):
	# select_move_path(Vector3( 1, 0, 1), Vector3(0, 0, 0))
	if start == end:
		return []
		
	if grid_map.get_cell_item(start.x, start.y, start.z) == GridMap.INVALID_CELL_ITEM:
		print("start ", start, " is not on the map")
		return []
		
	if grid_map.get_cell_item(end.x, end.y, end.z) == GridMap.INVALID_CELL_ITEM:
		print("end ", end, " is not on the map")
		return []
	
	var frontier = []
	frontier.append(start)
	
	var came_from = {}
	came_from[start] = null

	while len(frontier) != 0:
		var current = frontier.pop_front()
		
		if current == end:
			break

		for dir in base_axial_direction:
			for i in [0, 1, -1]:
				var next = current + dir + Vector3(0, i, 0)
				
				if next in came_from:
					continue
				
				if grid_map.get_cell_item(next.x, next.y, next.z) == GridMap.INVALID_CELL_ITEM:
					continue
				
				frontier.append(next)
				came_from[next] = current
				break

	# print(came_from)
	var path = []
	var current = end
	
	while current != start:
		path.append(current)
		current = came_from[current]
	
	path.append(start)
	return path


func draw_path(path):
	if len(path) == 0:
		return

	var yoffset = Vector3(0, 0.10, 0)
	# var s = path[0] + Vector3(0, 1, 0)
	# var e = path[-1] + Vector3(0, 1, 0)
	
	var im = $Draw

	im.clear()
	im.begin(Mesh.PRIMITIVE_POINTS, null)
	# im.add_vertex(grid_map.map_to_world(s.x, s.y, s.z) + yoffset)
	# im.add_vertex(grid_map.map_to_world(e.x, e.y, e.z) + yoffset)
	im.end()
	
	im.begin(Mesh.PRIMITIVE_LINE_STRIP, null)
	for n in path:
		n.y += 1
		im.add_vertex(grid_map.map_to_world(n.x, n.y, n.z))
	im.end()


func _input(event):
	var collision = null
	var pos = null

	# Mouse move
	if event is InputEventMouse:
		collision = $Camera.select_object(event.position)

	if collision:
		if collision.collider is GridMap:
			pos = collision.position
		else:
			# Object should have a position which is compatible with 
			# our grid system so we know that this will get us a tile
			pos = collision.collider.get_global_transform().origin

		pos = snap_to_grid(pos)

	if pos != null:
		$Cursor.translate(pos - $Cursor.get_global_transform().origin)
		select_object(event, pos, collision)
		
		if selection != null:
			var end = grid_map.world_to_map(pos)
			draw_path(select_move_path(selection_cell, end))


