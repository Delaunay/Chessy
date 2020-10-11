extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	texture = $Viewport.get_texture()


var health_gradient = [
	Color(1, 0, 0, 1), # Red
	Color(1, 1, 0, 1), # Yellow
	Color(0, 1, 0, 1), # Green
]


func color_gradient(val, colors):
	# create a color gradient red 0 50 -> yellow 50 -> green 50 - 100
	var v = float(val)
	var top_color = colors[1]
	var bot_color = colors[0]

	if val > 50:
		v -= 50
		top_color = colors[2]
		bot_color = colors[1]
	
	var pos = v / 50.0
	var neg = 1.0 - pos

	return top_color * pos + bot_color * neg


func set_health(val):
	$Viewport/StatusBar/VBoxContainer/Health.value = val
	$Viewport/StatusBar/VBoxContainer/Health.modulate = color_gradient(val, health_gradient)

func set_stamina(val):
	$Viewport/StatusBar/VBoxContainer/Stamina.value = val
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
