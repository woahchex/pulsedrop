local asset = Asset
local draw = drawImage
local gpush, gpop, setColor = love.graphics.push, love.graphics.pop, love.graphics.setColor



local SIZERATIO = 2.5

-- The field class handles rendering the play field. Also might work with player controls. Who knows!
local Field = {    
    -- prototype
    __index = {
        -- instance vars
        position = 250,
        notesToRender = {},
        transparencyTracker = {},
        fadeOutOffset = {},

        activePieceOffset = 0,

        -- methods
        update = function(self, dt)
            self.activePieceOffset = self.activePieceOffset / 1.1 * 100 * dt

            -- transparency gradient thing
            for i, e in pairs(self.transparencyTracker) do
                if e > 0.2 or (e > 0 and self.notesToRender[i]:getUsed()) then
                    self.transparencyTracker[i] = e - 5*dt
                end
            end

            for i, e in pairs(self.fadeOutOffset) do
                self.fadeOutOffset[i] = e * 4 * 60 * dt
            end
        end,


        draw = function(self, currentTime, activePiece, ox, oy)
            
            local height = love.graphics.getHeight()
            local width = height/SIZERATIO
            ox, oy = ox or 0, oy or 0

            local hitLinePos = width/10*5
            local noteArea = height - hitLinePos
            gpush()
            love.graphics.setColor(1,1,1,1)
            draw(asset.image.field_overlay, self.position + ox, 0 + oy, 0, width, height, 0.5, 0)
            gpop()
            local tileSize = width/10
            for i, note in pairs(self.notesToRender) do
                local approachRate = note:getApproachRate()
                local noteTime = note:getTime()
                local timeToHit = noteTime - currentTime
                local relativePosition = timeToHit/approachRate

                if note:getActive() then
                    self.fadeOutOffset[i] = self.fadeOutOffset[i] or 2
                end


                local actualPosition = relativePosition * noteArea + hitLinePos

                if relativePosition <= 1 then
                    if not self.transparencyTracker[i] and relativePosition < 0 then
                        self.transparencyTracker[i] = .9            
                    end
                    
                    local transparency = self.transparencyTracker[i] or 1

                    local type = note:getType()
                    if type == "MOVE" then
                        gpush()
                        if note:getCompleted() then
                            setColor( 1, 1, 1, transparency )
                        else
                            local pid = note:getPieceId()
                            local color = {Tetris.getColor(pid)}
                            setColor( color[1] + 0.3, color[2] + 0.3, color[3] + 0.3, transparency )
                        end
                        draw(asset.image.move_line, math.floor(self.position - width/2 + ox), actualPosition + oy, 0, width, width/10, nil, nil, nil, nil, true)
                        draw(asset.image.move_line_trail, math.floor(self.position - width/2 + ox), actualPosition + oy, 0, width, width/5, nil, nil, nil, nil, true)
                        gpop()
                    elseif type == "DROP" then
                        gpush()
                            setColor(1,1,1,transparency)

                        gpop()
                        local grid = note:getGrid()
                        
                        gpush()
                        local colorToUse = {Tetris.getColor( note:getAltPieceId() > 0 and note:getAltPieceId() or note:getPieceId())}
                        if note:getCompleted() then
                            setColor( 1, 1, 1, transparency )
                        else
                            setColor( colorToUse[1] + .2, colorToUse[2] + .2, colorToUse[3] + .2, transparency )
                        end
                        for y = 1, #grid do
                            for x = 1, #grid[y] do
                                if grid[y][x] then
                                    draw(asset.image.tile, math.floor(self.position-width/2+0.5+tileSize*(x-1)+ox), actualPosition+tileSize*(y-1)+oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                                    if x == 3 or x == 4 or x == 8 or x == 7 then
                                        draw(asset.image.tile_overlay, math.floor(self.position-width/2+0.5+tileSize*(x-1)+ox), actualPosition+tileSize*(y-1)+oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                                    end
                                end
                            end
                        end
                        gpop()
                        gpush()
                        if note:getActive() then
                            setColor(1,1,1, transparency)
                            
                        end
                        draw(asset.image.drop_border, math.floor(self.position - width/2 + ox), actualPosition + oy, 0, width, width/10, nil, nil, nil, nil, true)
                        draw(asset.image.drop_border, math.floor(self.position - width/2+0.5 + ox), actualPosition + width/10*#grid + oy, 0, width, width/10, nil, nil, nil, nil, true)
                        draw(asset.image.move_line_trail, math.floor(self.position - width/2+0.5 + ox), actualPosition + width/10*#grid + oy, 0, width, width/5, nil, nil, nil, nil, true)
                        gpop()


                        -- draw the ghost piece on the active note
                        if note:getActive() and activePiece and activePiece.overlap then
                            local pieceGrid = activePiece:getMatrix()
                            gpush()
                            setColor(1,1,1,1)
                            for y = 1, #pieceGrid do
                                for x = 1, #pieceGrid[y] do
                                    if pieceGrid[y][x] then
                                        draw(asset.image.tile_ghost, math.floor(self.position-width/2+0.5+tileSize*(x-2+activePiece.position)+ox), actualPosition+tileSize*(y-2+activePiece.overlap)+oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                                    end
                                end
                            end
                            gpop()
                        end

                        -- draw the piece out to the side
                        local fadeOutPos = self.fadeOutOffset[note:getFieldIndex()] or 0
                        local pieceMatrix = Tetris.displayMatrix[note:getPieceId()]
                        local heightOffset = (#grid - 4) * tileSize/2

                        if note:getPieceId() == 1 then
                            heightOffset = heightOffset + tileSize/2
                        end

                        local ofsx = self.position + tileSize*6
                        local ofsy = actualPosition
                        gpush()
                        setColor( Tetris.getColor( note:getPieceId(), transparency ) )
                        for y = 1, #pieceMatrix do
                            for x = 1, #pieceMatrix[y] do
                                if pieceMatrix[y][x] then
                                    draw(asset.image.tile, ofsx + tileSize*(x-1) + ox, ofsy + tileSize*(y-1) - fadeOutPos + heightOffset + oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                                end
                            end
                        end
                        gpop()
                        
                    end
                end



                -- removing from buffer if it's expired
                if relativePosition <= -0.5 then
                    self.notesToRender[i] = nil
                    self.transparencyTracker[i] = nil
                    self.fadeOutOffset[i] = nil
                end                
            end

            gpush()
            setColor(1,1,1)
            draw(asset.image.hit_line, self.position - width/2+0.5 + ox, hitLinePos + oy, 0, width, width/10, nil, nil, nil, nil, true)
            draw(asset.image.line_border_blur, self.position - width/2+0.5 + ox, hitLinePos + oy, 0, width, width/2.5, 0, 1, nil, nil, true)
            draw(asset.image.field_border_left, self.position - width/2+0.5 + ox + 1, 0 + oy, 0, width/10, height, 1, 0, nil, nil, true)
            draw(asset.image.field_border_right, self.position + width/2+0.5 + ox - 1, 0 + oy, 0, width/10, height, 0, 0, nil, nil, true)
            gpop()

            if activePiece then
                
                gpush()
                setColor( Tetris.getColor(activePiece:getId(), 1) )
                local pieceGrid = activePiece:getMatrix()
                
                for y = 1, #pieceGrid do
                    for x = 1, #pieceGrid[y] do
                        if pieceGrid[y][x] then
                            draw(asset.image.tile, self.position - width/2 + tileSize*(x-2+activePiece.position) + ox, tileSize*(y+activePiece.renderTileOffset) + oy, 0, tileSize, tileSize, nil, nil, nil, nil, true)
                        end
                    end
                end
                gpop()
            end

            
        end,

        addNote = function(self, note)
            local id = #self.notesToRender+1
            self.notesToRender[id] = note
            note:setFieldIndex(id)
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
        "skinpath/tile.png",
        "skinpath/tile_overlay.png",
        "skinpath/tile_ghost.png",
        "skinpath/drop_border.png",
        "skinpath/line_border_blur.png",
        "skinpath/field_border_left.png",
        "skinpath/field_border_right.png"
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