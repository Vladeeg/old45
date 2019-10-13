local Killingtrip = require 'states.killingtrip'
local Cutgame = require 'states.cutgame'
local Cooking = require 'states.cooking'
local Mainmenu = require 'states.mainmenu'

local config = require 'conf'

local currentLevel
local cooked = 0
local killed = 0
local neededKinds = { 'carrot', 'tomato', 'potato' }

local levels = {
    mainmenu = nil,
    killingtrip = nil,
    cutgame = nil,
    cooking = nil
}

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    levels.mainmenu = Mainmenu.new()
    currentLevel = 'mainmenu'
end

-- function neededKinds()
--     return { 'carrot', 'tomato' }
-- end

function love.update(dt)
    if love.keyboard.isDown('escape') then
        -- killingtrip.neededKinds = neededKinds()
        levels.mainmenu = Mainmenu.new()
        currentLevel = 'mainmenu'
    end
    if currentLevel == 'mainmenu' then
        Mainmenu.update(levels.mainmenu, dt)
        if love.keyboard.isDown('space') then
            -- print('kjasdgf')
            levels.killingtrip = Killingtrip.new(neededKinds)
            -- killingtrip.neededKinds = neededKinds()
            currentLevel = 'killingtrip'
        end
    elseif currentLevel == 'killingtrip' then
        if levels.killingtrip.win then
            levels.cutgame = Cutgame.new(neededKinds[1])
            currentLevel = 'cutgame'
        elseif levels.killingtrip.lose then
            levels.mainmenu = Mainmenu.new()
            currentLevel = 'mainmenu'
        end
        Killingtrip.update(levels.killingtrip, dt)
    elseif currentLevel == 'cutgame' then
        Cutgame.update(levels.cutgame, dt)
        if levels.cutgame.currentState == 'cooked' then
            print('win')
            if killed >= 1 and killed < #neededKinds then
                print('shouldupdate')

                levels.cutgame = Cutgame.new(neededKinds[killed + 1])
                currentLevel = 'cutgame'
            elseif killed >= #neededKinds then
                levels.cooking = Cooking.new()
                currentLevel = 'cooking'
            end
            killed = killed + 1
        end
    elseif currentLevel == 'cooking' then
        Cooking.update(levels.cooking, dt)
        if levels.cooking.cooked then
            levels.mainmenu = Mainmenu.new()
            currentLevel = 'mainmenu'
        end
    end
end

function love.draw()
    if currentLevel == 'mainmenu' then
        Mainmenu.draw(levels.mainmenu)
    elseif currentLevel == 'killingtrip' then
        Killingtrip.draw(levels.killingtrip)
    elseif currentLevel == 'cutgame' then
        Cutgame.draw(levels.cutgame)
    elseif currentLevel == 'cooking' then
        Cooking.draw(levels.cooking)
    end
end
