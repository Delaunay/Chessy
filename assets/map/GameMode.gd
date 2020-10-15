extends Spatial

var grid_map
var all_units = []
var unit_factions = {}
var unit_positions = {}
var friend_or_foe = {}
var moving = []

onready var character_asset = preload("res://assets/character/Character.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func __init__(map):
	grid_map = map


func new_faction(key):
	unit_factions[key] = []


func is_friend(f1, f2):
	var key
	if f1 > f2:
		key = f2 + f1
	else:
		key = f1 + f2

	return friend_or_foe.get(key, false)
 

func is_foe(f1, f2):
	return not is_friend(f1, f2)


func move(unit, path):
	# this makes the unit non selectable as long as it is moving
	unit_positions.erase(unit.cell)
	unit.cell = path[-1]
	unit_positions[unit.cell] = unit
	moving.append([unit, path, 1])


func new_unit_world(kind, faction, pos):
	#  insert a new charater on the map
	var map_pos = grid_map.world_to_map(pos)

	if grid_map.get_cell_item(map_pos.x, map_pos.y, map_pos.z) == GridMap.INVALID_CELL_ITEM:
		print("could not create character on ", map_pos, " x ", pos)
		return null
		
	var world_pos = grid_map.map_to_world(map_pos.x, map_pos.y, map_pos.z)
	
	var instance = null

	if kind == 0:
		instance = character_asset.instance()
	else:
		instance = character_asset.instance()
	
	instance.__init__(self)
	instance.faction = faction
	instance.cell = map_pos
	instance.index = len(all_units)

	all_units.append(instance)
	unit_factions[faction].append(instance)
	unit_positions[map_pos] = instance
	add_child(instance)

	var translate = world_pos + Vector3(0, grid_map.get_cell_size().y, 0)
	instance.translate(translate / instance.scale)
	return map_pos


func remove_unit(unit):
	unit_factions[unit.faction].erase(unit)
	all_units.erase(unit)
	unit_positions.erase(unit.cell)
	remove_child(unit)


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
			unit.idle()

	moving = new_moving


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
