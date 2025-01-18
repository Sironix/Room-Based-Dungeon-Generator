extends Control
var current_room_parts :int = 0
#amount of room_parts you want to create.
var map_max_room_parts :int = 50

#size of the map, it will be map_size unit talls and wide.
#please make it even, due to calculations.
var map_size : int = 10

#this array holds all the added rooms to the map for quick reference.
var list_of_rooms :Array[Room] = []

#this array is the full map, a single array for a room_part that could be in map.
#empty spaces are 0, numbers are the rooms, multiple grids with the same number mean that those room_parts are part of a single room
var map_grid :Array[Array] = create_grid(map_size)

#all the avaliable rooms, probably it exists a better way to do this.
const ROOMS_TO_USE :Array[Room]=[preload("res://Rooms/x_room.tres"),preload("res://Rooms/complex_room.tres"),preload("res://Rooms/x_room.tres"),
preload("res://Rooms/hallway_h.tres"),preload("res://Rooms/hallway_v.tres"),preload("res://Rooms/complex_room2.tres"),preload("res://Rooms/cross_road.tres") ]


func _ready() -> void:
	generate_map()
	var console_map = show_map_in_console()
	update_visual_grid()


func generate_map():
	#reference to the latest spawned room
	var last_room :Room
	
	
	var starting_room :Room
	#creation of the starting room
	
	if current_room_parts == 0:
		starting_room =generate_random_starting_room()
		current_room_parts += starting_room.shape.size()
		list_of_rooms.append(starting_room)
		for room_part in starting_room.shape:
			map_grid[room_part.part_place.x+map_size / 2][room_part.part_place.y+map_size / 2]= room_part
		last_room = starting_room.duplicate()
	
	#used to avoid infinite loops.
	var early_finish :int = 0
	var big_finish :int = 0
	#creates a single path of rooms but it can be interconnected when rooms generate next to each other.
	#how much of the max amount of rooms you want to use for the initial path. the rest will be used in random mini paths.
	var percentage_of_max_rooms :float = 0.5
	var amount_of_rooms_for_main_path :int = (map_max_room_parts * percentage_of_max_rooms) - current_room_parts
	var total_amount_of_room_parts :int = 0
	while total_amount_of_room_parts < map_max_room_parts and big_finish  <=  150:
		early_finish = 0
		last_room = starting_room.duplicate()
		current_room_parts = 0
		while current_room_parts < amount_of_rooms_for_main_path and early_finish  <=  50:
			var random_room = generate_room_based_on_this_room(last_room)
			if random_room:
				#if room creation went well.
				last_room = random_room.duplicate()
			else:
				early_finish +=1
				big_finish +=1
				total_amount_of_room_parts = current_room_parts
		big_finish+=1

#generates a room that can fit next to the room in the argument.
func generate_room_based_on_this_room(room:Room) -> Room:
	#selecting a random room_part of the room.
	var _room_part :Room_Part = room.shape.pick_random()
	
	
	var _selected_door :String =""
	var _avaliable_doors : Array=[]
	#adds avaliable door from the room_part to the array to select on at random.
	if _room_part.door_down == Room_Part.DOOR_TYPE.POSSIBLE:
		_avaliable_doors.append("door_down")
		
	if _room_part.door_right == Room_Part.DOOR_TYPE.POSSIBLE:
		_avaliable_doors.append("door_right")
		
	if _room_part.door_left == Room_Part.DOOR_TYPE.POSSIBLE:
		_avaliable_doors.append("door_left")
		
	if _room_part.door_up == Room_Part.DOOR_TYPE.POSSIBLE:
		_avaliable_doors.append("door_up")
	
	#if any door is avalieable then pick a random door.
	if _avaliable_doors.size():
		_selected_door = _avaliable_doors.pick_random()
	else:
		printerr("Room has no avaliable doors, should atleast have 2")
	
	#setting the position of the selected room_part.
	var _position:Vector2i = _room_part.part_place
	randomize()
	
	var filter = {}
	if _selected_door=="door_up":
		filter ={"door_down":true}
	elif _selected_door == "door_down":
		filter ={"door_up":true}
	elif _selected_door == "door_right":
		filter ={"door_left":true}
	elif _selected_door == "door_left":
		filter ={"door_right":true}

	var random_room : Room =generate_filtered_room(filter)
	#trying to put the room's first part_place next to the previously selected door.
	match _selected_door:
		"door_up":
			print("going up")
			for room_part in random_room.shape:
				#we have to duplicate the room_part, otherwise it affects all instances of the room.
				room_part.part_place =room_part.duplicate(true).part_place + Vector2i(0,-1) + _position
				if not is_in_grid(room_part):
					return null
				map_grid[room_part.part_place.y+map_size / 2][room_part.part_place.x+map_size / 2 ]= room_part
		"door_down":
			print("going down")
			for room_part in random_room.shape:
				room_part.part_place =room_part.duplicate(true).part_place + Vector2i(0,1) + _position
				if not is_in_grid(room_part):
					return null
				map_grid[room_part.part_place.y+map_size / 2][room_part.part_place.x+map_size / 2 ]= room_part
		"door_left":
			print("going left")
			for room_part in random_room.shape:
				room_part.part_place =room_part.duplicate(true).part_place + Vector2i(-1,0) + _position
				if not is_in_grid(room_part):
					return null
				map_grid[room_part.part_place.y+map_size / 2][room_part.part_place.x+map_size / 2 ]= room_part
		"door_right":
			print("going right")
			for room_part in random_room.shape:
				room_part.part_place =room_part.duplicate(true).part_place + Vector2i(1,0) + _position
				if not is_in_grid(room_part):
					return null
				print(room_part.part_place)
				map_grid[room_part.part_place.y+map_size / 2][room_part.part_place.x+map_size / 2 ]= room_part
	
	#checking if all places in which the room wants to be in are avalliable.
	if is_space_avaliable(random_room):
		current_room_parts +=random_room.shape.size()
		print_room_info(random_room)
		list_of_rooms.append(random_room)
		#changes possible doors to yes.
		check_neighbour_rooms(random_room)
		return random_room
	return null

