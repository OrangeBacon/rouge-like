local GameState = require "engine.state"
local gui = require "gui"
require "gui.button"
require "gui.label"

local text = {"hi", "hi", "hi"}

local Loading = GameState:extend();

function Loading:init()

end

function Loading:update(dt)
	gui:label("Hello, World", {id=4}, 100, 50)
	if gui:button(text[1], {id=0}, 50, 50).hit then
		if text[1] == "hi" then
			text[1] = ":-)"
		else 
			text[1] = "hi"
		end
	end
	if gui:button(text[2], {id=1}, 50, 100).hit then
		if text[2] == "hi" then
			text[2] = ":-)"
		else 
			text[2] = "hi"
		end
	end
	if gui:button(text[3], {id=2}, 50, 150).hit then
		if text[3] == "hi" then
			text[3] = ":-)"
		else 
			text[3] = "hi"
		end
	end
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