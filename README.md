# Room Based Dungeon Generator
 Uses rooms created by the user, to create a randomly generated dungeon, with rules and checks for door coonections. rooms can have an id to link to a real room scene, to create the real dungeon, this is just an abstraction that lets you do the generation of the dungeon itself
 
This was done in godot 4.3 just in case.

Instructions.

![image](https://github.com/user-attachments/assets/7dd2d354-6bc2-4d97-a80f-73bac8800f54)

create a new resource Room, in it create the room_parts you want.
part_place is the position from 0,0 that this room_part is going to be,
Vector2i(0,0) should be reserved for the first room_part of the room.

For example, want a room that is 3 tiles wide?
create a room with 3 room_parts
part 1 position would be Vector2i(0,0)
the second one would be Vector2i(1,0)
and the third one would be Vector2i(2,0)

you would end up with a room which the start is 0,0 and then has two spaces more to the right,

you could also make the second and third room_part go left, or one to each side.



same thing with square shaped rooms or even weirder forms.

for the door types of each room_part, only change them to "Possible" if you want a possible connection to a different room.

hidden door connections and special door connections will be handled by those special rooms and should not be selected for normal rooms.
(this connection isn't done yet btw)
also, don't put doors pointing to another room_part inside of the same room. probably it would crash.
