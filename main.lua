local gui = require "gui"
local inspect = require "vendor.inspect"
require "gui.button"

function love.update()
	local b = gui:button("hi", 50, 50, 50, 50)
	print(b.state)
	if b.state == "active" then
		gui:button(":-)", 100, 50, 50, 50)
	end
end

function love.draw()
	gui:draw()
end