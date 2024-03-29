local config = require 'conf'
local animation = require 'animation.animation'

local module = {}

function module.new(x, y, type)
    local vegetable = {}
    vegetable.type = 'vegetable'
    vegetable.x = x or 0
    vegetable.y = y or 0
    vegetable.kind = type

    vegetable.velocity = {}
    vegetable.velocity.x = 0
    vegetable.velocity.y = 0

    vegetable.maxVelocity = {}
    vegetable.maxVelocity.x = config.VEGETABLE_VELOCITY
    vegetable.maxVelocity.y = config.GRAVITY * 8

    vegetable.isGrounded = false

    vegetable.width = 21
    vegetable.height = 64

    vegetable.state = 'idle'
    vegetable.idleTimer = love.math.random(0, 15)
    vegetable.runTimer = 0

    vegetable.spriteSheet = love.graphics.newImage('assets/' .. type .. '.png')
    vegetable.animations = {}
    local spriteWidth = config.SPRITE_WIDTH
    local offsetX = (spriteWidth - vegetable.width) * 0.5

    vegetable.animations['idle'] = animation.new(vegetable.spriteSheet, spriteWidth, config.SPRITE_HEIGHT, 0.1, {1, 2, 3, 4}, true, nil, offsetX)
    vegetable.animations['run'] = animation.new(vegetable.spriteSheet, spriteWidth, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true, nil, offsetX)
    vegetable.animations['run_for_your_life'] = animation.new(vegetable.spriteSheet, spriteWidth, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true, nil, offsetX)
    vegetable.animations['death'] = animation.new(vegetable.spriteSheet, spriteWidth, config.SPRITE_HEIGHT, 0.1, {11, 12, 13, 14, 15, 15, 15}, true, false, offsetX)
    vegetable.animation = vegetable.animations['idle']
    vegetable.sx = 1
    vegetable.sy = 1

    return vegetable
end

return module
