extends Node2D

func _on_Button_pressed():
	var _scene_change_error = get_tree().change_scene("res://main.tscn")
