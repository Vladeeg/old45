local animation = require 'animation.animation'

local config = require 'conf'
local utils = require 'utils'

local module = {}

function module.new()
    local _module = {}
    _module.currentState = false
    _module.back = love.graphics.newImage('assets/main.png')    
    return _module
end

function module.update(mainmenu, dt)
    if love.keyboard.isDown('space') then
        -- print('adkjfhadskjl')
        mainmenu.currentState = 'run'
    end
end

function module.draw(mainmenu)
    love.graphics.draw(mainmenu.back)
end

return module