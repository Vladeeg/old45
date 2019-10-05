local animation = require 'animation.animation'
local bump = require 'libs.bump.bump'

local SPRITE_WIDTH = 64
local SPRITE_HEIGHT = 64
local DEFAULT_SCALE = 2
local GRAVITY = 400
local VEGETABLE_TYPES = {
    'carrot',
    'kartoha',
    'pomidor'
}

local player = nil
local vegetables = {}

-- PLAYER SPECIFIC {

function newPlayer()
    local _player = {}
    _player.type = 'player'
    _player.x = 0
    _player.y = 0

    _player.maxVelocityX = 80
    _player.velocityX = 0

    _player.maxVelocityY = GRAVITY * 8
    _player.jumpSpeed = 300
    _player.velocityY = 0

    _player.width = 21
    _player.height = 64

    _player.attacking = false
    _player.attackRefreshingTimer = 0

    _player.stealthState = false
    _player.attackState = false

    _player.spriteSheet = love.graphics.newImage('assets/demon.png')
    _player.animations = {}
    _player.animations['idle'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {1, 2, 3, 4, 5, 6}, true)
    _player.animations['run'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {7, 8, 9, 10, 11, 12}, true)
    _player.animations['stealth_activation'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    _player.animations['stealth_deactivation'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    _player.animations['mask'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {18, 19, 20, 21}, true)
    _player.animations['attack_start'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    _player.animations['attack'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.25, {18, 19, 20, 21}, true, false)
    _player.animations['attack_end'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    _player.animations['jump'] = animation.new(_player.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {22, 23, 24}, true, false)
    _player.animation = _player.animations['idle']
    _player.sx = DEFAULT_SCALE
    _player.sy = DEFAULT_SCALE

    return _player
end

function controlPlayer()
    if not player.attackState and not player.stealthState then
        if love.keyboard.isDown('left') then
            player.velocityX = -player.maxVelocityX
            player.sx = -math.abs(player.sx)
        elseif love.keyboard.isDown('right') then
            player.velocityX = player.maxVelocityX
            player.sx = math.abs(player.sx)
        else
            player.velocityX = 0
        end
    end

    if love.keyboard.isDown('up') then
        if player.velocityY == 0 then
            player.velocityY = -player.jumpSpeed
            animation.reset(player.animations['jump'])
        end
    end

    if love.keyboard.isDown('z') then
        if not player.attackState then
            animation.reset(player.animations['attack_start'])
            player.attackState = 'start'
        elseif player.attackState == 'start' then
            animation.reset(player.animations['attack_end'])
            player.attackState = 'start'
        end
        player.velocityX = 0
    end

    if love.keyboard.isDown('x') then
        if player.stealthState == 'active' then
            animation.reset(player.animations['stealth_deactivation'])
            player.stealthState = 'deactivating'
        elseif not player.stealthState then
            animation.reset(player.animations['stealth_activation'])
            player.stealthState = 'activating'
        end
        player.velocityX = 0
    end

    if player.attackState == 'start' then
        player.animation = player.animations['attack_start']
        if player.animation.finished then player.attackState = 'attacking' end

    elseif player.attackState == 'end' then
        player.animation = player.animations['attack_end']
        if player.animation.finished then player.attackState = false end

    elseif player.stealthState == 'activating' then
        player.animation = player.animations['stealth_activation']
        if player.animation.finished then player.stealthState = 'active' end

    elseif player.stealthState == 'deactivating' then
        player.animation = player.animations['stealth_deactivation']
        if player.animation.finished then player.stealthState = false end

    elseif player.stealthState == 'active' then
        player.animation = player.animations['mask']

    elseif math.abs(player.velocityY) > 0 then
        player.animation = player.animations['jump']

    elseif math.abs(player.velocityX) > 0 then
        player.animation = player.animations['run']

    else
        player.animation = player.animations['idle']
    end
end

function updatePlayer(dt)
    -- if player.attackState == 'start' and player.animation.finished then
    --     player.attackState = 'end'
    -- end
    -- if player.attackState == 'end' and player.animation.finished then
    --     player.attackState = false
    -- end
    -- if player.attackRefreshingTimer > 0 then
    --     player.attackRefreshingTimer = player.attackRefreshingTimer - dt
    -- end

    controlPlayer()
    applyGravity(player, dt)
    moveObject(player, dt)
    animation.update(player.animation, dt)
end

-- } PLAYER SPECIFIC

function table.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    end
    return "table" == type(v) and table.tostring(v) or tostring(v)
end
function table.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return '"' .. k .. '"'
    end
    return "[" .. table.val_to_str(k) .. "]"
end
function table.tostring(tbl)
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table.val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
                         table.key_to_str(k) .. ":" .. table.val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end

function resolveAttack(dt)
    if player.attackState == 'attacking' then
        local goalX = player.x + player.velocityX * dt
        local goalY = player.y + player.velocityY * dt

        local actualX, actualY, collisions, len =
            world:check(player, goalX, goalY)
        for i, coll in ipairs(collisions) do
            if coll.other.type == 'vegetable' then
                if not coll.other.dead then
                    setStateVegetable(coll.other, 'death')
                    return true
                end
            end
        end
        player.attackState = 'end'
    end
end

function drawAnimatedObject(object)
    animation.draw(object.animation, object.x, object.y, 0, object.sx, object.sy)
end

function signum(x)
    if x == 0 then return 0 end
    if x > 0 then
        return 1
    else
        return -1
    end
end

-- VEGETABLE SPECIFIC {

function newVegetable(x, y, type)
    local _vegetable = {}
    _vegetable.type = 'vegetable'
    _vegetable.x = x or 0
    _vegetable.y = y or 0

    _vegetable.maxVelocityX = 50
    _vegetable.velocityX = 0

    _vegetable.maxVelocityY = GRAVITY * 8
    _vegetable.velocityY = 0

    _vegetable.width = 21
    _vegetable.height = 64

    _vegetable.state = 'idle'
    _vegetable.idleTimer = love.math.random(0, 15)
    _vegetable.runTimer = 0

    _vegetable.spriteSheet = love.graphics.newImage('assets/' .. type .. '.png')
    _vegetable.animations = {}
    _vegetable.animations['idle'] = animation.new(_vegetable.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {1, 2, 3, 4}, true)
    _vegetable.animations['run'] = animation.new(_vegetable.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true)
    _vegetable.animations['death'] = animation.new(_vegetable.spriteSheet, SPRITE_WIDTH, SPRITE_HEIGHT, 0.1, {11, 12, 13, 14, 15}, true, false)
    _vegetable.animation = _vegetable.animations['idle']
    _vegetable.sx = DEFAULT_SCALE
    _vegetable.sy = DEFAULT_SCALE

    return _vegetable
end

function setStateVegetable(v, state)
    v.state = state
    v.animation = v.animations[state]

    if state == 'death' then
        v.velocityX = 0
    elseif state == 'idle' then
        v.velocityX = 0
    end
end

function controlVegetable(v, dt)
    if v.state == 'idle' then
        if v.idleTimer <= 0 then
            v.runTimer = love.math.random(5, 7)
            if love.math.random() < 0.5 then
                v.velocityX = math.abs(v.maxVelocityX)
            else
                v.velocityX = -math.abs(v.maxVelocityX)
            end
        else
            v.idleTimer = v.idleTimer - dt
        end
    elseif v.state == 'run' then
        if v.runTimer <= 0 then
            if love.math.random() < 0.25 then
                v.idleTimer = love.math.random(5, 7)
                setStateVegetable(v, 'idle')
            else
                v.runTimer = love.math.random(5, 7)
                v.velocityX = -v.velocityX
            end
        end
    elseif v.state == 'death' then
        if v.animations['death'].finished then
            v.dead = true
            player.attackState = 'end'
        end
    end

    if not (v.velocityX == 0) then
        v.sx = signum(v.velocityX) * math.abs(v.sx)
    end

    if math.abs(v.velocityX) > 0 then
        setStateVegetable(v, 'run')
        if v.runTimer > 0 then
            v.runTimer = v.runTimer - dt
        end
    else
        if not v.state == 'death' then
            setStateVegetable(v, 'idle')
        end
    end
end

function updateVegetable(v, dt)
    controlVegetable(v, dt)
    applyGravity(v, dt)
    moveObject(v, dt)
    animation.update(v.animation, dt)
end

-- } VEGETABLE SPECIFIC

function applyGravity(object, dt)
    object.velocityY = object.velocityY + GRAVITY * dt
    if object.velocityY > object.maxVelocityY then
        object.velocityY = object.maxVelocityY
    end
end

function collisionFilter(object, other)
    if (object.type == 'player') then
        if other.type == 'player' then
            return false
        elseif other.type == 'vegetable' then
            return false
        elseif other.type == 'ground' then
            return 'slide'
        end
    elseif (object.type == 'vegetable') then
        if other.type == 'player' then
            return false
        elseif other.type == 'vegetable' then
            return false
        elseif other.type == 'ground' then
            return 'slide'
        end
    end
end

function moveObject(object, dt)
    local goalX = object.x + object.velocityX * dt
    local goalY = object.y + object.velocityY * dt

    local collisions
    object.x, object.y, collisions = world:move(object, goalX, goalY, collisionFilter)
    for i, coll in ipairs(collisions) do
        if coll.normal.y < 0 then object.velocityY = 0 end
    end
end

function newWorld()
    local _world = bump.newWorld(16) -- 16 is our tile size

    ground = {}
    ground[1] = {}
    ground[1].type = 'ground'

    _world:add(ground[1], 0, 248, 800, 32)
    return _world
end

function drawWorld()
    for i, g in ipairs(ground) do
        love.graphics.rectangle('fill', world:getRect(g))
    end
end

function love.load()
    love.window.setMode(1280, 720)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    world = newWorld()
    player = newPlayer()
    back = love.graphics.newImage('assets/back.png')

    for i = 1, 10 do
        local type = VEGETABLE_TYPES[love.math.random(1, #VEGETABLE_TYPES)]
        local _vegetable = newVegetable(love.math.random(10, 800), nil, type)
        vegetables[i] = _vegetable
        world:add(_vegetable, _vegetable.x, _vegetable.y,  _vegetable.width * _vegetable.sx, _vegetable.height * _vegetable.sy)
    end

    world:add(player, player.x, player.y, player.width * player.sx, player.height * player.sy)
end

function love.update(dt)
    updatePlayer(dt)
    for i, v in ipairs(vegetables) do
        if not v.dead then updateVegetable(v, dt) end
    end
    resolveAttack(dt)
end

function love.draw()
    love.graphics.draw(back, 0, 0)
    drawWorld()
    if not player.attackState then
        drawAnimatedObject(player)
    elseif player.attackState == 'start' or player.attackState == 'end' then
        drawAnimatedObject(player)
    end
    for i, v in ipairs(vegetables) do
        if not v.dead then drawAnimatedObject(v) end
    end
end
