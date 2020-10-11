extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var display_container = null

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	# display_container = $VBoxContainer/CenterContainer/Preview/Viewport/DisplayWorld/Container
	display_container = $VBoxContainer/Preview/Viewport/DisplayWorld/Container
	

func display(obj = null):
	for child in display_container.get_children():
		display_container.remove_child(child)

	if obj:
		display_container.add_child(obj)
		visible = true

	else:
		visible = false


func set_viewport_size():
	$Viewport.size = self.rect_size 

