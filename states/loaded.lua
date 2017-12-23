local GameState = require "engine.state"
local gui = require "gui"
require "gui.label"
require "gui.button"

local Loading = GameState:extend();

function Loading:init()
  self.splash = love.graphics.newImage("splash.png")
end

function Loading:update(dt)
  gui.label("Loaded!", 50, 50)
  gui:updateTab()

  if gui.button("Quit", 50, 100, love.graphics.getWidth() - 100, 100).hit then
    love.event.quit()
  end
end

function Loading:draw()
  local sx = love.graphics.getWidth() / self.splash:getWidth()
  local sy = love.graphics.getHeight() / self.splash:getHeight()
  local scale = math.max(sx, sy)

  love.graphics.draw(self.splash, 0, 0, 0, scale, scale)
	gui:draw()
end

function Loading:keypressed(t)
	gui:keyDown(t)
end

function Loading:textinput(t)
	gui:textinput(t)
end

return Loading