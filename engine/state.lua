local Object = require "vendor.classic";
local gui = require "gui"

local GameState = Object:extend()

function GameState:_setApp(app)
	self.app = app
	self.gui = gui()
end

function GameState:init()
	error("init not implemented", 1)
end

function GameState:update(dt)
	error("update not implemented", 1)
end

function GameState:draw()

end

return GameState