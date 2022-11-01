local Note = {
    __index = {
        [1] = "NONE", -- note type (MOVE/DROP)
        [2] = 0,      -- note timestamp
        [3] = 2,      -- approach rate
        [4] = 1,      -- tetris piece ID (1-7)
        [5] = 0,      -- alt tetris piece ID (1-7)
        [6] = -1,     -- index in rendering field
        [7] = false,  -- active note flag
        [8] = nil,     -- grid (for DROPs only)
        [9] = false,  -- active piece state (first = false, second = true)
        [10] = false, -- completed flag
        [11] = false, -- used flag
        [12] = 1,     -- approach multiplier 

        -- methods
        setType = function(self, type)
            self[1] = type
        end,

        setTime = function(self, time)
            self[2] = time
        end,

        setApproachRate = function(self, time)
            self[3] = time
        end,

        setPieceId = function(self, id)
            self[4] = id
        end,

        setAltPieceId = function(self, id)
            self[5] = id
        end,

        setFieldIndex = function(self, id)
            self[6] = id
        end,

        setActive = function(self, active)
            self[7] = active
        end,

        setGrid = function(self, grid)
            self[8] = grid
        end,

        setActivePiece = function(self, val)
            self[9] = val
        end,

        setCompleted = function(self, val)
            self[10] = val
        end,

        setUsed = function(self, val)
            self[11] = val
        end,

        setARMultiplier = function(self, val)
            self[12] = val
        end,

        getType = function(self)
            return self[1]
        end,

        getTime = function(self)
            return self[2]
        end,

        getApproachRate = function(self)
            return self[3]
        end,

        getPieceId = function(self)
            return self[4]
        end,

        getAltPieceId = function(self)
            return self[5]
        end,

        getFieldIndex = function(self)
            return self[6]
        end,

        getActive = function(self)
            return self[7]
        end,

        getGrid = function(self)
            return self[8]
        end,

        getActivePiece = function(self)
            return self[9]
        end,

        getCompleted = function(self)
            return self[10]
        end,

        getUsed = function(self)
            return self[11]
        end,

        getARMultiplier = function(self)
            return self[12]
        end,
        
        toString = function(self)
            if self:getType()=="MOVE" then
                return "move@"..self:getTime().."s  AR"..self:getApproachRate()
            else
                local grid = ""
                for y, t in ipairs(self:getGrid()) do
                    grid = grid .. "\n\t"
                    for x, v in ipairs(t) do
                        grid = grid .. (v and "O" or " ")
                    end
                end
                return "drop@"..self:getTime().."s  AR"..self:getApproachRate().."  GR"..grid
            end
        end
    },
    __global = true
}

function Note.new(type, time, arMultiplier, pieceId, fieldIndex, grid, secondPieceId)
    local newNote = setmetatable({}, Note)

    newNote:setType(type or 0)
    newNote:setTime(time or 0)
    newNote:setARMultiplier(arMultiplier or 1)
    newNote:setPieceId(pieceId or 1)
    newNote:setAltPieceId(secondPieceId or 0)
    newNote:setFieldIndex(fieldIndex or -1)
    newNote:setGrid(grid or nil)

    return newNote
end

return Note