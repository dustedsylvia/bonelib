-- library made by dustedsylvia for Create Your Frisk, NOT unitale
-- This library is licensed under the GNU General Public License. In other words, please don't pass it off as your own.

--[[
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
]]


-- library object
local self = {}

-- default variables
self.defaultcollision = "ppcollision"                                -- "ppcollision" or "box". See the documentation.
self.defaultcolor = "white"                                          -- "white", "orange", "blue", or "green".
self.defaultlength = 100                                             -- Length (in pixels) of default bones
self.defaultmask = "arena"                                           -- You can either specify "arena" or "none".
self.defaultrotation = 0                                             -- From 0-360, rotation of bone
self.defaultbonepivotx = 0.5                                         -- See "Sprites and Animation" (documentation)
self.defaultbonepivoty = 0.5                                         -- See "Sprites and Animation" (documentation)
self.defaultbonetype = "papyrus"                                     -- Can be "papyrus" or "sans".
self.defaultbonexvelocity = 0                                        -- Default bone X velocity of sprite
self.defaultboneyvelocity = 0                                        -- Default bone Y velocity of sprite
self.defaultbonerotvelocity = 0                                      -- Default bone rotation  velocity of sprite
self.defaultbonelayer = "BelowPlayer"                                -- Default sprite layer for the bone
self.papsboneprefix = "Attacks/Papyrus/papyrusbones/papsbone"        -- Default sprite prefix for Papyrus's bones
self.sansboneprefix = "Attacks/Sans/sansbones/sansbone"              -- Default sprite prefix for Sans's bones
self.spriteextension = ".png"                                        -- Default sprite extension for all sprites
self.useabsolutepositions = false                                    -- Controls whether CreateProjectile or CreateProjectileAbs is used.
self.garbagecollection = true                                        -- Controls whether bones are destroyed once offscreen
self.bonedamage = 3                                                  -- How much damage each bone deals
self.boneinvs = 0.5                                                  -- How much invincibility time each bone gives (seconds)
self.ignoredef = true                                                -- Controls whether the bone damage will ignore defense
self.playhurtsound = true                                            -- Controls whether the hurt sound will be played when a bone hits the player
self.playhealsound = true                                            -- Controls whether the heal sound will be played when a green bone hits the player
self.shakescreenonhit = true                                         -- Controls whether the screen will be shaken when the player is hit
self.boneremoveonhit = false                                         -- Controls whether the bone will be removed when it hits the player
self.greenbonehealamount = 10                                        -- How much health green bones will heal
self.bones = {}                                                      -- Holds all the bones. DON'T OVERWRITE THIS.

function self.CreateBone(bonex, boney, bonelength, bonetype, bonecolor, bonerotation, bonemask, bonelayer, collisiontype, pivotx, pivoty, xvelocity, yvelocity, rotvelocity)
    -- Bone sprite
    if bonelength ~= nil then bonelength = tostring(bonelength) else bonelength = tostring(self.defaultlength) end
    if bonetype == "sans" then boneprefix = self.sansboneprefix else boneprefix = self.papsboneprefix end
    bonesprite = boneprefix..bonelength..self.spriteextension

    -- Bone layer
    if bonelayer == nil then bonelayer = self.defaultbonelayer end
    
    -- Bone position
    if self.useabsolutepositions then bone = CreateProjectileAbs(bonesprite, bonex, boney, bonelayer) else bone = CreateProjectile(bonesprite, bonex, boney, bonelayer) end

    -- Bone color
    if bonecolor ~= nil then color = bonecolor else color = self.defaultcolor end
    bone["color"] = color

    -- Bone sprite properties
    bone.sprite.rotation = bonerotation
    if bone["color"] == "orange" then bone.sprite.color32 = {255, 166, 0}
    elseif bone["color"] == "blue" then bone.sprite.color32 = {0, 162, 232}
    elseif bone["color"] == "green" then bone.sprite.color32 = {0, 255, 0}
    else bone.sprite.color32 = {255, 255, 255} end
    if bonemask == "arena" or (bonemask == nil and self.defaultmask == "arena") then bone.sprite.SetParent(Encounter["arenamask"]) end
    if pivotx == nil then bone.sprite.xpivot = self.defaultbonepivotx else bone.sprite.xpivot = pivotx end
    if pivoty == nil then bone.sprite.ypivot = self.defaultbonepivoty else bone.sprite.ypivot = pivoty end
    
    -- Projectile properties
    if collisiontype == "ppcollision" or (collisiontype == nil and self.defaultcollision == "ppcollision") then bone.ppcollision = true end
    if xvelocity == nil then bone["xvelocity"] = self.defaultbonexvelocity else bone["xvelocity"] = xvelocity end
    if yvelocity == nil then bone["yvelocity"] = self.defaultboneyvelocity else bone["yvelocity"] = yvelocity end
    if rotvelocity == nil then bone["rotvelocity"] = self.defaultbonerotvelocity else bone["rotvelocity"] = rotvelocity end
    bone["type"] = "bone" -- Needed for OnHit function
    bone.OnHit = self.OnHit

    table.insert(self.bones, bone)

    return #self.bones -- Return the index of the bone
end

function self.Update()
    for i=#self.bones, 1, -1 do
        local bone = self.bones[i]
        bone.Move(bone["xvelocity"], bone["yvelocity"])
        bone.sprite.rotation = bone.sprite.rotation + bone["rotvelocity"]
        if (self.garbagecollection == true) then
            if (bone.absx < -20 or bone.absx > 660) then
                bone.Remove()
                table.remove(self.bones, i)
            end
            if (bone.absy < -20 or bone.absy > 500) then
                bone.Remove()
                table.remove(self.bones, i)
            end
        end
    end
end

function self.RemoveBone(boneindex)
    self.bones[boneindex].Remove() --[[ DO NOT REMOVE IT FROM THE TABLE OBJECT!!!!
                                        Removing it from the table object will cause problems with other bones.
                                        This is because it will cause a frameshift mutation in the array indexes...
                                        so don't remove it. Please? ]]
end

function self.ClearBones()
    self.bones = {}
end

function self.GetBoneObject(boneindex)
    return self.bones[boneindex]
end

function self.GetBoneSprite(boneindex)
    return self.bones[boneindex].sprite
end

function self.OnHit(bone)
    if (bone["color"] == "blue" and Player.ismoving) then
        Player.Hurt(self.bonedamage, self.boneinvs, self.ignoredef, self.playhurtsound)
        if self.shakescreenonhit then Misc.ShakeScreen(30, 5, true) end
    elseif (bone["color"] == "blue" and not Player.ismoving) then
        -- Prevent the player from being hit
    elseif (bone["color"] == "orange" and not Player.ismoving) then
        Player.Hurt(self.bonedamage, self.boneinvs, self.ignoredef, self.playhurtsound)
        if self.shakescreenonhit then Misc.ShakeScreen(30, 5, true) end
    elseif (bone["color"] == "orange" and Player.ismoving) then 
        -- Prevent the player from being hit, again
    elseif bone["color"] == "green" then
        Player.Hurt(-1*self.greenbonehealamount, 0, true, self.playhealsound)
    else
        Player.Hurt(self.bonedamage, self.boneinvs, self.ignoredef, self.playhurtsound)
        if self.shakescreenonhit then Misc.ShakeScreen(30, 5, true) end
    end
    if self.removeboneonhit then bone.Remove() end
end

return self