
extends TileMap

# size of the strip dimensions per tilecount
# variable has a short name for easier (multiple) usage in the code
# needs to be of type float (add .0)
var t = 3.0

# variables for the basic map creation
var tile_count = 1000 # maximum tile count for the map
var tile_layout = 0
var tile_layout_depth = 1 # gives the amount of different tile-layouts
var map = {}
var map_tile_select = {}
var map_unwalkable = {}
var start_gate = Vector2()
var start_pos = Vector2()
var fog_rect = Rect2()

# variable to switch through tiles
var tile_switch = 0

# map border (will be filled with unwalkable tiles)
var x_max = t
var x_min = -t
var y_max = t
var y_min = -t

# variable for switching through cases
var switch_cases = 2

# variables to switch strip orientations (horizontal, vertical, diagonal)
var m = 0
var n = 0
var u = 1
var v = 1
var random = [-1,1]

# create random integer between minimal and maximal value (both included)
func rand_int(mini,maxi):
	return ((randi()%int(maxi-mini+1))+int(mini))

# check the chosen tile and fill with walkable terrain
func check_tile(x,y):
	# remove an already existing tile from consideration by
	# deleting it from map_tile_select
	if !Vector2(x,y) in map:
		map[Vector2(x,y)] = 1
		if int(x+y) % 2: # add specific tiles if line + row = odd
			tile_switch = rand_int(0,2) + tile_layout
		else: # add specific tiles if line + row = even
			tile_switch = rand_int(3,5) + tile_layout
		set_cell(x,y,tile_switch,false,false)
				

# add tile to collection of choosable generation-starters
func set_starter(x,y,direction):
	map_tile_select[Vector2(x,y)] = direction

# check and add map border values
func check_border(x,y):
	for x1 in x:
		if x1 > x_max:
			x_max = x1
		if x1 < x_min:
			x_min = x1
	for y1 in y:
		if y1 > y_max:
			y_max = y1
		if y1 < y_min:
			y_min = y1

# add a horzontal 2x8 strip to the walkable tiles
# (m,n,+1) eastward, (m,n,-1) westward
func strip_horizont(m,n,sign_m):
	set_starter(m+sign_m*t,n,[sign_m,0])
	check_border([m+sign_m*t],[n-1,n+1])
	for y in range(n-1,n+2):
		for x in range(m-t/2+sign_m*t/2,m+t/2+sign_m*t/2+1):
			check_tile(x,y)
			
# add a vertical 2x8 strip to the walkable tiles
# (m,n,+1) southward, (m,n,-1) northward
func strip_vertical(m,n,sign_n):
	set_starter(m,n+sign_n*t,[0,sign_n])
	check_border([m-1,m+1],[n+sign_n*t])
	for x in range(m-1,m+2):
		for y in range(n-t/2+sign_n*t/2,n+t/2+sign_n*t/2+1):
			check_tile(x,y)

# tri-diagonal filled 8x8 strip
# for south-east : (m,n,+1,+1)
# for south-west : (m,n,-1,+1)
# for north-west : (m,n,-1,-1)
# for north-east : (m,n,+1,-1)
func strip_diagonal(m,n,sign_m,sign_n):
#	set_starter(m+sign_m*6,n+sign_n*6,[sign_m,sign_n])
	set_starter(m+sign_m*t,n+sign_n*t,[sign_m,sign_n])
	check_border([m+sign_m*t],[n+sign_n*t])
	for x in range(m-1+sign_m,m+2+sign_m):
		for y in range(n-1+sign_n,n+2+sign_n):
			check_tile(x,y)
	m += sign_m*3
	n += sign_n*3
	for steps in range(t-2):
		for x in range(m-1-sign_m,m+2-sign_m):
			check_tile(x,n)
		for y in range(n-1-sign_n,n+2-sign_n):
			check_tile(m,y)
		m += sign_m
		n += sign_n

