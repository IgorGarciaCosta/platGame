extends KinematicBody2D
var sent = 1
var vivo = true

func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var new_offset = get_parent().get_unit_offset() + delta*sent*0.2
	
	get_parent().set_unit_offset(new_offset)
	
	if sent==1 and new_offset>=0.99999:
		
		get_parent().set_unit_offset(0)#volta pro inicio do trajeto

