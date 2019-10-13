local position = require 'components.position'
local velocity = require 'components.velocity'
local acceleration = require 'components.acceleration'
local config = require 'conf'
local animation = require 'animation.animation'

local module = {}

function module.new(x, y)
    local player = {}
    player.type = 'player'

    player.position = position.new(x, y)
    player.velocity = velocity.new(0, 0, config.PLAYER_VELOCITY, config.GRAVITY * 8)
    player.acceleration = acceleration.new(0, 0)

    player.jumpSpeed = 300
    player.velocityY = 0
    player.isGrounded = false

    player.width = 21
    player.height = 60

    player.attacking = false
    player.attackRefreshingTimer = 0

    player.stealthState = false
    player.attackState = false

    player.spriteSheet = love.graphics.newImage('assets/demon.png')
    player.animations = {}
    player.animations['idle'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {1, 2, 3, 4, 5, 6}, true)
    player.animations['run'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {7, 8, 9, 10, 11, 12}, true)
    player.animations['stealth_activation'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    player.animations['stealth_deactivation'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    player.animations['mask'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {18, 19, 20, 21}, true)
    player.animations['attack_start'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    player.animations['attack'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.25, {18, 19, 20, 21}, true, false)
    player.animations['attack_end'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    player.animations['jump'] = animation.new(player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {22, 23, 24}, true, false)

    player.animation = player.animations['idle']
    player.sx = config.DEFAULT_SCALE
    player.sy = config.DEFAULT_SCALE

    return player
end

return module