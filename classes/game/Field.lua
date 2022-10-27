local asset = Asset
local draw = drawImage

local Field = {    
    -- prototype
    __index = {
        -- instance vars
        position = 250,

        -- methods
        draw = function(self, ox, oy)
            local height = love.graphics.getHeight()
            local width = height/2.5

            draw(asset.image.field_overlay, self.position, 0, 0, width, height, 0.5, 0)
        end
    }
}

----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if loadedAssets then return end
    local asset = Asset
    loadedAssets = true
    for _, path in ipairs({
        "skinpath/field_overlay.png",
    }) do
        asset.loadImage(path)
    end        
end

-- Constructor
function Field.new()
    local newField = setmetatable({}, Field)
    
    -- load related assets, if applicable
    loadAssets()

    return newField
end

return Field