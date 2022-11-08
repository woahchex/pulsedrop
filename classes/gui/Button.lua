local Button = {}
Button.__index = {
    x = 0,   y = 0;
    sx = 0, sy = 0;
    ox = 0, oy = 0;
    currentSize = 1, goalSize = 1;
    image = nil,
    dampening = 2,
    color = {1, 1, 1, 1}
}

local mouse = Mouse

-- Constructor
function Button.new(image, x, y, sx, sy, ox, oy)
    local newButton = setmetatable({
        image = image,
        x = x,
        y = y,
        sx = sx,
        sy = sy,
        ox = ox,
        oy = oy
    }, Button)

    return newButton
end

-- instance methods
function Button.__index:getHover()
    local mx, my = Mouse.getPosition()
    local tx, ty = self.x - (self.sx * self.ox), self.y - (self.sy * self.oy)
    local bx, by = tx + self.sx, ty + self.sy
    return mx >= tx and my >= ty and mx <= bx and my <= by
end

function Button.__index:getClick()
    return self:getHover() and mouse.clicked
end

local gpush, gpop, draw, setColor, gprint = drawStuff()
function Button.__index:draw()
    local width, height = love.graphics.getDimensions()
    love.graphics.push()
    setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
    draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)
    love.graphics.pop()
end

function Button.__index:update(dt)
    local dampening = self.dampening / dt / 40
    self.currentSize = (self.currentSize * dampening + self.goalSize)/(dampening+1)
end

return Button