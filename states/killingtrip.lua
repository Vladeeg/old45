local animation = require 'animation.animation'
local bump = require 'libs.bump.bump'
local camera = require 'libs.camera'
local sti = require 'libs.sti.sti'

local config = require 'conf'
local utils = require 'utils'

local module = {}

-- PLAYER SPECIFIC {

function newPlayer(x, y)
    local _player = {}
    _player.type = 'player'
    _player.x = x or 0
    _player.y = y or 0

    _player.maxVelocityX = config.PLAYER_VELOCITY
    _player.velocityX = 0

    _player.maxVelocityY = config.GRAVITY * 8
    _player.jumpSpeed = 300
    _player.velocityY = 0
    _player.isGrounded = false

    _player.width = 21
    _player.height = 60

    _player.attacking = false
    _player.attackRefreshingTimer = 0

    _player.stealthState = false
    _player.attackState = false

    _player.spriteSheet = love.graphics.newImage('assets/demon.png')
    _player.animations = {}
    _player.animations['idle'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {1, 2, 3, 4, 5, 6}, true)
    _player.animations['run'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {7, 8, 9, 10, 11, 12}, true)
    _player.animations['stealth_activation'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    _player.animations['stealth_deactivation'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    _player.animations['mask'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {18, 19, 20, 21}, true)
    _player.animations['attack_start'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {13, 14, 15, 16, 17}, true, false)
    _player.animations['attack'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.25, {18, 19, 20, 21}, true, false)
    _player.animations['attack_end'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {17, 16, 15, 14, 13}, true, false)
    _player.animations['jump'] = animation.new(_player.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {22, 23, 24}, true, false)

    _player.animation = _player.animations['idle']
    _player.sx = config.DEFAULT_SCALE
    _player.sy = config.DEFAULT_SCALE

    return _player
end

function controlPlayer(level, player)
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
        if player.isGrounded then
            player.velocityY = -player.jumpSpeed
            player.isGrounded = false
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
        if player.animation.finished then
            player.attackState = false
            local completed = 0
            print(table.tostring(level.killedKinds) .. '\n')
            for i, killed in ipairs(level.killedKinds) do
                for j, needed in ipairs(level.neededKinds) do
                    if killed == needed then
                        completed = completed + 1
                    end
                end
            end
            print(completed .. ' ' .. #level.neededKinds .. '\n')
            if completed >= #level.neededKinds then
                print('asdkfhaskdj')
                level.win = true
            end
        end
    elseif player.stealthState == 'activating' then
        player.animation = player.animations['stealth_activation']
        if player.animation.finished then player.stealthState = 'active' end

    elseif player.stealthState == 'deactivating' then
        player.animation = player.animations['stealth_deactivation']
        if player.animation.finished then player.stealthState = false end

    elseif player.stealthState == 'active' then
        player.animation = player.animations['mask']

    elseif not player.isGrounded then
        player.animation = player.animations['jump']

    elseif math.abs(player.velocityX) > 0 then
        player.animation = player.animations['run']

    else
        player.animation = player.animations['idle']
    end
end

function updatePlayer(level, player, dt)
    controlPlayer(level, player)
    applyGravity(player, dt)
    moveObject(level.world, player, dt)
    animation.update(player.animation, dt)
end

-- } PLAYER SPECIFIC

function resolveAttack(level, dt)
    if level.player.attackState == 'attacking' then
        local goalX = level.player.x + level.player.velocityX * dt
        local goalY = level.player.y + level.player.velocityY * dt

        local actualX, actualY, collisions, len =
        level.world:check(level.player, goalX, goalY)
        for i, coll in ipairs(collisions) do
            if coll.other.type == 'vegetable' then
                if not coll.other.dead then
                    setStateVegetable(coll.other, 'death')
                    return true
                end
            end
        end
        level.player.attackState = 'end'
    end
end
-- VEGETABLE SPECIFIC {

function newVegetable(x, y, type)
    local _vegetable = {}
    _vegetable.type = 'vegetable'
    _vegetable.x = x or 0
    _vegetable.y = y or 0
    _vegetable.kind = type

    _vegetable.maxVelocityX = config.VEGETABLE_VELOCITY
    _vegetable.velocityX = 0

    _vegetable.maxVelocityY = config.GRAVITY * 8
    _vegetable.velocityY = 0
    _vegetable.isGrounded = false

    _vegetable.width = 21
    _vegetable.height = 64

    _vegetable.state = 'idle'
    _vegetable.idleTimer = love.math.random(0, 15)
    _vegetable.runTimer = 0

    _vegetable.spriteSheet = love.graphics.newImage('assets/' .. type .. '.png')
    _vegetable.animations = {}
    _vegetable.animations['idle'] = animation.new(_vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {1, 2, 3, 4}, true)
    _vegetable.animations['run'] = animation.new(_vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true)
    _vegetable.animations['run_for_your_life'] = animation.new(_vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {5, 6, 7, 8, 9, 10}, true)
    _vegetable.animations['death'] = animation.new(_vegetable.spriteSheet, config.SPRITE_WIDTH, config.SPRITE_HEIGHT, 0.1, {11, 12, 13, 14, 15, 15, 15}, true, false)
    _vegetable.animation = _vegetable.animations['idle']
    _vegetable.sx = config.DEFAULT_SCALE
    _vegetable.sy = config.DEFAULT_SCALE

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

function controlVegetable(level, v, dt)
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
            level.player.attackState = 'end'
        end
    elseif v.state == 'run_for_your_life' then
        v.velocityX = config.VEGETABLE_VELOCITY * 4 * utils.signum(v.x - level.player.x)
    end

    if not (v.velocityX == 0) then
        v.sx = utils.signum(v.velocityX) * math.abs(v.sx)
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

function updateVegetable(level, v, dt)
    controlVegetable(level, v, dt)
    applyGravity(v, dt)
    print(level)
    moveObject(level.world, v, dt)
    animation.update(v.animation, dt)
end

-- } VEGETABLE SPECIFIC

function applyGravity(object, dt)
    object.velocityY = object.velocityY + config.GRAVITY * dt
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
        else
            return 'slide'
        end
    elseif (object.type == 'vegetable') then
        if other.type == 'player' then
            return false
        elseif other.type == 'vegetable' then
            return false
        else
            return 'slide'
        end
    end
    return 'slide'
end

function moveObject(world, object, dt)
    local goalX = object.x + object.velocityX * dt
    local goalY = object.y + object.velocityY * dt

    local collisions
    object.x, object.y, collisions = world:move(object, goalX, goalY, collisionFilter)
    for i, coll in ipairs(collisions) do
        if coll.touch.y > goalY then  -- We touched below (remember that higher locations have lower y values) our intended target.
            object.velocityY = 0
            object.isGrounded = false
        elseif coll.normal.y < 0 then
            object.velocityY = 0
            object.isGrounded = true
        end
    end
end

function newWorld()
    local _map = sti('assets/map.lua', { 'bump' })
    local _world = bump.newWorld(32)
    _map:resize(love.graphics.getWidth(), love.graphics.getHeight())

    _map:bump_init(_world)

    return _map, _world
end

function drawWorld()
    -- for i, g in ipairs(ground) do
    --     love.graphics.rectangle('fill', world:getRect(g))
    -- end
end


function positionCamera(player, map)
    local mapWidth = map.width * map.tilewidth
    local mapHeight = map.height * map.tileheight
    local halfScreenWidth = love.graphics.getWidth() / 2
    local halfScreenHeight = love.graphics.getHeight() / 2
  
    local boundX = 0
    local boundY = 0

    if player.x < (mapWidth - halfScreenWidth) then
        boundX = math.max(0, player.x - halfScreenWidth)
    else
        boundX = math.min(player.x - halfScreenWidth, mapWidth - love.graphics.getWidth())
    end

    if player.y < (mapHeight - halfScreenHeight) then
        boundY = math.max(0, player.y - halfScreenHeight)
    else
        boundY = math.min(player.y - halfScreenHeight, mapHeight - love.graphics.getHeight())
    end
  
    camera:setPosition(boundX, boundY)
end

function module.new(neededKinds)
    local level = {}
    level.player = nil
    level.vegetables = {}
    level.neededKinds = neededKinds
    level.killedKinds = { }
    level.win = false
    level.map, level.world = newWorld()

    level.playerSpawn = {}
    level.vegetableSpawns = {}
    for k, object in pairs(level.map.objects) do
        if object.name == "player" then
            level.playerSpawn = object
        else
            for i, type in ipairs(config.VEGETABLE_TYPES) do
                if object.name == type then
                    level.vegetableSpawns[type] = object
                end
            end
        end
    end
    level.player = newPlayer(level.playerSpawn.x, level.playerSpawn.y)

    level.back = love.graphics.newImage('assets/back.png')

    level.spawnTimer = 0
    spawnVegetables(level)

    level.world:add(
        level.player,
        level.player.x,
        level.player.y,
        level.player.width * level.player.sx,
        level.player.height * level.player.sy
    )
    return level
end

function seesPlayerFilter(item)
    if item.type == 'player' then
        return 'slide'
    end
    return false
end

function spawnVegetables(level)
    if level.spawnTimer <= 0 then
        print(#level.vegetables)
        if #level.vegetables <= config.MAX_VEGETABLES then
            for i = 1, #config.VEGETABLE_TYPES do
                local type = config.VEGETABLE_TYPES[i]
                for i = 1, config.SPAWN_COUNT do
                    local _vegetable = newVegetable(
                        level.vegetableSpawns[type].x,
                        level.vegetableSpawns[type].y,
                        type
                    )
                    table.insert(level.vegetables, _vegetable)
                    level.world:add(_vegetable, _vegetable.x, _vegetable.y,  _vegetable.width * _vegetable.sx, _vegetable.height * _vegetable.sy)
                end
            end
        end
        print(#level.vegetables)

        level.spawnTimer = config.SPAWN_RATE
    end
end

function removeCorpses(level)
    local newVegetables = {}
    for i, v in ipairs(level.vegetables) do
        if not v.dead and v.y <= level.map.height * level.map.tileheight then
            table.insert(newVegetables, v)
        end
    end
    level.vegetables = newVegetables
end

function module.update(level, dt)
    level.map:update(dt)
    updatePlayer(level, level.player, dt)

    if level.player.y > level.map.height * level.map.tileheight then
        level.lose = true
    end

    for i, v in ipairs(level.vegetables) do
        if not v.dead then
            updateVegetable(level, v, dt)
            local vegYs = {v.y, v.y + v.height * 0.5, v.y + v.height * 0.99}
            local playerYs = {
                level.player.y,
                level.player.y + level.player.height * 0.5,
                level.player.y + level.player.height * 0.99
            }
            local seeX = level.player.x - v.x > 0
            if v.sx < 0 then
                seeX = level.player.x - v.x < 0
            end
            if playerYs[1] >= vegYs[1] - 1 and playerYs[3] <= vegYs[3] + 1 and seeX and not level.player.stealthState then
                local sees = utils.ray(
                    level.map,
                    level.world,
                    {x = v.x + v.width * 0.5, y = vegYs[1]},
                    {x = level.player.x + level.player.width * 0.5, y = playerYs[1]}
                )
                setStateVegetable(v, 'run_for_your_life')
            else
                -- print(false)
            end
        end
    end
    resolveAttack(level, dt)
    positionCamera(level.player, level.map)

    level.spawnTimer = level.spawnTimer - dt

    for i, v in ipairs(level.vegetables) do
        if v.dead and not utils.contains(level.killedKinds, v.kind) then
            table.insert(level.killedKinds, v.kind)
        end
    end
    removeCorpses(level)
    spawnVegetables(level)
end

function module.draw(level)
    camera:set()
    love.graphics.draw(level.back, camera.x, camera.y)
    level.map:draw(-camera.x, -camera.y)

    if not level.player.attackState then
        utils.drawAnimatedObject(level.player)
    elseif level.player.attackState == 'start' or level.player.attackState == 'end' then
        utils.drawAnimatedObject(level.player)
    end
    for i, v in ipairs(level.vegetables) do
        if not v.dead then utils.drawAnimatedObject(v) end
    end
    camera:unset()
end

return module
