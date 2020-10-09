extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	texture = $Viewport.get_texture()
	set_value(25)


var red = Color(1, 0, 0, 1)
var yellow = Color(1, 1, 0, 1)
var green = Color(0, 1, 0, 1)


func set_value(val):
	$Viewport/ProgressBar.value = val
	
	# create a color gradient red 0 50-> yellow 50 -> green 50 - 100
	var color = null
	var v = float(val)
	var pos = v / 50.0
	var neg = 1.0 - pos
	
	if val > 50:
		v -= 50
		color = green * pos + yellow * neg
	else:
		color = yellow * pos + red * neg
	
	modulate = color
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