func generate_random_starting_room() -> Room:
	var room : Room = Room.new()
	var selected_room = load("res://Rooms/cross_road.tres")
	room.color = selected_room.color
	for room_part in selected_room.shape:
		room.shape.append(room_part.duplicate())
	return room

func generate_truly_random_room() -> Room:
	var room : Room = Room.new()
	var selected_room = ROOMS_TO_USE.pick_random().duplicate()
	room.color = selected_room.color
	for room_part in selected_room.shape:
		room.shape.append(room_part.duplicate())
	return room

func generate_filtered_room(filter:Dictionary):
	var list_of_filtered_rooms :Array = []
	for _room in ROOMS_TO_USE:
		if filter.has("size"):
			if _room.shape.size() != filter.size:
				continue
		if filter.has("door_up"):
			if _room.shape[0].door_up != Room_Part.DOOR_TYPE.POSSIBLE:
				continue
		if filter.has("door_down"):
			if _room.shape[0].door_down != Room_Part.DOOR_TYPE.POSSIBLE:
				continue
		if filter.has("door_left"):
			if _room.shape[0].door_left != Room_Part.DOOR_TYPE.POSSIBLE:
				continue
		if filter.has("door_right"):
			if _room.shape[0].door_right != Room_Part.DOOR_TYPE.POSSIBLE:
				continue
		list_of_filtered_rooms.append(_room)
	
	#same code as generate random room.
	var room : Room = Room.new()
	if list_of_filtered_rooms.size() == 0:
		printerr("there are no rooms with this filter")
	
	var selected_room = list_of_filtered_rooms.pick_random().duplicate()
	room.color = selected_room.color
	for room_part in selected_room.shape:
		room.shape.append(room_part.duplicate())
	return room



func is_in_grid(room_part,_use_position=false) -> bool:
	if _use_position == false:
		if room_part.part_place.y     >=5:
			return false
		elif room_part.part_place.x   >=5:
			return false
		elif room_part.part_place.x   <=-5:
			return false
		elif room_part.part_place.y   <=-5:
			return false
		return true
	else:
		#when passing a vector2i, instead of room_part
		if room_part.y     >=5:
			return false
		elif room_part.x   >=5:
			return false
		elif room_part.x   <=-6:
			return false
		elif room_part.y   <=-6:
			return false
		return true

func is_space_avaliable(comparing_room:Room):
	for room in list_of_rooms:
		for room_part in room.shape:
			for comparing_room_part in comparing_room.shape:
				if room_part.part_place == comparing_room_part.part_place:
					print("room tried to spawn on ocuppied space, retrying")
					return false
	return true

#func is_room_connectable_to_neighbours(comparing_room:Room):
	#for comparing_room_part in comparing_room.shape:
		#if comparing_room_part.door_right == Room_Part.DOOR_TYPE.POSSIBLE:
			#if list_of_rooms.

func show_map_in_console():
	print("printing map.")
	var map = create_grid()
	var rooms = 0
	for room in list_of_rooms:
		rooms +=1
		for room_part in room.shape:
			var pos :Vector2i = room_part.part_place
			map[pos.y+map_size / 2][pos.x+map_size / 2] = [str(" ",rooms," ")]
	for i in map:
		print(i)
	return map

func create_grid(size:int=10):
	var grid :Array[Array] =[]
	for i in range(size):
		grid.append([])
		for k in range(size):
			grid[i].append([" 0 "])
	return grid

func print_room_info(room:Room):
	for room_part in room.shape:
		var text :String = str(room_part.part_place)
		if room_part.door_up or room_part.door_down or room_part.door_left or room_part.door_right:
			text += " door "
			if room_part.door_up:
				text += "up "
			if room_part.door_down:
				text += "down "
			if room_part.door_left:
				text += "left "
			if room_part.door_right:
				text += "right "
		print(text)



