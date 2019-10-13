local module = {}

function module.new(x, y)
    local position = {}
    
    position.x = x or 0
    position.y = y or 0
    
    return position
end

return module