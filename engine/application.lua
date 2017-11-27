local Object = require "vendor.classic"
local StateObject = require "engine.state"

local Application = Object:extend()
local created = false

function Application:new(State)
	if created then
		error("cannot create more than one application", 3)
	end
	created = true
	self.state_stack = {}
	self:pushState(State)
end

function Application:_setCallbacks()
	local new = self.state_stack[#self.state_stack]
	new:init()
	love.update = function(dt)
		new.gui:update(dt)
		new.update(dt)
	end
	love.draw = function()
		new.gui:draw()
	end
end

function Application:pushState(State)
	State = State or error("no initial state provided", 3)
	if not State.__constructed then
		error("non constructed class provided", 3)
	end
	if not State:is(StateObject) then
		error("non state class provided", 3)
	end
	State:_setApp(self)
	self.state_stack[#self.state_stack+1] = State
	self:_setCallbacks()
end

function Application:popState()
	table.remove(self.state_stack)
	self:_setCallbacks()
end

return Application