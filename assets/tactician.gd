extends Spatial


var grid_map: GridMap = null
var selection = null


class Selection:
	var cell
	var world
	var unit


func new_selection(cell, world, unit):
	var s = Selection.new()
	s.cell = cell
	s.world = world
	s.unit = unit
	return s


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()

	if not parent is GridMap:
		print('Error! tactician needs to be a child of GridMap')

	grid_map = parent
	$Units.__init__(grid_map)


func select_object(event, pos, collision):
	var cell = grid_map.world_to_map(pos)
	var obj = null

	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		# TODO: move this logic into an editor plugin to place entities
		# on the grid map
		# create_character(pos)
		grid_map.clear_highlighted_tiles()

		if collision.collider is GridMap:
			selection = null
			clear_path()
		else:
			obj = $Units.character_asset.instance()

			if cell in $Units.characters:
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


