extends Control

func _ready():
	var my_style = StyleBoxFlat.new()
	my_style.set_bg_color(Color(0,1,1,1))
	set("custom_styles/normal", my_style)
