extends Spatial


var cursor_position = Vector3(0, 0, 0)
var grid_map = null


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()

	if not parent is GridMap:
		print('Error! tactician needs to be a child of GridMap')

	grid_map = parent
	cursor_position = snap_to_grid(cursor_position)
	$Cursor.translate(cursor_position)


func snap_to_grid(pos):
	var cell = grid_map.world_to_map(pos)
	cell.y -= 1
	return grid_map.map_to_world(cell.x, cell.y, cell.z)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	var collision = $Camera.select_object(event)
	
	if collision:
		var pos = snap_to_grid(collision.position)
		$Cursor.translate(pos - cursor_position)
		cursor_position = pos
		return true


