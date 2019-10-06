local animation = require 'animation.animation'

local module = {}

function module.drawAnimatedObject(object)
    animation.draw(object.animation, object.x, object.y, 0, object.sx, object.sy)
end

function module.signum(x)
    if x == 0 then return 0 end
    if x > 0 then
        return 1
    else
        return -1
    end
end

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

function module.ray(map, world, start, _end, filter, resolution)
    local resolution = resolution or 1
    local step = map.tilewidth

    if map.tileheight < map.tilewidth then
        step = map.tileheight
    end

    step = step / resolution
    local deltaX = _end.x - start.x
    local deltaY = _end.y - start.y
    local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY)
    local steps = math.ceil(distance / step)
    local stepX = deltaX / steps
    local stepY = deltaY / steps
    local curX = start.x - stepX
    local curY = start.y - stepY
    local i = 0

    while i < steps do
        curX = curX + stepX;
        curY = curY + stepY;

        if curX == _end.x and curY == _end.y then
            return true
        end

        local items, len = world:queryPoint(curX, curY, filter)
        
        if len > 0 then
            return false
        end
        
        i = i + 1;
    end

    return true;
end

return module
