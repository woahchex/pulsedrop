-- source2 must live in libs to benefit from updating before the game
local settings
local clamp = math.clamp
local Source2 = {
    instances = setmetatable({}, {__mode="kv"}),

    __index = {
        adjustedTime = 0,
        rawTime = 0,
        midSampleTime = 0,
        realVolume = 1,

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
            self.realSource:stop()
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
            return self.realVolume
        end,

        setVolume = function(self, v)
            self.realVolume = v
            self.realSource:setVolume(clamp(self.realVolume * settings.data.masterVolume * (self.isSong and settings.data.musicVolume or settings.data.sfxVolume), 0, 2))
        end   
    }
}

function Source2.update(dt)
    settings = settings or Settings
    for _, sound in pairs(Source2.instances) do
        if sound.realSource:isPlaying() then
            sound.pitch = sound.realSource:getPitch()
            sound.midSampleTime = sound.midSampleTime + dt*sound.pitch

            local rt = sound.realSource:tell()
            sound.rawTime = sound.rawTime>0 and sound.rawTime or rt
            
            if rt-sound.rawTime>0 then
                sound.midSampleTime = 0--dt*sound.pitch
            end
            
            sound.rawTime = rt
            sound.adjustedTime = rt + sound.midSampleTime
            
            sound.realSource:setVolume(sound.realVolume * settings.data.masterVolume * (sound.isSong and settings.data.musicVolume or settings.data.sfxVolume) - settings.xPosition/3)
        end
    end
end

function Source2.new( filename, type )
    type = type or "static"
    local newSource = setmetatable({}, Source2)
    newSource.realSource = love.audio.newSource(filename, type)
    newSource.isSong = type == "stream"
    newSource.realSource:setVolume(Settings.data.masterVolume * (newSource.isSong and Settings.data.musicVolume or Settings.data.sfxVolume))
    table.insert(Source2.instances, newSource)

    return newSource
end

return Source2