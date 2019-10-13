local module = {}

function module.new(target, width, height, scale)
    local camera = {}

    camera.target = target
    camera.x = camera.target.x or 0
    camera.y = camera.target.y or 0
    camera.scale = scale or 1

    camera.width = width or love.graphics.getWidth()
    camera.height = height or love.graphics.getHeight()

    camera.topLeft = {}
    camera.bottomRight = {}
    
    return camera
end

function module.setScrollBoundsRect(camera, topLeftX, topLeftY, bottomRightX, bottomRightY)
    camera.topLeft = {
        x = topLeftX,
        y = topLeftY
    }
    camera.bottomRight = {
        x = bottomRightX,
        y = bottomRightY
    }
end

function module.set(camera)
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)
end

function module.unset()
    love.graphics.pop()
end

function module.update(camera, dt)
    local boundsWidth = camera.bottomRight.x - camera.topLeft.x
    local boundsHeight = camera.bottomRight.y - camera.topLeft.y
    local halfScreenWidth = camera.width / 2
    local halfScreenHeight = camera.height / 2
  
    local newX = 0
    local newY = 0

    if camera.target.x < (boundsWidth - halfScreenWidth) then
        newX = math.max(0, camera.target.x - halfScreenWidth)
    else
        newX = math.min(camera.target.x - halfScreenWidth, boundsWidth - camera.width)
    end

    if camera.target.y < (boundsHeight - halfScreenHeight) then
        newY = math.max(0, camera.target.y - halfScreenHeight)
    else
        newY = math.min(camera.target.y - halfScreenHeight, boundsHeight - camera.height)
    end
  
    camera.x = newX
    camera.y = newY
end

return module