####################################################################
####################################################################
####						PROGRAM START						####
####################################################################
####################################################################

func _ready():
	var swit=1
	if 1 == swit:         #######################################
		print("start")
		randomize() # randomize seed
		
		# determine tilemap layout randomly (forest, desert, ...)
		tile_layout = (randi() % tile_layout_depth) * 14
		start_gate = Vector2(m,n)
		# create a 13x13 cross as first walkable tiles
		for x in range(m-t,m+t+1):
			for y in range(n-1,n+2):
				check_tile(x,y)
		set_starter(m-t,n,[-1,0])
		set_starter(m+t,n,[1,0])
		for x in range(m-1,m+2):
			for y in range(n-t,n+t+1):
				check_tile(x,y)
		set_starter(m,n-t,[0,-1])
		set_starter(m,n+t,[0,1])
		# fill the rest of the map as long as:
		# - the wished walkable tile amount is not reached
		# - and there are still tiles left to be chosen
		while( (map.size() < tile_count) && \
		(map_tile_select.empty() == false) ):
			
			t = float(rand_int(3,5))
			var pos = randi() % map_tile_select.size()

			m = map_tile_select.keys()[pos].x
			n = map_tile_select.keys()[pos].y
			
			if (map_tile_select[Vector2(m,n)][0] == 0) or \
			(map_tile_select[Vector2(m,n)][1] == 0):
				if map_tile_select[Vector2(m,n)][0] == 0:
					u = random[(randi()%2)]
					v = map_tile_select[Vector2(m,n)][1]
				else:
					u = map_tile_select[Vector2(m,n)][0]
					v = random[(randi()%2)]
			else:
				var choose_direct = randi() % 3
				if choose_direct == 0:
					u = -map_tile_select[Vector2(m,n)][0]
					v = map_tile_select[Vector2(m,n)][1]
				elif choose_direct == 1:
					u = map_tile_select[Vector2(m,n)][0]
					v = -map_tile_select[Vector2(m,n)][1]
				elif choose_direct == 2:
					u = -map_tile_select[Vector2(m,n)][0]
					v = -map_tile_select[Vector2(m,n)][1]

			
			
			map_tile_select.erase(Vector2(m,n))
			if switch_cases == 0:
				strip_diagonal(m,n,u,v)
			elif switch_cases == 1:
				strip_vertical(m,n,v)
			elif switch_cases == 2:
				strip_horizont(m,n,u)
				
			if switch_cases < 2:
				switch_cases += 1
			else:
				switch_cases = 0
				
		start_pos = Vector2(m,n)
		x_max += 2
		y_max += 2
		x_min -= 1
		y_min -= 2
		if 1 == 1:   #######################
			for x in range(x_min,x_max):
				for y in range(y_min,y_max):
					if !Vector2(x,y) in map:
						if int(x+y) % 2: # add specific tiles if line + row = odd
							tile_switch = 6 + tile_layout
						else: # add specific tiles if line + row = even
							tile_switch = 7 + tile_layout
						set_cell(x,y,tile_switch,false,false)
						map_unwalkable[Vector2(x,y)] = tile_switch

		print(map_tile_select)

	if 0 == swit:
		strip_vertical(20,20,1)
		strip_vertical(20,20,-1)
		strip_horizont(20,20,1)
		strip_horizont(20,20,-1)
		strip_diagonal(20,20,-1,-1)
		strip_diagonal(20,20,1,-1)
		strip_diagonal(20,20,-1,1)
		strip_diagonal(20,20,1,1)
		
		start_pos=Vector2(20,20)
		for the_key in map_tile_select.keys():
			set_cell(the_key.x,the_key.y,6,0,0)
	print("le map tile select: ",map_tile_select)
	print(x_max-x_min," ",y_max-y_min)
	fog_rect = Rect2(x_min*48,y_min*48,(x_max-x_min)*48,(y_max-y_min)*48)
	pass
