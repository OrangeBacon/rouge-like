local Object = require "vendor.classic"
local guicontrol = require "gui.guicontrol"
local inspect = require "vendor.inspect"

local gui = Object:extend()
gui.controls = {}

-- constructor
function gui:new()
  -- mouse location
  self.mouseX = 0
  self.mouseY = 0
  self.mouseDown = {left=false, middle=false, right=false}

  -- location of top left corner of gui
  self.x = 0
  self.y = 0

  -- mouse stats last frame - used for mouse enter/exit/down/release
  self.oldMouseX = 0
  self.oldMouseY = 0
  self.oldMouseDown = {left=false, middle=false, right=false}

  -- list of functions to call on next draw call
  self.drawQueue = {n=0}
end

-- add control to static controls table
function gui.addControl(name, c)
  gui.controls[name] = c
end
function gui:addControl(name, c)
  gui.controls[name] = c
end

-- render gui
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

-- add function to be called during draw
function gui:addDraw(f, ...)
  -- increase index
  self.drawQueue.n = self.drawQueue.n + 1

  -- arguments for function
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
  self.updateMouse(love.mouse.getX(), love.mouse.getY(), 
    love.mouse.isDown(1), love.mouse.isDown(3), love.mouse.isDown(2))
end

-- set mouse x/y/down
function gui:updateMouse(x, y, left, middle, right)
  -- set old mouse stats to equal current mouse stats
  self.oldMouseX = self.mouseX
  self.oldMouseY = self.mouseY
  self.oldMouseDown = self.mouseDown

  -- update current mouse stats
  self.mouseX = x
  self.mouseY = y
  self.mouseDown = {left=left, middle=middle, right=right}
end

function gui:__index(index)
  -- get from this instance
  local get = getmetatable(self)[index]
  if get  ~= nil then 
    return get -- this instance has item with this index
  else
    -- index not found, return control if exists or nil
    return gui.controls[index] 
  end
end

return gui