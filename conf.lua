local config = {}

config.SPRITE_WIDTH = 64
config.SPRITE_HEIGHT = 64
config.DEFAULT_SCALE = 1

config.GRAVITY = 400
config.PLAYER_VELOCITY = 150
config.VEGETABLE_VELOCITY = 50

config.VEGETABLE_TYPES = {
    'carrot',
    'potato',
    'tomato'
}

config.SPAWN_RATE = 10
config.SPAWN_COUNT = 3
config.MAX_VEGETABLES = 10

config.FULLSCREEN_SPRITE_DIMENSIONS = {
    width = 800,
    height = 600
}

config.KNIFE_VELOCITY = 600
config.WIN_OFFSET = 50

config.PLAYER_SPRITESHEET = {
    width = 64,
    height = 64,
    image = 'assets/demon.png'
}

function love.conf(t)
	t.title = "Funny Farm"
	t.window.width = 800
	t.window.height = 600
end

return config
