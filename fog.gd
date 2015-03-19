
extends TileMap

# member variables here, example:
# var a=2
# var b="textvar"
var x_min
var x_max
var y_min
var y_max
var position
var x = 0
var y = 0
var x_old
var y_old
var l = range(1,4)

func _fixed_process(delta):
	position = get_node("../troll").get_pos()
	
	x = int(position.x/48)
	if position.x < 0:
		x -= 1
	
	y = int(position.y/48)
	if position.y < 0:
		y -= 1
		
	if (x_old != x) or (y_old != y):
		var end = l.size()-1
		var start = 0
		for steps in range(l.size()):
			for m in range(x-l[end],x+l[end]+1):
				for n in range(y-l[start],y+l[start]+1):
					if (m<x_max) and (m>x_min-1):
						if (n<y_max-1) and (n>y_min-1):
							set_cell(m,n,-1)
			end -= 1
			start += 1
	
	x_old = x
	y_old = y
	
	pass

func _ready():
	# Initalization here
	x_min = get_node("../base").x_min
	x_max = get_node("../base").x_max
	y_min = get_node("../base").y_min
	y_max = get_node("../base").y_max
	for x in range(x_min-1,x_max+2):
		for y in range(y_min-1,y_max+2):
			set_cell(x,y,0,0,0)
	set_fixed_process(true)
	pass


