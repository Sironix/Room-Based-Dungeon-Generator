extends Resource
class_name Room

#here I reccommend adding some sort of thing to link this abstract room to one of your room scenes.
#probably an id or path, not a preload itself, make the generator light because it isn't optimized at all.

#also more things can be added to be used with filters. 
@export var shape :Array[Room_Part]=[]
@export var color :Color
