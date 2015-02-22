
extends TileMap

# member variables here, example:
# var a=2
# var b="textvar"

var tile_count = 1000 # maximum tile count for the map
var map_ratio = 0
var map_width = 0
var map_height = 0
var map = {}
var map_tile_select = {}

# map borders (will be filled with unwalkable tiles)
var width_border = 0
var height_border = 0

# variable for switching through cases
var switch_cases = 0

# variables to switch strip orientations (horizontal, vertical, diagonal)
var u = 1
var v = 1
var a = 0

# create random integer between minimal and maximal value
func rand_int(mini,maxi):
	return ((randi()%(maxi-mini+1))+mini)

# check the chosen tile and evaluate
func check_tile(x,y):
	# remove an already existing tile from consideration
	if Vector2(x,y) in map: 
		map[Vector2(x,y)] += 1 
		if Vector2(x,y) in map_tile_select:
			map_tile_select.erase(Vector2(x,y))
	# add a new tile to the map
	else:
		map[Vector2(x,y)] = 1
		randomize()
		set_cell(x,y,randi()%7,randi()%2,false)
		# check if point is in selection boundary
		if x in range((width_border+7), (map_width - width_border-7)):
			if y in range((height_border+7), (map_height - height_border-7)):
				map_tile_select[Vector2(x,y)] = 1

# add a horzontal 1x8 strip to the walkable tiles
# (m,n,+1) eastward, (m,n,-1) westward
func strip_horizont(m,n,sign_m):
	for x in range(m-3.5+sign_m*3.5,m+4.5+sign_m*3.5):
		check_tile(x,n)
			
# add a vertical 1x8 strip to the walkable tiles
# (m,n,+1) southward, (m,n,-1) northward
func strip_vertical(m,n,sign_n):
	for y in range(n-3.5+sign_n*3.5,n+4.5+sign_n*3.5):
		check_tile(m,y)

# tri-diagonal filled 8x8 strip
# for south-east : (m,n,+1,+1)
# for south-west : (m,n,-1,+1)
# for north-west : (m,n,-1,-1)
# for north-east : (m,n,+1,-1)
func strip_diagonal(m,n,sign_m,sign_n):
	if sign_m*sign_n < 0:
		m += sign_m*7
		n += sign_n*7
	for y in range(n-1.5+sign_n*1.5,n+2.5+sign_n*1.5):
		check_tile(m,y)
	m += sign_m
	n += sign_n*4
	for steps in range(4):
		for x in range(m-0.5-sign_m*0.5,m+1.5-sign_m*0.5):
			check_tile(x,n)
		for y in range(n-0.5-sign_n*0.5,n+1.5-sign_n*0.5):
			check_tile(m,y)
		m += sign_m
		n += sign_n
	n -= sign_n
	for x in range(m-1+sign_m,m+2+sign_m):
		check_tile(x,n)

func _ready():
	
	# make the map ratio something between 3:2 or 2:3 (equaly distributed)
	
	a = randomize() # randomize seed
	var b = randi() % 2 # random value between 0 and 1
	if (b > 0):
		map_ratio = rand_range(1,2)
	else:
		map_ratio = 1/rand_range(1,2)

	map_height = int (sqrt(tile_count/map_ratio))
	map_width = int (map_height*map_ratio)
	
	# randomly pick first walkable tile
	var m = rand_int((width_border+7), (map_width - width_border-7))
	var n = rand_int((height_border+7), (map_height - height_border-7))

	# create a 13x13 cross as first walkable tiles
	for x in range(m-7,m+8):
		check_tile(x,n)
	for y in range(n-7,n+8):
		check_tile(m,y)
	
	# fill the rest of the map as long as the wished walkable tile amount is not reached
	# and there are still tiles left to be chosen
	while( (map.size() < \
	((map_width-2*width_border-2)*(map_height-2*height_border-2))*1/2) && \
	(map_tile_select.empty() == 0) ):
		
		a = randomize()
		var pos = randi() % map_tile_select.size()
		m = Vector2(map_tile_select.keys()[pos]).x
		n = Vector2(map_tile_select.keys()[pos]).y
		
		print("map size ",map.size())
		print("max_tiles ", ((map_width-2*width_border-2)*(map_height-2*height_border-2))*1/2)
		
		if switch_cases == 0 || switch_cases == 4:
			strip_diagonal(m,n,u,v)
			v *= -1
			switch_cases += 1
		elif switch_cases == 1 || switch_cases == 5:
			strip_vertical(m,n,v)
			switch_cases += 1
		elif switch_cases == 2 || switch_cases == 6:
			strip_diagonal(m,n,u,v)
			u *= -1
			switch_cases += 1
		elif switch_cases == 3:
			strip_horizont(m,n,u)
			switch_cases += 1
		elif switch_cases == 7:
			strip_horizont(m,n,u)
			switch_cases = 0
	
	print("map size: ", map.size())
	print("b: ",b)
	print("map ratio: " , map_ratio)
	print("height: ", map_height)
	print("width: ",map_width)
	print("map: ", map)
	
	pass
