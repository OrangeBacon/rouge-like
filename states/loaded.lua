local GameState = require "engine.state"
local gui = require "gui"
require "gui.label"
require "gui.button"

local Loading = GameState:extend();

function Loading:init()

end

function Loading:update(dt)
  gui.label("Loaded!", 50, 50)
  gui:updateTab()

  if gui.button("Quit", 50, 100).hit then
    love.event.quit()
  end
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