local module = {}

function module.new(x, y, maxX, maxY)
    local velocity = {}

    velocity.x = x or 0
    velocity.y = y or 0
    
    velocity.max = {}
    velocity.max.x = maxX or 0
    velocity.max.y = maxY or 0

    return velocity
end

return module