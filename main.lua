local inspect = require "vendor.inspect"
local gui = require "gui"
require "gui.button"

print(inspect(gui.controls))

gui:button("hi", 0,0,5,6)

function love.update()

end

function love.draw()
	gui:draw()
end