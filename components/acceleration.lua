local module = {}

function module.new(x, y)
    local acceleration = {}

    acceleration.x = x or 0
    acceleration.y = y or 0

    return acceleration
end

return module