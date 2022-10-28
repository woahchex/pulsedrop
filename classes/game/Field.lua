local asset = Asset
local draw = drawImage
local gpush, gpop = love.graphics.push, love.graphics.pop

local SIZERATIO = 2.5

-- The field class handles rendering the play field. Also might work with player controls. Who knows!
local Field = {    
    -- prototype
    __index = {
        -- instance vars
        position = 250,
        notesToRender = {},

        -- methods
        draw = function(self, currentTime, ox, oy)
            
            local height = love.graphics.getHeight()
            local width = height/SIZERATIO
            ox, oy = ox or 0, oy or 0

            local hitLinePos = width/10*5
            local noteArea = height - hitLinePos

            draw(asset.image.field_overlay, self.position + ox, 0 + oy, 0, width, height, 0.5, 0)
            local c = 0
            for i, note in pairs(self.notesToRender) do
                c = c + 1
                local approachRate = note[3]
                local noteTime = note[2]
                local timeToHit = noteTime - currentTime
                local relativePosition = timeToHit/approachRate



                local actualPosition = relativePosition * noteArea + hitLinePos

                if relativePosition <= 1 then
                    gpush()
                    draw(asset.image.move_line, self.position - width/2 + ox, actualPosition + oy, 0, width, width/10, nil, nil, nil, nil, true)
                    gpop()
                    if note[1] == "MOVE" then
                        gpush()
                        draw(asset.image.move_line_trail, self.position - width/2 + ox, actualPosition + oy, 0, width, width/10, nil, nil, nil, nil, true)
                        gpop()
                    elseif note[1] == "DROP" then
                        local grid = note[6]
                        local tileSize = width/10
                        gpush()
                        for y = 1, #grid do
                            for x = 1, #grid[y] do
                                if grid[y][x] then
                                    draw(asset.image.tile, self.position-width/2+0.5+tileSize*(x-1)+ox, actualPosition+tileSize*(y-1)+oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                                end
                            end
                        end
                        gpop(); gpush()
                        draw(asset.image.move_line, self.position - width/2+0.5 + ox, actualPosition + width/10*#grid + oy, 0, width, width/10, nil, nil, nil, nil, true)
                        gpop()
                    end
                end

                -- removing from buffer if it's expired
                if relativePosition <= 0 then
                    self.notesToRender[i] = nil
                end                
            end
            print(c)
            draw(asset.image.hit_line, self.position - width/2+0.5 + ox, hitLinePos + oy, 0, width, width/10, nil, nil, nil, nil, true)

        end,

        addNote = function(self, note)
            local id = #self.notesToRender+1
            self.notesToRender[id] = note
            note[5] = id
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
        "skinpath/hit_line.png",
        "skinpath/move_line.png",
        "skinpath/move_line_trail.png",
        "skinpath/tile.png"
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