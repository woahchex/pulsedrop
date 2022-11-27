local mouse = Mouse
local dimensions = _G.SIZE

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
    local width, height = dimensions[1], dimensions[2]
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx*self.currentSize, self.sy*self.currentSize, self.ox, self.oy)
    gpop()
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



















----------------- 0-1 Slider --------------------
GuiElement.elements.Slider = {
    __index = setmetatable({
        cursorPosition = 0.5, -- 0.0 - 1.0
        padding = 15,       -- pixels,
        selected = false,
        tlText = "TLEFT", tText = "TOP", trText = "TRIGHT";
        blText = "BLEFT", bText = "BOTTOM", brText = "BRIGHT";

        cursor = nil        
    }, GuiElement)
}
local Slider = GuiElement.elements.Slider

-- instance methods
function Slider.__index:update(dt)
    if mouse.dragging then
        if self:getClick() then
            self.selected = true
        end
    else
        self.selected = false
    end

    if self.selected then
        local minPos = self.x + self.padding - self.sx*self.ox
        local maxPos = self.x + self.sx - self.padding - self.sx*self.ox

        local ratio = (mouse.x - minPos) / (maxPos - minPos)

        self.cursorPosition = math.clamp(ratio, 0, 1)
    end
end

function Slider.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        draw(self.cursor, self.x + self.padding + (self.sx - self.padding*2)*self.cursorPosition - ofsX, self.y+self.sy/2 - ofsY, 0, self.sy, self.sy, 0.5,0.5)
        
        gprint(self.tlText, self.x - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0, 1)
        gprint(self.trText, self.x + self.sx - ofsX, self.y - ofsY, 0, nil, self.sy/2, 1, 1)
        gprint(self.tText, self.x + self.sx/2 - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0.5, 1)
        gprint(self.blText, self.x - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0, 0)
        gprint(self.brText, self.x + self.sx - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 1, 0)
        gprint(self.bText, self.x + self.sx/2 - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0.5, 0)
    gpop()
end

function GuiElement.newSlider(image, cursor, x, y, sx, sy, ox, oy, padding, color)
    local newSlider = setmetatable({
        image = image, cursor = cursor, color = color;
        x = x, y = y, padding = padding;
        sx = sx, sy = sy;
        ox = ox, oy = oy
    }, GuiElement.elements.Slider)

    return newSlider
end



----------------- Selection Slider --------------------
GuiElement.elements.SelectionSlider = {
    __index = setmetatable({
        cursorPosition = 0.5, -- 0.0 - 1.0
        cursorSelection = 1,
        selections = {},
        padding = 75,       -- pixels,
        selected = false,
        tlText = "TLEFT", tText = "TOP", trText = "TRIGHT";
        blText = "BLEFT", bText = "BOTTOM", brText = "BRIGHT";

        cursor = nil        
    }, GuiElement)
}
local SelectionSlider = GuiElement.elements.SelectionSlider

-- instance methods
function SelectionSlider.__index:update(dt)
    if mouse.dragging then
        if self:getClick() then
            self.selected = true
        end
    else
        if self.selected then
            self.cursorPosition = math.floor(self.cursorPosition*(#self.selections-1)+0.5)/(#self.selections-1)
            self.cursorSelection = math.floor(self.cursorPosition * (#self.selections-1)+0.5)+1
            self.selected = false
        end
    end

    if self.selected then
        local minPos = self.x + self.padding - self.sx*self.ox
        local maxPos = self.x + self.sx - self.padding - self.sx*self.ox

        local ratio = (mouse.x - minPos) / (maxPos - minPos)

        self.cursorPosition = math.clamp(ratio, 0, 1)
    end
end

function SelectionSlider.__index:draw()
    local width, height = dimensions[1], dimensions[2]
    local ofsX, ofsY = self.ox*self.sx, self.oy*self.sy
    gpush()
        setColor(self.color[1], self.color[2], self.color[3], self.color[4] or 1)
        draw(self.image, self.x, self.y, 0, self.sx, self.sy, self.ox, self.oy)
        draw(self.cursor, self.x + self.padding + (self.sx - self.padding*2)*self.cursorPosition - ofsX, self.y+self.sy/2 - ofsY, 0, self.sy, self.sy, 0.5,0.5)
        
        for i = 1, #self.selections do
            gprint(self.selections[i], self.x + self.padding + (self.sx - self.padding*2)*((i-1)/(#self.selections-1)) - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0.5, 1)
        end

        --gprint(self.tlText, self.x - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0, 1)
        --gprint(self.trText, self.x + self.sx - ofsX, self.y - ofsY, 0, nil, self.sy/2, 1, 1)
        --gprint(self.tText, self.x + self.sx/2 - ofsX, self.y - ofsY, 0, nil, self.sy/2, 0.5, 1)
        --gprint(self.blText, self.x - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0, 0)
        --gprint(self.brText, self.x + self.sx - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 1, 0)
        --gprint(self.bText, self.x + self.sx/2 - ofsX, self.y + self.sy - ofsY, 0, nil, self.sy/2, 0.5, 0)
    gpop()
end

function SelectionSlider.__index:getSelection() 
    return self.selections[self.cursorSelection]
end

function GuiElement.newSelectionSlider(image, cursor, selections, x, y, sx, sy, ox, oy, padding, color)
    local newSlider = setmetatable({
        image = image, cursor = cursor, color = color;
        x = x, y = y, padding = padding;
        sx = sx, sy = sy;
        ox = ox, oy = oy;
        selections = selections
    }, GuiElement.elements.SelectionSlider)

    return newSlider
end

return GuiElement