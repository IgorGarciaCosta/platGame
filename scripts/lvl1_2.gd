extends Node
onready var perc = get_node("personagem")
onready var camera = get_node("dead_camera")

var moedas = 0
var vidas = 3

func _ready():
	set_process(true)#habilita o processamento a cada frame
	
func _process(delta):
	get_node("CanvasLayer/Panel/time").set_text(str(int(get_node("game_time").get_time_left())))

func change_camera():
	camera.set_global_pos(perc.get_node("camera").get_camera_pos())
	camera.make_current()#fazer a dead cam virar  a principal nesse momento

func _on_personagem_morreu():
	change_camera()
	get_node("spawn_time").set_wait_time(2)
	get_node("spawn_time").start()
	
	vidas -=1
	if vidas == 2:
		get_node("CanvasLayer/Panel/heart1").set_texture(load("res://assets/hud_heartEmpty.png"))
	elif vidas == 1:
		get_node("CanvasLayer/Panel/heart2").set_texture(load("res://assets/hud_heartEmpty.png"))
	elif vidas == 0:
		get_node("CanvasLayer/Panel/heart3").set_texture(load("res://assets/hud_heartEmpty.png"))



func _on_spawn_time_timeout():
	if vidas>0:
		reviver()
	else:
		transition.fade_to("res://scenes/mainMenu.tscn")	
	reviver()
	
func reviver():
	perc.set_pos(get_node("spawn_point").get_pos())	
	perc.reviver()
	
	get_node("game_time").set_wait_time(201)
	get_node("game_time").start()


func _on_personagem_fim():#pra o game saber quando chegarmos ao fim
	change_camera()
	get_node("spawn_time").set_wait_time(3)
	transition.fade_to("res://scenes/cutScenes/cut2.tscn")#vai pro level 2 ao chegar no final
	#get_node("spawn_time").start()


func _on_personagem_moeda():
	moedas+=1
	get_node("CanvasLayer/Panel/moedas").set_text(str(moedas))


