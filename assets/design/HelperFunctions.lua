-- negative sx and sy values do default behavior; positive values are pixel measurements
-- ox and oy values between 0 and 1 will be treated as a ratio to image size (anchor point)
_G.drawImage = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    love.graphics.draw(
        drawable,
        ignoreSnap and (x or 0) or math.floor(x or 0), ignoreSnap and (y or 0) or math.floor(y or 0), r,
        sx and (sx < 0 and -sx or 1 / drawable:getWidth() * sx),
        sy and (sy < 0 and -sy or 1 / drawable:getHeight() * sy),
        ox and (ox <= 1 and drawable:getWidth() * ox or ox),
        oy and (oy <= 1 and drawable:getHeight() * oy or oy),
        kx, ky   
    )
end

-- ox/oy and sx/sy alt rules always apply here
_G.drawImage2 = function(drawable, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    love.graphics.draw(
        drawable,
        ignoreSnap and (x or 0) or math.floor(x or 0), ignoreSnap and (y or 0) or math.floor(y or 0), r,
        sx and 1 / drawable:getWidth() * sx,
        sy and 1 / drawable:getHeight() * sy,
        ox and drawable:getWidth() * ox,
        oy and drawable:getHeight() * oy,
        kx, ky   
    )
end

_G.drawText = function(text, x, y, r, sx, sy, ox, oy, kx, ky, ignoreSnap)
    if sx and not sy then
        sy = sx / (Libs.Asset.currentFont:getWidth(text)/Libs.Asset.currentFont:getHeight())
    elseif sy and not sx then
        sx = sy * (Libs.Asset.currentFont:getWidth(text)/Libs.Asset.currentFont:getHeight())
    end
    love.graphics.print(
        text,
        ignoreSnap and (x or 0) or math.floor(x or 0), ignoreSnap and (y or 0) or math.floor(y or 0), r,
        sx and (sx < 0 and -sx or 1 / Libs.Asset.currentFont:getWidth(text) * sx),
        sy and (sy < 0 and -sy or 1 / Libs.Asset.currentFont:getHeight() * sy),
        ox and Libs.Asset.currentFont:getWidth(text) * ox,
        oy and Libs.Asset.currentFont:getHeight() * oy,
        kx, ky   
    )    
end

function _G.drawStuff()
    return love.graphics.push,
           love.graphics.pop,
           drawImage,
           love.graphics.setColor,
           drawText
end

function _G.generateTimestamp(time, h, m, ms)
    local hours = tostring(math.floor(time / 60 / 60)); hours = string.rep("0", 2-#hours)..hours
    local minutes = tostring(math.floor(time / 60) % (h and math.huge or 60)); minutes = string.rep("0", 2-#minutes)..minutes
    local seconds = tostring(math.floor(time) % 60); seconds = string.rep("0", 2-#seconds)..seconds
    local milliseconds = tostring(math.floor((time - math.floor(time))*100)); milliseconds = milliseconds .. string.rep("0", 2-#milliseconds)
    return (h and hours..":" or "")..(m and minutes..":" or "")..seconds..(ms and "."..milliseconds or "")
end