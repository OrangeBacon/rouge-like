local GameState = require "engine.state"
local rect = require "gui.rect"
local textbox = require "gui.textbox"

local Loading = GameState:extend();

function Loading:init()
	self.gui:addControl(rect())
	self.gui:addControl(textbox())
end

function Loading:update(dt)

end

return Loading