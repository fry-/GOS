
extends KinematicBody2D

# This is a simple collision demo showing how
# the kinematic cotroller works.
# move() will allow to move the node, and will
# always move it to a non-colliding spot, 
# as long as it starts from a non-colliding spot too.


#pixels / second
const MOTION_SPEED=300
const step = 1
var new_anim = ""
var anim = "front_idle"
var old_motion = Vector2()

func _fixed_process(delta):
	var motion = Vector2()
	
	if (Input.is_action_pressed("move_up")):
		motion+=Vector2(0,-step)
	if (Input.is_action_pressed("move_bottom")):
		motion+=Vector2(0,step)
	if (Input.is_action_pressed("move_left")):
		motion+=Vector2(-step,0)
	if (Input.is_action_pressed("move_right")):
		motion+=Vector2(step,0)
		
	motion = motion.normalized() * MOTION_SPEED * delta
	move(motion)
	
	var slide_attempts = 2
	while(is_colliding() and slide_attempts>0):
		motion = get_collision_normal().slide(motion)
		move(motion)
		slide_attempts -= 1
	
	if old_motion != motion:
		if (motion==Vector2(0,0)):
			new_anim += "_idle"
		elif abs(motion.x) > 0:
			get_node("Sprite").set_flip_h(motion.x>0)
			new_anim = "side"
		elif motion.y < 0:
			new_anim = "back"
		elif motion.y > 0:
			new_anim = "front"
	
	
	old_motion = motion
	
	if (new_anim!=anim):
		anim = new_anim
		get_node("animat").play(anim)
	
func _ready():
	var x_min = get_node("../base").x_min
	var x_max = get_node("../base").x_max
	var y_min = get_node("../base").y_min
	var y_max = get_node("../base").y_max
	get_node("Camera2D").set_limit(0,(x_min) *48)
	get_node("Camera2D").set_limit(1,(y_min) *48)
	get_node("Camera2D").set_limit(2,(x_max) *48)
	get_node("Camera2D").set_limit(3,(y_max-1) *48)
	
	print("player")
	get_node("animat").play(anim)
	var position = get_node("../base").start_pos * 48 + Vector2(24,24)
	set_pos(position)
	set_fixed_process(true)
	pass

