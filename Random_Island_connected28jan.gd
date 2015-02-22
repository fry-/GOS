
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
var start_pos = Vector2()

# variable to switch through tiles
var tile_switch = 0

# map border (will be filled with unwalkable tiles)
var width_border = 5
var height_border = 5

# variable for switching through cases
var switch_cases = 0

# variables to switch strip orientations (horizontal, vertical, diagonal)
var u = 1
var v = 1

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
	print("set_starter")
	if (x > 7) and (x < map_width - 7):
		print("start x")
		if (y > 7) and (y < map_height - 7):
			map_tile_select[Vector2(x,y)] = direction
			print("mts: ",map_tile_select)
				
				
# add a horzontal 2x8 strip to the walkable tiles
# (m,n,+1) eastward, (m,n,-1) westward
func strip_horizont(m,n,sign_m):
	set_starter(m+sign_m*7,n)
	for y in range(n-1,n+2):
		for x in range(m-3.5+sign_m*3.5,m+4.5+sign_m*3.5):
			check_tile(x,y)
	
	print("hori_set: ",m+sign_m*7," ",n)
			
# add a vertical 2x8 strip to the walkable tiles
# (m,n,+1) southward, (m,n,-1) northward
func strip_vertical(m,n,sign_n):
	set_starter(m,n+sign_n*7)
	for x in range(m-1,m+2):
		for y in range(n-3.5+sign_n*3.5,n+4.5+sign_n*3.5):
			check_tile(x,y)
	print("verti_set: ",m," ",n+sign_n*7)

# tri-diagonal filled 8x8 strip
# for south-east : (m,n,+1,+1)
# for south-west : (m,n,-1,+1)
# for north-west : (m,n,-1,-1)
# for north-east : (m,n,+1,-1)
func strip_diagonal(m,n,sign_m,sign_n):
	set_starter(m+sign_m*6,n+sign_n*6)
	set_starter(m+sign_m*7,n+sign_n*7)
	for x in range(m-1+sign_m,m+2+sign_m):
		for y in range(n-1+sign_n,n+2+sign_n):
			check_tile(x,y)
	m += sign_m*3
	n += sign_n*3
	for steps in range(5):
		for x in range(m-1-sign_m,m+2-sign_m):
			check_tile(x,n)
		for y in range(n-1-sign_n,n+2-sign_n):
			check_tile(m,y)
		m += sign_m
		n += sign_n

func _ready():
	if 1 == 0:         #######################################
		print("start")
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
		
		print("Map",map_width," ",map_height)
		# randomly pick first walkable tile
		var m = rand_int(7, (map_width - 8))
		var n = rand_int(7, (map_height - 8))
		start_pos = Vector2(m,n)
		# create a 13x13 cross as first walkable tiles
		for x in range(m-7,m+8):
			check_tile(x,n)
		set_starter(m-7,n)
		set_starter(m+7,n)
		for y in range(n-7,n+8):
			check_tile(m,y)
		set_starter(m,n-7)
		set_starter(m,n+7)
		# fill the rest of the map as long as:
		# - the wished walkable tile amount is not reached
		# - and there are still tiles left to be chosen
		while( (map.size() < \
		(map_width*map_height/4)) && \
		(map_tile_select.empty() == false) ):
			
			randomize()
			var pos = randi() % map_tile_select.size()
			m = map_tile_select.keys()[pos].x
			n = map_tile_select.keys()[pos].y
			print("m: ",m," n: ",n)
			map_tile_select.erase(Vector2(m,n))
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
		start_pos = Vector2(m,n)
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
#						start_pos = "start_pos: "+str(x)+"   "+str(y)
#			print(start_pos)
#			for x in range(0,map_width):
#				for y in range(0,map_height):
#					set_cell(x,y,5,false,false)
#					start_pos = "start_pos: "+str(x)+"   "+str(y)
#			print(start_pos)
#			for x in range(7, (map_width - 7)):
#				for y in range(7, (map_height - 7)):
#					set_cell(x,y,4,false,false)
#					start_pos = "start_pos: "+str(x)+"   "+str(y)
#			print(start_pos)
		print(map_tile_select)
		if 1 == 0:
			print("map size: ", map.size())
			print("b: ",b)
			print("map ratio: " , map_ratio)
			print("width: ",map_width)
			print("height: ", map_height)
			print("map: ", map)
#			print("\n test: ",map_total)
	if 1 == 1:
		map_width = 1000
		map_height = 1000
		strip_vertical(20,20,1)
		strip_vertical(20,20,-1)
		strip_horizont(20,20,1)
		strip_horizont(20,20,-1)
		strip_diagonal(20,20,-1,-1)
		start_pos=Vector2(20,20)
		for the_key in map_tile_select.keys():
			set_cell(the_key.x,the_key.y,6,0,0)
	print("le map tile select: ",map_tile_select)
	pass
