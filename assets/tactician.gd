extends Spatial


var grid_map: GridMap = null
var selection = null
var faction = null
var mode = null


class Selection:
	var cell
	var world
	var unit


func __init__(faction_, map, mode_):
	faction = faction_
	grid_map = map
	mode = mode_
	add_units()


func new_selection(cell, world, unit):
	var s = Selection.new()
	s.cell = cell
	s.world = world
	s.unit = unit
	return s

func new_unit(kind, pos):
	mode.new_unit_world(kind, faction, pos)


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
		var _cell = new_unit(1, p)


func select_object(event, pos, collision):
	var cell = grid_map.world_to_map(pos)
	var obj = null

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		# TODO: move this logic into an editor plugin to place entities
		# on the grid map
		# create_character(pos)
		grid_map.clear_highlighted_tiles()

		if collision.collider is GridMap:
			if selection != null:
				var path = grid_map.select_move_path(selection.cell, cell)
				mode.move(selection.unit, path)
				selection = null
				
			clear_path()
		else:
			obj = mode.character_asset.instance()
			obj.hide_status()

			if cell in mode.unit_positions:
				selection = new_selection(cell, pos, collision.collider)
				grid_map.show_unit_range(cell, 2)
			else:
				selection = null
				clear_path()

		$HUD/UnitInfo.display(obj)


func draw_path(path):
	$PathPreview.show_path(path, grid_map)


func clear_path():
	$PathPreview.clear()


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

		pos = grid_map.snap_to_grid(pos)

	# Move cursor
	if pos != null:
		$Cursor.translate(pos - $Cursor.get_global_transform().origin)
	
		# Are we clicking on a
		select_object(event, pos, collision)

		# if unit selected show move path
		if selection != null:
			var end = grid_map.world_to_map(pos)
			var path = grid_map.select_move_path(selection.cell, end)
			draw_path(path)


