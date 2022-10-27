local Logo = {}
Logo.prototype = {
    scale = 2;
    position =  {x = 50, y = 50}, -- entire logo position
    p =         {x = 0, y = 0}, -- data for P
    d =         {x = 0, y = 48.6},  -- data for D
    u =         {x = 44.2, y = 30.4},  -- etc.
    l =         {x = 76.2, y = 2.4},
    s =         {x = 90.2, y = 30.4},
    e =         {x = 118.2, y = 30.4},
    r =         {x = 42.2, y = 66.4},
    o =         {x = 68.2, y = 66.4},
    p2 =        {x = 102.2, y = 66.4},
    underline = {x = 42.2, y = 64.4},

    oScale = 1,
    pOffset = 0,
    arrowOffset = 0
}
Logo.__index = Logo.prototype

local asset
local draw = drawImage
function Logo.prototype:draw()
    asset = asset or Asset
    local s = self.scale
    local px, py = self.position.x, self.position.y
    draw(asset.image.letter_d, (self.d.x+px)*s, (self.d.y+py+self.pOffset/10)*s, 0, 40*s, 60*s)
    draw(asset.image.letter_p, (self.p.x+px)*s, (self.p.y+py+self.pOffset)*s, 0, 40*s, 60*s)
    draw(asset.image.letter_u, (self.u.x+px)*s, (self.u.y+py+self.pOffset/4)*s, 0, 28*s, 32*s)
    draw(asset.image.letter_l_main, (self.l.x+px)*s, (self.l.y+py)*s, 0, 10*s, 64*s)
    draw(asset.image.letter_s, (self.s.x+px)*s, (self.s.y+py+self.pOffset/4)*s, 0, 24*s, 32*s)
    draw(asset.image.letter_e, (self.e.x+px)*s, (self.e.y+py+self.pOffset/4)*s, 0, 24*s, 32*s)
    draw(asset.image.letter_r, (self.r.x+px)*s, (self.r.y+py+self.pOffset/6)*s, 0, 24*s, 32*s)
    draw(asset.image.letter_p_main, (self.p2.x+px-6)*s, (self.p2.y+py+self.pOffset/6)*s, 0, 38*s, 58*s)
    draw(asset.image.letter_p_arrow, (self.p2.x+px-6)*s, (self.p2.y+py+self.arrowOffset)*s, 0, 38*s, 58*s)
    draw(asset.image.logo_underline, (self.underline.x+px)*s, (self.underline.y+py)*s, 0, 102*s, 44*s)
    draw(asset.image.letter_o, (self.o.x+px+16)*s, (self.o.y+py+16)*s, 0, 32*s*self.oScale, 32*s*self.oScale, 0.5, 0.5)

end

function Logo.prototype:update(dt)
    self.oScale = self.oScale - (self.oScale - 1)*dt*4
    self.pOffset = self.pOffset - self.pOffset*dt*4
    self.arrowOffset = self.arrowOffset - self.arrowOffset*dt*4
end


function Logo.prototype:pulse()
    self.oScale = 1.35
    self.arrowOffset = 10
    self.pOffset = 10
end

----- Asset loading bit
local loadedAssets = false
local function loadAssets()
    if loadedAssets then return end
    local asset = Asset
    loadedAssets = true
    for _, path in ipairs({
        "mainpath/logo/letter_p.png",
        "mainpath/logo/letter_d.png",
        "mainpath/logo/letter_e.png",
        "mainpath/logo/letter_l_main.png",
        "mainpath/logo/letter_o.png",
        "mainpath/logo/letter_p_arrow.png",
        "mainpath/logo/letter_p_main.png",
        "mainpath/logo/letter_r.png",
        "mainpath/logo/letter_s.png",
        "mainpath/logo/letter_u.png",
        "mainpath/logo/logo_underline.png"
    }) do
        asset.loadImage(path)
    end        
end

-- Constructor for 
function Logo.new()
    local newField = setmetatable({}, Logo)
    
    -- load related assets, if applicable
    loadAssets()

    return newField
end






return Logo