extends KinematicBody2D

onready var rayE = get_node("rayE")
onready var rayD = get_node("rayD")
onready var sprite = get_node("sprite")
var vivo = true

signal morreu
signal moeda
signal fim

var left
var right
var up
var fim = false



# Member variables
const GRAVITY = 1100.0 # Pixels/second

# Angle in degrees towards either side that the player can consider "floor"
const FLOOR_ANGLE_TOLERANCE = 40
const WALK_FORCE = 600
const WALK_MIN_SPEED = 20
const WALK_MAX_SPEED = 500
const STOP_FORCE = 1300
const JUMP_SPEED = 700
const JUMP_MAX_AIRBORNE_TIME = 0.2

const SLIDE_STOP_VELOCITY = 1.0 # One pixel per second
const SLIDE_STOP_MIN_TRAVEL = 1.0 # One pixel

var velocity = Vector2()
var on_air_time = 100
var jumping = false

var prev_jump_pressed = false


func _fixed_process(delta):
	# Create forces
	var force = Vector2(0, GRAVITY)
	
	var walk_left = Input.is_action_pressed("move_left") or left and vivo
	var walk_right = Input.is_action_pressed("move_right") or right or fim and vivo
	var jump = Input.is_action_pressed("jump") or up and vivo
	
	var stop = true
	
	if (walk_left):
	    if (velocity.x <= WALK_MIN_SPEED and velocity.x > -WALK_MAX_SPEED):
	        force.x -= WALK_FORCE
	        stop = false
	elif (walk_right):
		if (velocity.x >= -WALK_MIN_SPEED and velocity.x < WALK_MAX_SPEED):
			force.x += WALK_FORCE
			stop = false
	
	if (stop):
		var vsign = sign(velocity.x)
		var vlen = abs(velocity.x)
		
		vlen -= STOP_FORCE*delta
		if (vlen < 0):
			vlen = 0
		
		velocity.x = vlen*vsign
	
	# Integrate forces to velocity
	velocity += force*delta
	
	# Integrate velocity into motion and move
	var motion = velocity*delta
	
	# Move and consume motion
	motion = move(motion)
	
	var floor_velocity = Vector2()
	
	if (is_colliding()):
		# You can check which tile was collision against with this
		# print(get_collider_metadata())
		
		# Ran against something, is it the floor? Get normal
		var n = get_collision_normal()
		
		if (rad2deg(acos(n.dot(Vector2(0, -1)))) < FLOOR_ANGLE_TOLERANCE):
			# If angle to the "up" vectors is < angle tolerance
			# char is on floor
			on_air_time = 0
			floor_velocity = get_collider_velocity()
		
		if (on_air_time == 0 and force.x == 0 and get_travel().length() < SLIDE_STOP_MIN_TRAVEL and abs(velocity.x) < SLIDE_STOP_VELOCITY and get_collider_velocity() == Vector2()):
			# Since this formula will always slide the character around, 
			# a special case must be considered to to stop it from moving 
			# if standing on an inclined floor. Conditions are:
			# 1) Standing on floor (on_air_time == 0)
			# 2) Did not move more than one pixel (get_travel().length() < SLIDE_STOP_MIN_TRAVEL)
			# 3) Not moving horizontally (abs(velocity.x) < SLIDE_STOP_VELOCITY)
			# 4) Collider is not moving
			
			revert_motion()
			velocity.y = 0.0
		else:
			# For every other case of motion, our motion was interrupted.
			# Try to complete the motion by "sliding" by the normal
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			# Then move again
			move(motion)
	
	if (floor_velocity != Vector2()):
		# If floor moves, move with floor
		move(floor_velocity*delta)
	
	if (jumping and velocity.y > 0):
		# If falling, no longer jumping
		jumping = false
	
	if (on_air_time < JUMP_MAX_AIRBORNE_TIME and jump and not prev_jump_pressed and not jumping):
		# Jump must also be allowed to happen if the character left the floor a little bit ago.
		# Makes controls more snappy.
		pular()
	
	on_air_time += delta
	prev_jump_pressed = jump
	
	var no_chao = rayE.is_colliding() or rayD.is_colliding()
	if walk_right:
		sprite.set_flip_h(false)
	if walk_left:
		sprite.set_flip_h(true)	
	if (walk_left or walk_right) and no_chao:
		sprite.play()	
	elif(walk_left or walk_right):
		sprite.stop()
		sprite.set_frame(3)
	else: 
		sprite.stop()
		sprite.set_frame(1)
		
	#if get_pos().y> 900:#quer dizer que saiu do mapa (tem que morrer)	
	   #morrer()


func _ready():
	set_fixed_process(true)

func _on_pes_body_enter( body ):#o body que ele recebe é o do inimigo
	if not vivo: return 
	pular()
	if body.has_method("furar"):
		body.furar()
		morrer()
	elif body.has_method("esmagar"):
		body.esmagar()
	elif body.has_method("esmagarRobot"):
		body.esmagarRobot()	
	elif body.has_method("esmagarFortran"):
		body.esmagarFortran()	
	elif body.has_method("esmagarC_alado"):
		body.esmagarC_alado()	
	elif body.has_method("esmagarAssembly"):
		body.esmagarAssembly()
	elif body.has_method("esmagarCodObj"):
		body.esmagarCodObj()
	elif body.has_method("esmagarBin"):
		body.esmagarBin()	
	elif body.has_method("esmagarAnd"):
		body.esmagarAnd()	
	elif body.has_method("esmagarNand"):
		body.esmagarNand()		
	elif body.has_method("esmagarNor"):
		body.esmagarNor()
	elif body.has_method("esmagarNot"):
		body.esmagarNot()
	elif body.has_method("esmagarOr"):
		body.esmagarOr()
	
func pular():
	velocity.y = -JUMP_SPEED
	jumping = true	


func _on_corpo_body_enter( body ):
	if not vivo: return 
	morrer()
	
func morrer():
	if not vivo: return 
	vivo = false
	velocity.y = -500
	get_node("shape").set_trigger(true)#faz o shape parar de colidir c objetos	
	#get_node("sprite").set_texture(load("res://assets/inimigo/slimeDead.png"))
	emit_signal("morreu")


func _on_cabeca_body_enter( body ):
	if not vivo: return 
	if body.has_method("destruir"):#verifica pra saber se quem ta chamando é o bloco dest e não o  tileMap
		body.destruir()


func _on_touchLeft_pressed():
	left =true
func _on_touchLeft_released():
	left = false


func _on_touchRight_pressed():
	right = true
func _on_touchRight_released():
	right = false
	
func _on_touchUp_pressed():
	up = true
func _on_touchUp_released():
	up = false


func reviver():
	velocity = Vector2(0, 0)	
	get_node("shape").set_trigger(false)#comeca em false aqui pra o personagem não cair
	get_node("camera").make_current()
	vivo = true
	fim = false


func _on_fim_body_enter( body ):#quando chegar no fim da fase
	fim = true
	emit_signal("fim")

func moeda():
	emit_signal("moeda")
	

func _on_game_time_timeout():
	morrer()



