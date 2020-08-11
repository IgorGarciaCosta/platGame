extends Node


func _on_play_pressed():
	transition.fade_to("res://scenes/lvl5.tscn")
	#transition.fade_to("res://scenes/cutScenes/cut1.tscn")


func _on_Credits_pressed():
	transition.fade_to("res://scenes/creditos.tscn")