func check_neighbour_rooms(room:Room):
	for room_part in room.shape:
		if room_part.door_down == Room_Part.DOOR_TYPE.POSSIBLE:
			#gotta get the reference to the room_part thats below this one.
			var room_part_ref = get_room_part_reference(room_part.part_place + Vector2i(0,1))
			if room_part_ref:
				if room_part_ref.door_up == Room_Part.DOOR_TYPE.POSSIBLE:
					room_part_ref.door_up = Room_Part.DOOR_TYPE.YES
					room_part.door_down = Room_Part.DOOR_TYPE.YES
					
				if room_part_ref.door_up == Room_Part.DOOR_TYPE.NO_DOOR:
					room_part_ref.door_up = Room_Part.DOOR_TYPE.NO_DOOR
					room_part.door_down = Room_Part.DOOR_TYPE.NO_DOOR
					
		if room_part.door_up == Room_Part.DOOR_TYPE.POSSIBLE:
			var room_part_ref = get_room_part_reference(room_part.part_place + Vector2i(0,-1))
			if room_part_ref:
				if room_part_ref.door_down == Room_Part.DOOR_TYPE.POSSIBLE:
					room_part_ref.door_down = Room_Part.DOOR_TYPE.YES
					room_part.door_up = Room_Part.DOOR_TYPE.YES
					
				if room_part_ref.door_down == Room_Part.DOOR_TYPE.NO_DOOR:
					room_part_ref.door_down = Room_Part.DOOR_TYPE.NO_DOOR
					room_part.door_up = Room_Part.DOOR_TYPE.NO_DOOR
					
		if room_part.door_right == Room_Part.DOOR_TYPE.POSSIBLE:
			var room_part_ref = get_room_part_reference(room_part.part_place + Vector2i(1,0))
			if room_part_ref:
				if room_part_ref.door_left == Room_Part.DOOR_TYPE.POSSIBLE:
					room_part_ref.door_left = Room_Part.DOOR_TYPE.YES
					room_part.door_right = Room_Part.DOOR_TYPE.YES
					
				if room_part_ref.door_left == Room_Part.DOOR_TYPE.NO_DOOR:
					room_part_ref.door_left = Room_Part.DOOR_TYPE.NO_DOOR
					room_part.door_right = Room_Part.DOOR_TYPE.NO_DOOR
				
		if room_part.door_left == Room_Part.DOOR_TYPE.POSSIBLE:
			var room_part_ref = get_room_part_reference(room_part.part_place + Vector2i(-1,0))
			if room_part_ref:
				if room_part_ref.door_right == Room_Part.DOOR_TYPE.POSSIBLE:
					room_part_ref.door_right = Room_Part.DOOR_TYPE.YES
					room_part.door_left = Room_Part.DOOR_TYPE.YES
					
				if room_part_ref.door_right == Room_Part.DOOR_TYPE.NO_DOOR:
					room_part_ref.door_right = Room_Part.DOOR_TYPE.NO_DOOR
					room_part.door_left = Room_Part.DOOR_TYPE.NO_DOOR

func get_room_part_reference(_position :Vector2i) -> Room_Part:
	if not is_in_grid(_position,true):
		return null
	for room in list_of_rooms:
		for room_part in room.shape:
			if room_part.part_place == _position:
				return room_part
	return null
	
func update_visual_grid():
	for room in list_of_rooms:
		for room_part in room.shape:
			var pos :Vector2i = room_part.part_place
			var node :Control =$VBoxContainer.get_child(pos.y +map_size/2).get_child(pos.x + map_size/2)
			node.get_child(1).visible = true
			node.get_child(1).color = room.color
			match room_part.door_up:
				Room_Part.DOOR_TYPE.YES:
					node.get_child(2).visible = true
			
				Room_Part.DOOR_TYPE.POSSIBLE:
					node.get_child(2).color = Color(Color.DIM_GRAY)
					node.get_child(2).visible = true
			
			match room_part.door_down:
				Room_Part.DOOR_TYPE.YES:
					node.get_child(3).visible = true
			
				Room_Part.DOOR_TYPE.POSSIBLE:
					node.get_child(3).color = Color(Color.DIM_GRAY)
					node.get_child(3).visible = true
			
			match room_part.door_right:
				Room_Part.DOOR_TYPE.YES:
					node.get_child(4).visible = true
			
				Room_Part.DOOR_TYPE.POSSIBLE:
					node.get_child(4).color = Color(Color.DIM_GRAY)
					node.get_child(4).visible = true
					
			match room_part.door_left:
				Room_Part.DOOR_TYPE.YES:
					node.get_child(5).visible = true
			
				Room_Part.DOOR_TYPE.POSSIBLE:
					node.get_child(5).color = Color(Color.DIM_GRAY)
					node.get_child(5).visible = true
			
