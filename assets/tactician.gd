extends Spatial


var grid_map: GridMap = null
var characters = {}
var cell_size = null
var selection = null
var unit_selected = false

onready var character_asset = preload("res://assets/character/Character.tscn")


func create_character(pos):
	#  insert a new charater on the map
	var map_pos = grid_map.world_to_map(pos)
	var world_pos = grid_map.map_to_world(map_pos.x, map_pos.y, map_pos.z)
	
	var instance = character_asset.instance()
	characters[map_pos] = instance
	
	$Units.add_child(instance)
	var translate = world_pos + Vector3(0, grid_map.get_cell_size().y, 0)
	instance.translate(translate / instance.scale)
	
	print("pos", pos)


func add_units():
	var positions = [
		Vector3(-1.5, 1, -2.598076),
		Vector3(1.5, 1, -0.866025),
		Vector3(-1.5, 0, 0.866025)
	]
	
	for p in positions:
		create_character(p)


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

		if collision.collider is GridMap:
			selection = null
			unit_selected = false
		else:
			selection = collision.collider
			obj = character_asset.instance()

			if cell in characters:
				unit_selected = true
			else:
				unit_selected = false
				
		display(obj)


func _input(event):
	var collision = null
	var pos = null

	# Mouse move
	if event is InputEventMouse:
		collision = $Camera.select_object(event.position)

	if collision:
		var offset = 1

		if collision.collider is GridMap:
			pos = collision.position
		else:
			# Object should have a position which is compatible with 
			# our grid system so we know that this will get us a tile
			pos = collision.collider.get_global_transform().origin
			offset = 1

		pos = snap_to_grid(pos, offset)

	if pos != null:
		$Cursor.translate(pos - $Cursor.get_global_transform().origin)
		select_object(event, pos, collision)

		return true


