extends Spatial

onready var character_asset = preload("res://assets/character/Character.tscn")
var grid_map = null
var display_container = null
var unit_info = null
var characters = {}
var moving = []


func __init__(map):
	grid_map = map
	add_units()


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
		var _cell = create_character(p)
		

func create_character(pos):
	#  insert a new charater on the map
	var map_pos = grid_map.world_to_map(pos)
	if grid_map.get_cell_item(map_pos.x, map_pos.y, map_pos.z) == GridMap.INVALID_CELL_ITEM:
		print("could not create character on ", map_pos, " x ", pos)
		return
		
	var world_pos = grid_map.map_to_world(map_pos.x, map_pos.y, map_pos.z)
	
	var instance = character_asset.instance()
	characters[map_pos] = instance
	
	add_child(instance)
	var translate = world_pos + Vector3(0, grid_map.get_cell_size().y, 0)
	instance.translate(translate / instance.scale)

	return map_pos

		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_moving = []

	for m in moving:
		var unit = m[0]
		var path = m[1]
		var p = path[m[2]]
		unit.move_now(grid_map.map_to_world(p.x, p.y + 1, p.z))

		if len(path) > m[2] + 1:
			new_moving.append([unit, path, m[2] + 1])
		else:
			characters[p] = unit
			unit.idle()


	moving = new_moving


func move(unit, path):
	characters.erase(path[0])
	moving.append([unit, path, 1])