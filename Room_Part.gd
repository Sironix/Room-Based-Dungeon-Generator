extends Resource
class_name Room_Part

### this class shouldn't be used by itself, but created inside Room export variables.

#here you can define different types of doors prolly only special rooms should have special doors.
#like how curse rooms in isaac have the spikes, and they add those spike doors to the neighbour rooms when they get connected.

#another example, only hidden rooms should have hidden doors, then the game checks for rooms with possible doors to connect to it
#and instead of the game adding normal doors to those rooms, it adds bombable walls.
enum DOOR_TYPE{NO_DOOR=0,POSSIBLE=1,YES=2,HIDDEN =3,SPECIAL =4}

@export var part_place:Vector2i
@export var door_up :DOOR_TYPE =DOOR_TYPE.NO_DOOR
@export var door_down :DOOR_TYPE =DOOR_TYPE.NO_DOOR
@export var door_left :DOOR_TYPE =DOOR_TYPE.NO_DOOR
@export var door_right :DOOR_TYPE =DOOR_TYPE.NO_DOOR
