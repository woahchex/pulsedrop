local mouse = Mouse

----------------- GuiElement ------------------
local GuiElement = {
    elements = {},

    __global = true
}

-- prototype GuiElement
GuiElement.__index = {
    x = 0, y = 0;
    sx = 0, sy = 0;
    ox = 0, oy = 0;
    image = nil,
    color = {1, 1, 1, 1}
}

-- instance methods
function GuiElement.__index:getHover()
    local mx, my = mouse.getPosition()
    local tx, ty = self.x - (self.sx * self.ox), self.y - (self.sy * self.oy)
    local bx, by = tx + self.sx, ty + self.sy
    return mx >= tx and my >= ty and mx <= bx and my <= by
end

function GuiElement.__index:getClick()
    return mouse.clicked and self:getHover() 
end

local gpush, gpop, draw, setColor, gprint = drawStuff()
function GuiElement.__index:draw()
    local width, height = love.graphics.getDimensions()
    love.graphics.push()
    setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
    draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)
    love.graphics.pop()
end

function GuiElement.__index:update(dt)
    -- pass
end


function GuiElement.new(image, x, y, sx, sy, ox, oy, color)
    local newElement = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
    }, GuiElement)
    
    return newElement
end

----------------- Button -------------------
GuiElement.elements.Button = {
    __index = setmetatable({
        dampening = 2,
        currentSize = 1; goalSize = 1
    }, GuiElement)
}
local Button = GuiElement.elements.Button

-- instance methods
function Button.__index:update(dt)
    local dampening = self.dampening / dt / 40
    self.currentSize = (self.currentSize * dampening + self.goalSize)/(dampening+1)
end

function GuiElement.newButton(image, x, y, sx, sy, ox, oy, color)
    local newButton = setmetatable({
        image = image, color = color;
        x = x, y = y;
        sx = sx, sy = sy;
        ox = ox, oy = oy
    }, GuiElement.elements.Button)

    return newButton
end

---------------- 


return GuiElement