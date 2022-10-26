--[[
    Editor Scenes run at a base 1280x720 resolution, scaled linearly*
]]
local Scene Scene = {
    -- This is the prototype instance for an editor scene object.
    prototype = {
        --- instance vars
        id = 0,

        --- methods
        destroy = function(self)
            Scene.activeScenes[self.id] = nil
        end,

        draw = function(self)
            
        end,

        update = function(self)
            
        end
    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype


----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if not loadedAssets then
        loadedAssets = true
        -- load scene assets into memory (Scene.assets{})
    end
end


-- Constructor for editor scene objects
function Scene.new()
    local newScene = setmetatable({}, Scene)
    
    -- add the scene to the current list
    newScene.id = #Scene.activeScenes+1
    Scene.activeScenes[#Scene.activeScenes+1] = newScene

    -- load related assets, if applicable
    loadAssets()

    return newScene
end

-- Draw method for the CLASS. Handles drawing for all active scenes.
function Scene.draw()
    for _, scene in pairs(Scene.activeScenes) do
        scene.draw()
    end
end

-- Update method for the CLASS. Handles updates for all active scenes.
function Scene.update(dt)
    
    for _, scene in pairs(Scene.activeScenes) do
        scene.update()
    end    
end

return Scene