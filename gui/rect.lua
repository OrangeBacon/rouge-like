local guicontrol = require "gui.guicontrol"
local ResourceManager = require "engine.resorcemanager"

local rect = guicontrol:extend()

function rect:init()
	self.image = ResourceManager:addResource("glass.png")
end

function rect:draw()
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("fill", 0, 0, 100, 100)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(self.image, 0, 0, 0, 2, 2)
end

return rect