local Object = require "vendor.classic"
local guicontrol = require "gui.guicontrol"
local inspect = require "vendor.inspect"

local gui = Object:extend()
gui.controls = {}

function gui:new()
  self.drawQueue = {n=0}
end

function gui.addControl(name, c)
  gui.controls[name] = c
end
function gui:addControl(name, c)
  gui.controls[name] = c
end

function gui:draw()
  -- stop adding new controls
  self.exitFrame()
  
  -- save all state
  love.graphics.push("all")

  -- run all functions in draw queue and reset it
  for i = self.drawQueue.n, 1, -1 do
    self.drawQueue[i]()
  end
  self.drawQueue = {n=0}

  -- restore state
  love.graphics.pop()

  -- prepare to add new controls
  self.enterFrame()
end

function gui:addDraw(f, ...)
  -- increase index
  self.drawQueue.n = self.drawQueue.n + 1

  local args = {...}
  local arglen = select('#', ...)

  -- function to run draw with all provided arguemnts
  self.drawQueue[self.drawQueue.n] = function()
    f(unpack(args, 1, arglen))
  end
end

function gui:exitFrame()
end

function gui:enterFrame()
  height = love.graphics.getHeight()
end

function gui:__tostring()
  return "gui"
end

function gui:__index(index)
  local get = getmetatable(self)[index]
  if get  ~= nil then 
    return get
  else
    return gui.controls[index] 
  end
end

return gui