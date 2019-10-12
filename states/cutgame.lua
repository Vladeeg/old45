local animation = require 'animation.animation'

local config = require 'conf'
local utils = require 'utils'

local module = {}

function newGame(type)
    local game = {}

    local spriteSheet = love.graphics.newImage('assets/' .. type .. '_cut.png')
    game.animations = {}
    game.animations['knife'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 0.1, {1, 2})
    game.animations['win'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 1.5, {3}, false, false)
    game.animations['lose_right'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 1.5, {4}, false, false)
    game.animations['lose_left'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 1.5, {5}, false, false)
    game.animations['blink'] = animation.new(spriteSheet, config.SCREEN_WIDTH, config.SCREEN_HEIGHT, 0.1, {6, 7, 6, 6}, false, false)

    game.animation = game.animations['knife']

    return game
end

function newKnife()
    local knife = {}
    knife.image = love.graphics.newImage('assets/knife.png')
    knife.x = love.graphics.getWidth() * 0.5
    knife.y = 70
    knife.maxvelocity = config.KNIFE_VELOCITY
    knife.velocity = knife.maxvelocity
    
    return knife
end

function updateKnife(knife, level, dt)
    knife.x = knife.x + knife.velocity * dt

    if knife.x <= level.leftOffset then
        knife.x = level.leftOffset
        knife.velocity = knife.maxvelocity
    elseif knife.x >= love.graphics.getWidth() - level.rightOffset then
        knife.x = love.graphics.getWidth() - level.rightOffset
        knife.velocity = -knife.maxvelocity
    end
end

function updateGame(level, dt)
    if level.currentState == 'attacking' then
        level.game.animation = level.game.animations['blink']
    elseif level.currentState == 'win' then
        level.game.animation = level.game.animations['win']
        if level.game.animation.finished then
            level.currentState = 'cooked'
        end
    elseif level.currentState == 'lose_right' then
        level.game.animation = level.game.animations['lose_right']
        if level.game.animation.finished then
            level.currentState = 'cooked'
        end
    elseif level.currentState == 'lose_left' then
        level.game.animation = level.game.animations['lose_left']
        if level.game.animation.finished then
            level.currentState = 'cooked'
        end
    elseif level.currentState == 'play' then
        level.game.animation = level.game.animations['knife']
    end

    animation.update(level.game.animation, dt)
end

function module.new(type)
    local level = {}
    level.game = newGame(type)
    level.knife = newKnife()
    level.leftOffset = 150
    level.rightOffset = 300

    level.currentState = 'play'
    -- game.animation = game.animations['knife']
    level.finalKnifePosition = 0
    return level
end

function module.update(level, dt)
    updateGame(level, dt)
    if level.currentState == 'play' then
        updateKnife(level.knife, level, dt)

        if love.keyboard.isDown('space') then
            level.currentState = 'attacking'
            level.finalKnifePosition = level.knife.x
        end
    elseif level.currentState == 'attacking' then
        if level.game.animations['blink'].finished then
            local screenCenter = love.graphics.getWidth() * 0.5
            if level.finalKnifePosition >= screenCenter - config.WIN_OFFSET
                and level.finalKnifePosition <= screenCenter + config.WIN_OFFSET
            then
                level.currentState = 'win'
            elseif level.finalKnifePosition < screenCenter then
                level.currentState = 'lose_left'
            elseif level.finalKnifePosition > screenCenter then
                level.currentState = 'lose_right'
            end
        end
    end
end

function module.draw(level)
    animation.draw(level.game.animation, 400)
    if level.currentState == 'play' then
        love.graphics.draw(level.knife.image, level.knife.x, level.knife.y)
    end
end

return module