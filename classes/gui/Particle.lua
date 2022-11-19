local Particle = {
    TICKRATE = 60,
    
    instances = setmetatable({}, {__mode=""}),

    __global = true
}

local push, pop, draw, setColor = drawStuff()
local function defaultDraw(self)
    if Particle.instances[self[18]] == self then
        push()
            setColor(1,1,1, self[14])
            draw(self[1], self[2], self[3], self[4], self[5], self[6], self[7], self[8], nil, nil, true)
        pop()
    end
end

local function clamp(x, mn, mx) return x<mn and mn or x>mx and mx or x end
local function defaultUpdate(self, dt)
    local dtconst = 60*dt
    self[2] = self[2] + self[9]*dtconst    -- xvel
    self[3] = self[3] + self[10]*dtconst    -- yvel
    self[9] = self[9] + self[11]*dtconst    -- xacc
    self[10] = self[10] + self[12]*dtconst   -- yacc
    self[14] = self[14] + self[15]*dtconst -- ovel
    local ratio = self[5]/self[6]
    self[5] = clamp(self[5] + self[13]*dtconst, 0, math.huge) -- svel
    self[6] = self[6] + self[13]*dtconst/ratio -- svel
    
    self[17] = self[17] + dt -- lifetime

    if self[17] > self[16] then
        self:destroy()
    end
end
--                  1       2   3   4   5   6   7    8    9   10  11  12  13  14       15         16        17        18  19             20
--                  img,    x,  y,  r,  sx, sy, ox,  oy,  vx, vy, ax, ay, sv, opacity, ovelocity, lifetime, lifeprog, id, updatefunc,    drawfunc
Particle.__index = {false,  0,  0,  0,  0,  0,  0.5, 0.5, 0,  0,  0,  0,  0,  1,       0,         5,        0,        0,  defaultUpdate, defaultDraw}

for i, alias in ipairs({
    "Image", "X", "Y", "Rotation", "SizeX", "SizeY", "OffsetX", "OffsetY",
    "VelocityX", "VelocityY", "AccelerationX", "AccelerationY",
    "SizeVelocity", "Opacity", "OVelocity", "Lifetime", "LifeProgress",
    "UpdateFunction", "DrawFunction"
}) do
    Particle.__index["get" .. alias] = function(s) return s[i] end
    Particle.__index["set" .. alias] = function(s, v) s[i] = v end
end
Particle.__index.update = function(self, dt) return self[19](self, dt) end
Particle.__index.draw = function(self) return self[20](self) end
Particle.__index.destroy = function(self)
    Particle.instances[self[18]] = nil
end

function Particle.new(img, x, y, r, sx, sy, ox, oy, vx, vy, ax, ay, sv, opacity, oVelocity, lifetime, updateFunc, drawFunc)
    local id = #Particle.instances+1
    local newParticle = setmetatable({img, x, y, r, sx, sy, ox, oy, vx, vy, ax, ay, sv, opacity, oVelocity, lifetime, 0, id, updateFunc, drawFunc}, Particle)
    Particle.instances[id] = newParticle
    return newParticle
end

local tickProgress = 0
local tickRate = 1/Particle.TICKRATE
function Particle.update(dt)
    tickProgress = tickProgress + dt
    while tickProgress >= tickRate do
        tickProgress = tickProgress - tickRate
        -- update all active particles
        for _, particle in pairs(Particle.instances) do
            particle:update(tickRate)
        end
    end
end


-- bonus class: particle containers
local Container = {
    __index = {
        particles = {},

        draw = function(self)
            for _, particle in pairs(self.particles) do
                particle:draw()
            end
        end,

        insert = function(self, particle)
            self.particles[#self.particles+1] = particle
        end
    },
}
function Particle.newContainer()
    local newContainer = setmetatable({}, Container)
    newContainer.particles = setmetatable({}, {__mode="kv"})
    return newContainer
end

return Particle