local function transpose(m)
    local rotated = {}
    for c, m_1_c in ipairs(m[1]) do
        local col = {m_1_c}
        for r = 2, #m do
            col[r] = m[r][c]
        end
        table.insert(rotated, col)
    end
    return rotated
end
 
local function rotateCCW(m)
    local rotated = {}
    for c, m_1_c in ipairs(m[1]) do
        local col = {m_1_c}
        for r = 2, #m do
            col[r] = m[r][c]
        end
        table.insert(rotated, 1, col)
    end
    return rotated
end

local function rotate180(m)
    return rotateCCW(rotateCCW(m))
end

local function rotateCW(m)
    return rotateCCW(rotateCCW(rotateCCW(m)))
end

local function deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepCopy(orig_key)] = deepCopy(orig_value)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

local Piece = {
    __index = {
        position = 4,
        matrix = {},
        matrix2 = {},
        id = 0,
        id2 = 0,
        leftHoldTime = 0,
        rightHoldTime = 0,
        direction = 1,

        das = 0.3,
        arr = 0.05,
        arrTimer = 0,

        overlap = nil,
        held = false,
        renderTileOffset = 0.5,
        dropDebounce = 0,

        getMatrix = function(self)
            return self.held and self.matrix2 or self.matrix
        end,

        getId = function(self)
            return self.held and self.id2 or self.id
        end,

        hold = function(self)
            if not self.held then
                self.held = true
                self.position = 4
                self.renderTileOffset = -0.5
            end
        end,

        rotateCW = function(self)
            if self.held then
                self.matrix2 = rotateCW(self.matrix2)
            else
                self.matrix = rotateCW(self.matrix)
            end
        end,

        rotateCCW = function(self)
            if self.held then
                self.matrix2 = rotateCCW(self.matrix2)
            else
                self.matrix = rotateCCW(self.matrix)
            end
        end,

        rotate180 = function(self)
            if self.held then
                self.matrix2 = rotateCW(rotateCW(self.matrix2))
            else
                self.matrix = rotateCW(rotateCW(self.matrix))
            end
        end,

        holdLeft = function(self, val, dt)
            self.leftHoldTime = val and self.leftHoldTime + dt or 0
        end,

        holdRight = function(self, val, dt)
            self.rightHoldTime = val and self.rightHoldTime + dt or 0
        end,

        frameLeft = function(self)
            self.position = self.position - 1
            self.rightHoldTime = 0
            self.arrTimer = self.arr
            self.direction = -1
        end,

        frameRight = function(self)
            self.position = self.position + 1
            self.leftHoldTime = 0
            self.arrTimer = self.arr
            self.direction = 1
        end,

        updateCollision = function(self, note)
            -- first update vertical collision
            local pieceMatrix = self:getMatrix()
            local noteMatrix = note:getGrid()
            local piecePos = self.position
            local tileOffset = -4

            local ofs = -6
            local resolved
            while not resolved do
                ofs = ofs + 1

                for py = 1, #pieceMatrix do
                    local ty = py + ofs
                    for px = 1, #pieceMatrix[py] do
                        local tx = px + piecePos - 1
                        if pieceMatrix[py][px]then
                            if ty > #noteMatrix then
                                -- collision !
                                resolved = true; break
                            end
                            if noteMatrix[ty] and noteMatrix[ty][tx] then
                                -- collision !
                                resolved = true; break
                            end
                        end
                    end
                    if resolved then break end
                end
            end
            self.overlap = ofs

            local xpush = 0
            for y = 1, #pieceMatrix do
                for x = 1, #pieceMatrix[y] do
                    if pieceMatrix[y][x] then
                        local tx = x + piecePos - 1
                        if tx < 1 then
                            xpush = math.abs(1 - tx) > math.abs(xpush) and 1 - tx or xpush
                        elseif tx > 10 then
                            xpush = math.abs(tx - 10) > math.abs(xpush) and 10 - tx or xpush
                        end
                    end
                end
            end

            self.position = piecePos + xpush
        end,

        fillNote = function(self, note)
            local pieceMatrix = self:getMatrix()
            local piecePos = self.position
            local noteMatrix = note:getGrid()
            local completed = true
            for y = 1, #pieceMatrix do
                local ty = y + self.overlap - 1
                for x = 1, #pieceMatrix[y] do
                    local tx = x + piecePos - 1
                    if pieceMatrix[y][x] then
                        if noteMatrix[ty] then
                            noteMatrix[ty][tx] = true
                        else
                            completed = false
                        end
                    end
                end
            end
            note:setUsed(true)
            note:setCompleted(completed)
        end,

        update = function(self, dt)
            self.renderTileOffset = self.renderTileOffset * (1 - 10*dt)
            self.dropDebounce = self.dropDebounce - dt

            --print(self.leftHoldTime, self.rightHoldTime)

            if self.leftHoldTime > self.das or self.rightHoldTime > self.das then                
                self.arrTimer = self.arrTimer + dt
                while self.arrTimer >= self.arr do
                    self.arrTimer = self.arrTimer - self.arr
                    self.position = self.position + self.direction
                end
            end
        end
    }
}



local tetris
function Piece.new(id, id2, das, arr)
    tetris = tetris or Tetris

    local newPiece = setmetatable({}, Piece)
    
    newPiece.matrix = deepCopy(tetris.matrix[id])
    newPiece.matrix2 = id2 and deepCopy(tetris.matrix[id2]) or deepCopy(tetris.matrix[id])
    newPiece.id = id
    newPiece.id2 = id2 or id
    newPiece.das = das
    newPiece.arr = arr

    return newPiece
end

return Piece