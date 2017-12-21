local GameState = require "engine.state"
local gui = require "gui"
require "gui.button"
require "gui.label"
require "gui.progress"

local text = {"hi", "hi", "hi"}
local progress = 0

local Loading = GameState:extend();

function Loading:init()

end

function Loading:update(dt)
	progress = (progress + 1) % 100
	gui.progressVertical(100, 0, 500, 40, progress)
	gui:updateTab()
end

function Loading:draw()
	gui:draw()
end

function Loading:keypressed(t)
	gui:keyDown(t)
end

function Loading:textinput(t)
	gui:textinput(t)
end

return Loading