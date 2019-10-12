local animation = require 'animation.animation'

local config = require 'conf'
local utils = require 'utils'

local module = {}

function new_game(type)
    local _game = {}

    local spriteSheet = love.graphics.newImage('assets/COOK.png')
    _game.animations = {}
    _game.animations['COOK'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 0.1,
        {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29},
        false,
        false
    )

    _game.animation = _game.animations['COOK']

    return _game
end

function module.new(type)
    local level = {}
    level.game = new_game()
    level.currentState = 'COOK'
    return level
end

function module.update(level, dt)
    animation.update(level.game.animation, dt)
    if level.game.animation.finished then
        level.cooked = true
    end
end

function module.draw(level)
    animation.draw(level.game.animation, 400)
end

return module