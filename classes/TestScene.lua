local dimensions = _G.SIZE
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
            self.testElement:draw()
        end,

        update = function(self, dt)
            self.testElement:update(dt)
        end
    },

    activeScenes = {},
    assets = {}
}
Scene.__index = Scene.prototype


----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if loadedAssets then return end
    local asset = Asset
    loadedAssets = true
    for _, path in ipairs({
        "mainpath/slider_body.png",
        "mainpath/slider_cursor.png",
        "mainpath/checkbox_background.png",
        "mainpath/checkbox_cursor.png"
    }) do
        asset.loadImage(path)
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

    --
    newScene.testElement = Classes.gui_GuiElement.newContainer(Asset.image.slider_body, dimensions[1]/2, dimensions[2]/2, dimensions[1]/2, dimensions[2]/2, 0.5, 0.5)
    newScene.testElement:addElement( Classes.gui_GuiElement.newSelectionBox(Asset.image.empty, Asset.image.checkbox_background, Asset.image.checkbox_cursor, {"A", "B", "C", "D"}, dimensions[1]/1.75, dimensions[2]/1.75, 400, 400, 6, 3, 0.5, 0.5, nil, true) )
    newScene.testElement:addElement( Classes.gui_GuiElement.newTextbox(Asset.image.slider_body, "", dimensions[1]/1.75, dimensions[2]/2, dimensions[1]/3, dimensions[2]/20, 0.5, 0.5, {0, 0, 0}) )
    newScene.testElement.elements[2].textSize = 0.6
    newScene.testElement:addElement( Classes.gui_GuiElement.newSelectionBox(Asset.image.empty, Asset.image.checkbox_background, Asset.image.checkbox_cursor, {"Generic Checkbox"}, dimensions[1]/1.25, dimensions[2]/1.25, dimensions[1]/10, dimensions[2]/10, 1, 1, 0.5, 0.5, nil, true) )
    newScene.testElement.elements[3].align = "RIGHT"

    return newScene
end

-- Draw method for the CLASS. Handles drawing for all active scenes.
function Scene.draw()
    for _, scene in pairs(Scene.activeScenes) do
        scene:draw()
    end
end

-- Update method for the CLASS. Handles updates for all active scenes.
function Scene.update(dt)
    
    for _, scene in pairs(Scene.activeScenes) do
        scene:update(dt)
    end    
end

return Scene