local Asset = {
    image = {},
    sound = {},

    __global = true
}

local function split(input, sep)
    sep = sep or "%s"
    local out = {}
    for sub in input:gmatch("([^"..sep.."]+)") do
        out[#out+1] = sub
    end
    return out
end
--[[
    So skins should work something like: 
    You can call for any direct links to in the gamefiles, but 
    the term "skinpath" will be replaced with whatever the current skin folder is.
    i don't know how it's gonna work yet so there's a placeholder

    KEYWORDS:
    skinpath - active skin pack
    mainpath - constant assets folder
]]
local skinPath = "assets/skins/default"
local mainPath = "assets/constant"
function Asset.loadImage(path)
    local pathData = split(path, "/")
    Asset.image[pathData[#pathData]:gsub(".png","")] = love.graphics.newImage(path:gsub("skinpath", skinPath):gsub("mainpath", mainPath), nil) -- need this nil because i guess gsub returns indices also and fucks everything up
end

--[[function Asset.loadSound(path)
    Asset.sound[path] = love.audio.newSource(path)
end]]

return Asset