extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var cursor_position = Vector3(0, 0, 0)


func _input(event):
	var collision = $Camera.select_object(event)
	
	# {collider:[GridMap:1321], collider_id:1321, normal:(0.004067, 0.999941, 0.010094), position:(-3.100389, 0.544514, 4.125091), rid:[RID], shape:37}

	if collision:
		var parent = get_parent()

		if not parent is GridMap:
			print('Error! tactician needs to be a child of GridMap')
			return false

		var cell = parent.world_to_map(collision.position)
		cell.y -= 1
		var cell_pos = parent.map_to_world(cell.x, cell.y, cell.z)
		
		$Cursor.translate(cell_pos - cursor_position)
		cursor_position = cell_pos
		
		print("Move and slide to", cell_pos)
		# collision.collider
		
		print(collision)
		return true

	
