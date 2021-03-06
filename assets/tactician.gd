extends Spatial


var grid_map: GridMap = null
var selection = null
var faction = null
var mode = null
var select_action = null
var cursor_cell = null
var ability_slots = []
var human = false
var can_process_input = false
var color = null

class Selection:
	var cell
	var world
	var unit
	var range_cells


# UI state machine
enum {
	# We select a unit to move
	UNIT_SELECT,
	# Select where to move the unit
	UNIT_MOVE,
	# Execute an action after the move
	UNIT_ACTION
}

var ui_state = UNIT_SELECT

func transition(new_state):
	# select our unit
	if ui_state == UNIT_SELECT and new_state == UNIT_MOVE:
		ui_state = new_state
	
	# Execute selected move
	elif ui_state == UNIT_MOVE and new_state == UNIT_ACTION:
		ui_state = new_state
	
	elif ui_state == UNIT_ACTION and new_state == UNIT_SELECT:
		ui_state = new_state
	
	elif new_state == UNIT_SELECT:
		pass

	else:
		print("Invalid state transition ", ui_state, " to ", new_state)


func move_unit():
	if ui_state != UNIT_MOVE:
		print("Cannot move")
		return
	
	if selection.unit.faction == faction:
		var path = grid_map.select_move_path(selection.cell, cursor_cell)
		mode.move(selection.unit, path)
		selection.cell = path[-1]
		select_action = selection
	selection = null
	transition()


func __init__(faction_, map, mode_, human_):
	faction = faction_
	grid_map = map
	mode = mode_
	setup_abilities()
	human = human_
	
	if not human:
		$Cursor.visible = false
		$PathPreview.visible = false
		$HUD.visible = false


func new_selection(cell, world, unit, cells):
	var s = Selection.new()
	s.cell = cell
	s.world = world
	s.unit = unit
	s.range_cells = cells
	return s


func new_unit(kind, pos):
	mode.new_unit_world(kind, faction, pos, color)


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
				print('Selection is not null')
				if selection.unit.faction == faction:
					var path = grid_map.select_move_path(selection.cell, cursor_cell)
					mode.move(selection.unit, path)
					selection.cell = path[-1]
					select_action = selection
				selection = null

			clear_path()
			print('Grid Map selected')
		else:
			print(collision.collider)
			obj = mode.character_asset.instance()
			obj.hide_status()

			if cell in mode.unit_positions:
				var cells = grid_map.show_unit_range(cell, collision.collider.unit_range)
				selection = new_selection(cell, pos, collision.collider, cells)
				print('Unit selected')
				# Unit selected enter Unit selection mode
				$Cursor.visible = false
			else:
				selection = null
				clear_path()
				print('Did not find a unit')

		$HUD/UnitInfo.display(obj)


func draw_path(path):
	$PathPreview.show_path(path, grid_map)


func clear_path():
	$PathPreview.clear()
	$Cursor.visible = true


func clear_selection():
	selection = null
	clear_path()
	grid_map.clear_highlighted_tiles()
	$HUD/UnitInfo.display(null)


func _input(event):
	if not can_process_input:
		return 

	if grid_map == null:
		return 

	var collision = null
	var pos = null

	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			clear_selection()

	# Mouse move
	if event is InputEventMouse:
		collision = $Camera.select_object(event.position)

	# This is a bit hacky
	if collision:
		var offset = 1

		if collision.collider is GridMap:
			pos = collision.position
		else:
			# Object should have a position which is compatible with 
			# our grid system so we know that this will get us a tile
			pos = collision.collider.get_global_transform().origin - grid_map.offset
			offset = 0

		pos = grid_map.snap_to_grid(pos, offset)

	# Move cursor
	if pos != null:
		var end = grid_map.world_to_map(pos)
		
		if selection == null:
			$Cursor.translate(pos - $Cursor.get_global_transform().origin)
			cursor_cell = end
	
		# Are we clicking on a
		select_object(event, pos, collision)

		# if unit selected show move path
		if selection != null and end in selection.range_cells and selection.unit.faction == faction:
			$Cursor.translate(pos - $Cursor.get_global_transform().origin)
			cursor_cell = end
			
			var path = grid_map.select_move_path(selection.cell, end)
			draw_path(path)


func _get_name(obj):
	return obj.get_name()


func setup_abilities():
	for ability_slot in $HUD/ActionBar/HBoxContainer.get_children():
		ability_slots.append(ability_slot)
	
	# Just make sure there is no weird ordering here
	ability_slots.sort_custom(self, "_get_name")
	
	var k = 0
	for slot in ability_slots:
		slot.connect("pressed", self, "call_ability", [k, slot])
		k += 1


var base_axial_direction = [
	Vector3(+1, 0, 0), Vector3(+1, 0, -1), Vector3(0, 0, -1), 
	Vector3(-1, 0, 0), Vector3(-1, 0, +1), Vector3(0, 0, +1), 
]

func call_ability(slot_id, slot):
	get_tree().set_input_as_handled()

	if selection == null and select_action != null:
		var units = []

		for dir in base_axial_direction:
			for i in [0, 1, -1]:
				var next = select_action.cell + dir + Vector3(0, i, 0)
				if next in mode.unit_positions:
					units.append(mode.unit_positions[next])
		
		select_action.unit.attack()
		for unit in units:
			unit.hit()
			unit.update_health(-10)
		
		select_action = null
	slot.press()

