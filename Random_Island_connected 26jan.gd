
extends TileMap

# variables for the basic map creation
var tile_count = 4000 # maximum tile count for the map
var tile_layout = 0
var tile_layout_depth = 1 # gives the amount of different tile-layouts
var map_ratio = 0
var map_width = 0
var map_height = 0
var map = {}
var map_tile_select = {}
var map_unwalkable = {}
var debug

# variable to switch through tiles
var tile_switch = 0

# map borders (will be filled with unwalkable tiles)
var width_border = 5
var height_border = 5

# variable for switching through cases
var switch_cases = 0

# variables to switch strip orientations (horizontal, vertical, diagonal)
var u = 1
var v = 1

# create random integer between minimal and maximal value (both included)
func rand_int(mini,maxi):
	return ((randi()%(maxi-mini+1))+mini)

# check the chosen tile and evaluate
func check_tile(x,y):
	# remove an already existing tile from consideration by
	# deleting it from map_tile_select
	if Vector2(x,y) in map:
		map[Vector2(x,y)] += 1
#		set_cell(x,y,5,false,false)
		if Vector2(x,y) in map_tile_select:
			map_tile_select.erase(Vector2(x,y))
	# add a new tile to the map
	else:
		map[Vector2(x,y)] = 1
		if int(x+y) % 2: # add specific tiles if line + row = odd
			tile_switch = rand_int(0,2) + tile_layout
		else: # add specific tiles if line + row = even
			tile_switch = rand_int(3,5) + tile_layout
		set_cell(x,y,tile_switch,false,false)
		# check if point is in selection boundary
		if x in range(7, (map_width - 7)):
			if y in range(7, (map_height - 7)):
				map_tile_select[Vector2(x,y)] = 1

# add a horzontal 2x8 strip to the walkable tiles
# (m,n,+1) eastward, (m,n,-1) westward
func strip_horizont(m,n,sign_m):
#	print("horizont: ",m," ",n)
	for x in range(m-3.5+sign_m*3.5,m+4.5+sign_m*3.5):
		#for y in range(n,n+2):
		check_tile(x,n)
			
# add a vertical 2x8 strip to the walkable tiles
# (m,n,+1) southward, (m,n,-1) northward
func strip_vertical(m,n,sign_n):
#	print("vertical: ",m," ",n)
	for y in range(n-3.5+sign_n*3.5,n+4.5+sign_n*3.5):
		#for x in range(m,m+2):
		check_tile(m,y)

# tri-diagonal filled 8x8 strip
# for south-east : (m,n,+1,+1)
# for south-west : (m,n,-1,+1)
# for north-west : (m,n,-1,-1)
# for north-east : (m,n,+1,-1)
func strip_diagonal(m,n,sign_m,sign_n):
#	print("++++++: ",m," ",n)
	if sign_m*sign_n < 0: # adjust start position
		m -= sign_m*7
		n -= sign_n*7
	for y in range(n-2+sign_n*2,n+3+sign_n*2):
		for x in range(m-0.5+sign_m*0.5,m+1.5+sign_m*0.5):
			check_tile(x,y)
	m += sign_m*2
	n += sign_n*5
	for steps in range(3):
		for x in range(m-0.5-sign_m*0.5,m+1.5-sign_m*0.5):
			check_tile(x,n)
		check_tile(m,n-sign_n)
		m += sign_m
		n += sign_n
	n -= sign_n
	for x in range(m-1+sign_m,m+2+sign_m):
		for y in range(n-0.5-sign_n*0.5,n+1.5-sign_n*0.5):
			check_tile(x,y)

func _ready():
	print("START")
	if 1 == 1:         #######################################
		
		randomize() # randomize seed
		
		# determine tilemap layout randomly (forest, desert, ...)
		tile_layout = (randi() % tile_layout_depth) * 14
		
		# make the map ratio something between 3:2 or 2:3 (equaly distributed)
		var b = randi() % 2 # random value between 0 and 1
		if (b > 0):
			map_ratio = rand_range(1,2)
		else:
			map_ratio = 1/rand_range(1,2)
		
		map_height = int (sqrt(tile_count/map_ratio))
		map_width = int (map_height*map_ratio)
		
		# randomly pick first walkable tile
		var m = rand_int(7, (map_width - 8))
		var n = rand_int(7, (map_height - 8))
		debug = Vector2(m,n)
		# create a 13x13 cross as first walkable tiles
		for x in range(m-7,m+8):
			check_tile(x,n)
		for y in range(n-7,n+8):
			check_tile(m,y)
		
		# fill the rest of the map as long as:
		# - the wished walkable tile amount is not reached
		# - and there are still tiles left to be chosen
		while( (map.size() < \
		((map_width)*(map_height)*1/2)) && \
		(map_tile_select.empty() == false) ):
			
			randomize()
			var pos = randi() % map_tile_select.size()
			m = map_tile_select.keys()[pos].x
			n = map_tile_select.keys()[pos].y
			if switch_cases == 0 or switch_cases == 4:
				strip_diagonal(m,n,u,v)
				v *= -1
				switch_cases += 1
			elif switch_cases == 1 or switch_cases == 5:
				strip_vertical(m,n,v)
				switch_cases += 1
			elif switch_cases == 2 or switch_cases == 6:
				strip_diagonal(m,n,u,v)
				u *= -1
				switch_cases += 1
			elif switch_cases == 3:
				strip_horizont(m,n,u)
				switch_cases += 1
			elif switch_cases == 7:
				strip_horizont(m,n,u)
				switch_cases = 0
		if 1 == 1:   #######################
			for x in range(-width_border,map_width+width_border):
				for y in range(-height_border,map_height+height_border):
					if !Vector2(x,y) in map:
						if int(x+y) % 2: # add specific tiles if line + row = odd
							tile_switch = rand_int(6,7) + tile_layout
						else: # add specific tiles if line + row = even
							tile_switch = rand_int(8,9) + tile_layout
						set_cell(x,y,tile_switch,false,false)
						map_unwalkable[Vector2(x,y)] = tile_switch
#						debug = "debug: "+str(x)+"   "+str(y)
#			print(debug)
#			for x in range(0,map_width):
#				for y in range(0,map_height):
#					set_cell(x,y,5,false,false)
#					debug = "debug: "+str(x)+"   "+str(y)
#			print(debug)
#			for x in range(7, (map_width - 7)):
#				for y in range(7, (map_height - 7)):
#					set_cell(x,y,4,false,false)
#					debug = "debug: "+str(x)+"   "+str(y)
#			print(debug)
		
		if 1 == 0:
			print("map size: ", map.size())
			print("b: ",b)
			print("map ratio: " , map_ratio)
			print("width: ",map_width)
			print("height: ", map_height)
			print("map: ", map)
#			print("\n test: ",map_total)
#	strip_vertical(0,0,1)
#	strip_vertical(0,0,-1)
#	strip_horizont(0,0,1)
#	strip_horizont(0,0,-1)
	print(rand_int(1,3))
	pass
