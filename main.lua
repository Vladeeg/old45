local killingtrip = require 'states.killingtrip'

function love.load()
    love.window.setMode(1280, 720)
    love.graphics.setDefaultFilter('nearest', 'nearest')

    killingtrip.load()
end

function love.update(dt)
    killingtrip.update(dt)
end

function love.draw()
    killingtrip.draw()
end
