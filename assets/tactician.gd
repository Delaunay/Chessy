extends Spatial


var cursor_position = Vector3(0, 0, 0)
var grid_map: GridMap = null
var characters = {}
var cell_size = null


onready var character_asset = preload("res://assets/character/Character.tscn")


func create_character(pos):
	#  insert a new charater on the map
	var map_pos = grid_map.world_to_map(pos)
	var world_pos = grid_map.map_to_world(map_pos.x, map_pos.y, map_pos.z)
	
	var instance = character_asset.instance()
	characters[map_pos] = instance
	instance.visible = true
	
	$Units.add_child(instance)
	var translate = world_pos + Vector3(0, grid_map.get_cell_size().y, 0)
	instance.translate(translate / instance.scale)


# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()

	if not parent is GridMap:
		print('Error! tactician needs to be a child of GridMap')

	grid_map = parent
	cell_size = grid_map.cell_size


func snap_to_grid(pos):
	var cell = grid_map.world_to_map(pos)
	cell.y -= 1

	# make sure that a cell exist under the map position
	if grid_map.get_cell_item(cell.x, cell.y, cell.z) == GridMap.INVALID_CELL_ITEM:
		return null

	return grid_map.map_to_world(cell.x, cell.y, cell.z)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select_object():
	pass


func _input(event):
	var collision = null
	var pos = null

	# Mouse move
	if event is InputEventMouse:
		collision = $Camera.select_object(event.position)

	if collision:
		pos = snap_to_grid(collision.position)

	if pos != null:
		print("Cursor position", pos)
		$Cursor.translate(pos - cursor_position)
		cursor_position = pos
		
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
			create_character(pos)
			# select_object()
			
		return true


