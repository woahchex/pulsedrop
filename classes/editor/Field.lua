local Field = {
    scene = false,

}

----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if not loadedAssets then
        loadedAssets = true
        -- load scene assets into memory (Scene.assets{})
    end
end

-- Constructor for 
function Field.new()
    local newField = setmetatable({}, Field)
    
    -- load related assets, if applicable
    loadAssets()

    return newField
end


return Field