local animationModule = {}

function animationModule.reset(animation)
    animation.currentTime = 0
    animation.finished = false
end

function animationModule.update(animation, dt)
    animation.currentTime = animation.currentTime + dt

    if animation.currentTime >= animation.duration then
        if animation.repeatable then
            animation.currentTime = animation.currentTime - animation.duration
        else
            animation.currentTime = animation.duration - dt
            animation.finished = true
        end
    end
end

function animationModule.draw(animation, x, y, r, sx, sy, ox, oy)
    local frameNum = math.floor(animation.currentTime / animation.duration * #animation.frames) + 1
    local spriteNum = animation.frames[frameNum]
    local quad = animation.quads[spriteNum]
    local _, _, width, _ = quad:getViewport()
    local flipMultiplier = animation.flip and -1 or 1

    r = r or 0
    local sx = flipMultiplier * (sx or 1)
    local sy = sy or 1

    local ox = (sx < 0 and -sx * width - animation.offset.x or animation.offset.x) + (ox or 0)
    local oy = (sy < 0 and -sy * height - animation.offset.y or animation.offset.y) + (oy or 0)
    love.graphics.draw(animation.spriteSheet, quad, x, y, r, sx, sy, ox, oy, kx, ky)
end

function animationModule.new(image, width, height, frameDuration, frames, flip, repeatable, offsetX, offsetY)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
    animation.flip = flip
    
    animation.offset = {}
    animation.offset.x = offsetX or 0
    animation.offset.y = offsetY or 0
    
    animation.repeatable = true
    if repeatable == false then
        animation.repeatable = false
    end
    
    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end
    
    local function fillArray()
        local arr = {}
        for i = 1, #animation.quads do
            arr[i] = i
        end
        return arr
    end

    animation.frames = frames or fillArray()
    animation.duration = frameDuration * #frames or #frames
    animation.currentTime = 0

    return animation
end

return animationModule
