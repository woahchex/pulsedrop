-- 1. I
-- 2. J
-- 3. L
-- 4. S
-- 5. Z
-- 6. T
-- 7. O
local Tetris = {
    color = {
        {110/255, 199/255, 255/255},
        {52/255, 138/255, 250/255},
        {255/255, 166/255, 33/255},
        {59/255, 255/255, 48/255},
        {255/255, 61/255, 61/255},
        {250/255, 97/255, 225/255},
        {255/255, 229/255, 0/255}
    },

    matrix = {
        { -- I
            {false, false, false, false},
            {true,  true,  true,  true },
            {false, false, false, false},
            {false, false, false, false}
        },
        { -- J
            {true,  false, false},
            {true,  true,  true },
            {false, false, false}
        },
        { -- L
            {false, false, true },
            {true,  true,  true },
            {false, false, false}
        },
        { -- S
            {false, true , true },
            {true,  true,  false},
            {false, false, false}
        },
        { -- Z
            {true,  true , false},
            {false, true,  true },
            {false, false, false}
        },
        { -- T
            {false, true,  false},
            {true,  true,  true},
            {false, false, false}
        },
        { -- O
            {false, false, false, false},
            {false, true,  true,  false},
            {false, true,  true,  false},
            {false, false, false, false}
        },
    },

    displayMatrix = {
        { -- I
            {false, false, false, false},
            {true,  true,  true,  true },
            {false, false, false, false},
            {false, false, false, false}
        },
        { -- J
            {false, false, false, false},
            {true,  false, false, false},
            {true,  true,  true , false},
            {false, false, false, false}
        },
        { -- L
            {false, false, false, false},
            {false, false, true,  false},
            {true,  true,  true,  false},
            {false, false, false, false}
        },
        { -- S
            {false, false, false, false},
            {false, true , true , false},
            {true,  true,  false, false},
            {false, false, false, false}
        },
        { -- Z
            {false, false, false, false},
            {true,  true , false, false},
            {false, true,  true,  false},
            {false, false, false, false}
        },
        { -- T
            {false, false, false, false},
            {false, true,  false, false},
            {true,  true,  true, false},
            {false, false, false, false}
        },
        { -- O
            {false, false, false, false},
            {true,  true,  false, false},
            {true,  true,  false, false},
            {false, false, false, false}
        },
    },
    
    
    __global = true
}

function Tetris.getColor(id, transparency)
    local c = Tetris.color[id]
    return c[1], c[2], c[3], transparency
end

return Tetris