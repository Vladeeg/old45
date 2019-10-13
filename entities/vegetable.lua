local position = require 'components.position'
local velocity = require 'components.velocity'
local acceleration = require 'components.acceleration'
local config = require 'conf'
local animation = require 'animation.animation'

local module = {}

function module.new(x, y, type)
    local vegetable = {}
    vegetable.type = 'vegetable'
    vegetable.kind = type

    vegetable.position = position.new(x, y)
    vegetable.velocity = velocity.new(0, 0, config.VEGETABLE_VELOCITY, config.GRAVITY * 8)
    vegetable.acceleration = acceleration.new(0, 0)

    vegetable.isGrounded = false

    vegetable.width = 21
    vegetable.height = 64

    vegetable.state = 'idle'
    vegetable.idleTimer = love.math.random(0, 15)
    vegetable.runTimer = 0

    vegetable.spriteSheet = love.graphics.newImage('assets/' .. type .. '.png')
    vegetable.animations = {}
    vegetable.animations['idle'] = animation.new(vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {1, 2, 3, 4}, true)
    vegetable.animations['run'] = animation.new(vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true)
    vegetable.animations['run_for_your_life'] = animation.new(vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true)
    vegetable.animations['death'] = animation.new(vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {11, 12, 13, 14, 15, 15, 15}, true, false)
    vegetable.animation = vegetable.animations['idle']
    vegetable.sx = config.DEFAULT_SCALE
    vegetable.sy = config.DEFAULT_SCALE

    return vegetable
end

return module