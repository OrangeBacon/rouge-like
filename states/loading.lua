local GameState = require "engine.state"
local gui = require "gui"
require "gui.label"
require "gui.progress"
local loaded = require "states.loaded"

local text = {"hi", "hi", "hi"}
local progress = 0

local Loading = GameState:extend();

function Loading:init()

end

function Loading:update(dt)
	if progress >= 110 then
		self.app:pushState(loaded())
	end
	progress = progress + 0.1
	local text = "Loading: " .. math.min(math.floor(progress), 100) .."%"
	gui.label(text, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(text)/2, 50)
	gui.progressHorizontal(100, 100, love.graphics.getWidth() - 200, 40, progress)
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