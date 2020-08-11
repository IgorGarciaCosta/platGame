extends StaticBody2D

func destruir():
	get_node("sprite").queue_free()#apaga o sprite do bloco
	get_node("shape").queue_free()#apaga o colisor do bloco
	get_node("particles").set_emitting(true)