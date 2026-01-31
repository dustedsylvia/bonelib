# bonelib
```
=== DOCUMENTATION ===
Loading into an attack script:
[at top of script]
bonelib = require "Libraries/bonelib"

[at bottom of Update() function]
bonelib.Update()

Functions:
Optional arguments have square brackets around the argument name.
self.CreateBone(
    Creates a bone based on the provided arguments and adds it to the `bones` table. The projectile is managed for you, but you can overwrite the OnHit function
    by running `bonelib.GetBoneObject.OnHit = function() ...your OnHit code here... end`. Note that this will render the library's damage management features useless.

    number    bonex           : X position of the bone (absolute if bonelib.useabsolutepositions is set to true)
    number    boney           : Y position of the bone (absolute if bonelib.useabsolutepositions is set to true)
    number    [bonelength]    : Length of the bone in pixels
    "string"  [bonetype]      : "sans" or "papyrus"
    "string"  [bonecolor]     : "white", "orange", "blue", or "green"
    number    [bonerotation]  : Rotation of bone sprite in degrees, clamped
    "string"  [bonemask]      : "arena" if you want to constrain the sprite to the arena, "none" otherwise
    "string"  [bonelayer]     : The sprite layer to draw the bone on
    "string"  [collisiontype] : "ppcollision" for pixel-perfect collision or "box" for box collision
    number    [pivotx]        : Horizontal pivot point of the sprite from 0 to 1 (left to right, respectively).
    number    [pivoty]        : Vertical pivot point of the sprite from 0 to 1 (bottom to top, respectively).
    number    [xvelocity]     : X velocity of bone in pixels per frame. Negative values move it left and positive values move it right.
    number    [yvelocity]     : Y velocity of bone in pixels per frame. Negative values move it down and positive values move it up.
    number    [rotvelocity]   : Rotational velocity of bone in degrees per frame. Negative values rotate it counterclockwise and positive values rotate it clockwise.

    Returns boneid. This function can be used as an argument to bonelib.RemoveBone(), bonelib.GetBoneObject(), and bonelib.GetBoneSprite(), so save the value to a
    variable or add it to a table if you need to use any of those functions.
)

self.RemoveBone(
    Removes a bone from the screen.

    number boneid: The id of the bone. (This is just the index of the bone in `bonelib.bones`, it's nothing special).

    Returns nil.
)

self.ClearBones(
    Resets the `bones` array back to how it was when it started. Does not require arguments.

    Returns nil.
)

self.GetBoneObject(
    Shortcut to get the Projectile object of a bone.

    number boneid: The id of the bone. Returned from CreateBone().

    Returns a Projectile object.
)

self.GetBoneSprite(
    Shortcut to get the Sprite object of a bone.

    number boneid: The id of the bone. Returned from CreateBone().

    Returns a Sprite object.
)

Examples (assuming self.useabsolutepositions is false)
Creating a stationary white bone at the arena's center:
    bonelib.CreateBone(0, 0, 15)
Creating an orange spinning bone:
    bonelib.CreateBone(0, 0, Arena.height, "papyrus", "orange", 0, "arena", "BelowPlayer", "ppcollision", 0.5, 0.5, 0, 0, 3)
Creating an orange bone that goes across the Arena:
    bonelib.CreateBone(-1*(Arena.width / 2)-20, 0, 400, "papyrus", "orange", 0, "arena", "BelowPlayer", "ppcollision", 0.5, 0.5, 15, 0, 0)

P.S. before the keyboard warriors open issues because the method used for bone sprites is EXTREMELY inefficient, i am aware of this. it will be fixed later. maybe.
```