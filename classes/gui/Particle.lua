local Particle = {
    __global = true
}

local push, pop, draw, setColor = drawStuff()
local function defaultDraw(self)
    push()
    setColor(1,1,1)
    draw()
    pop()
end


local function defaultUpdate(self, dt)
    local dtconst = 60*dt
    self[2] = self[2] + self[7]*dtconst    -- xvel
    self[3] = self[3] + self[8]*dtconst    -- yvel
    self[7] = self[7] + self[9]*dtconst    -- xacc
    self[8] = self[8] + self[10]*dtconst   -- yacc
    self[11] = self[11] + self[12]*dtconst -- ovel
end

--                  img,    x,  y,  r,  sx, sy, vx, vy, ax, ay, opacity, oVel, updatefunc,    drawfunc
Particle.__index = {false,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,       0,    defaultUpdate, defaultDraw}

function Particle.new(img, x, y, r, sx, sy, vx, vy, ax, ay, opacity, oVelocity, updateFunc, drawFunc)
    return setmetatable({img, x, y, r, sx, sy, vx, vy, ax, ay, opacity, oVelocity, updateFunc, drawFunc}, Particle)
end

return Particle