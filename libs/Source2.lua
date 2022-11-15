-- source2 must live in libs to benefit from updating before the game
local Source2 = {
    instances = setmetatable({}, {__mode="kv"}),

    __index = {
        adjustedTime = 0,
        rawTime = 0,
        midSampleTime = 0,

        realSource = false,

        -- methods
        tell = function(self)
            return self.adjustedTime
        end,

        seek = function(self, time)
            self.rawTime = time
            self.adjustedTime = time
            self.midSampleTime = 0
            self.realSource:seek(time)
        end,

        getPitch = function(self)
            return self.realSource:getPitch()
        end,

        setPitch = function(self, val)
            self.realSource:setPitch(val)
        end,

        play = function(self)
            self.realSource:play()
        end,

        pause = function(self)
            self.realSource:pause()
            self:seek(self.adjustedTime)
        end,

        stop = function(self)
            self.realSource:stop()
            self.playing = false
        end,

        isPlaying = function(self)
            return self.realSource:isPlaying()
        end,

        getVolume = function(self)
            return self.realSource:getVolume()
        end,

        setVolume = function(self, v)
            self.realSource:setVolume(v)
        end   
    }
}


function Source2.update(dt)
    for _, sound in pairs(Source2.instances) do
        if sound.realSource:isPlaying() then
            sound.pitch = sound.realSource:getPitch()
            sound.midSampleTime = sound.midSampleTime + dt*sound.pitch

            local rt = sound.realSource:tell()
            sound.rawTime = sound.rawTime>0 and sound.rawTime or rt
            
            if rt-sound.rawTime>0 then
                print((sound.adjustedTime - rt))
                sound.midSampleTime = 0--dt*sound.pitch
            end
            
            sound.rawTime = rt
            sound.adjustedTime = rt + sound.midSampleTime

            
        end
    end
end

function Source2.new( filename, type )
    type = type or "static"
    local newSource = setmetatable({}, Source2)
    newSource.realSource = love.audio.newSource(filename, type)
    table.insert(Source2.instances, newSource)

    return newSource
end

return Source2