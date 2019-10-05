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

function animationModule.draw(animation, x, y, r, sx, sy)
    local frameNum = math.floor(animation.currentTime / animation.duration * #animation.frames) + 1
    local spriteNum = animation.frames[frameNum]
    local quad = animation.quads[spriteNum]
    local _, _, width, _ = quad:getViewport()
    local flipMultiplier = 1
    if animation.flip then
        flipMultiplier = -1
    end 
    love.graphics.draw(animation.spriteSheet, quad, x, y, r, flipMultiplier * sx, sy, width * 0.5, oy, kx, ky)
end

function animationModule.new(image, width, height, frameDuration, frames, flip, repeatable)
    local animation = {}
    animation.spriteSheet = image
    animation.quads = {}
    animation.flip = flip
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
