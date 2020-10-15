extends Sprite3D

var floating_text_class = preload("res://assets/character/CombatText.tscn")

export var travel = Vector2(-80, -80)
export var duration = 2
export var spread = PI


func _ready():
	texture = $Viewport.get_texture()
	visible = true


func show_value(value, crit=false):
	var floating_text = floating_text_class.instance()
	$Viewport/Control.add_child(floating_text)
	floating_text.show_value(str(value), travel, duration, spread, crit)
