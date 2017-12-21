local Object = require "vendor.classic"
local inspect = require "vendor.inspect"

table.indexOf = function( t, object )
  if "table" == type( t ) then
    for i = 1, #t do
      if object == t[i] then
        return i
      end
    end
    return -1
  else
    error("table.indexOf expects table for first argument, " .. type(t) .. " given")
  end
end

local gui = Object:extend()
gui.controls = {}

local none = {}

--[[
  Gui control states:
  - hovered : mouse is above control
  - active  : hovered and mouse down until mouse release
  - hit     : hovered and mouse clicked in this frame
  - focus   : has keyboard focus, set if active/hit
  - none    : none of the above 
]]


-- constructor
function gui:new()
  -- mouse location
  self.mouseX = 0
  self.mouseY = 0
  self.mouseDown = false

  -- location of top left corner of gui
  self.x = 0
  self.y = 0

  -- hovered/active last frame
  self.lastHovered = nil
  self.lastActive = nil

  -- currently hovered/active
  self.hovered = nil
  self.active = nil
  self.hit = nil
  self.focus = nil

  -- list of functions to call on next draw call
  self.drawQueue = {n=0}

  self.keyPressed = ""
  self.text = ""

  self.escExit = true

  self.idx = 0

  self.tabDisabled = false

  self.tabOrder = {}

  self.theme = {
    hovered = {bg = { 50,153,187}, fg = {255,255,255}},
    active =  {bg = { 66,300, 66}, fg = {255,255,255}},
    hit =     {bg = {255,153,187}, fg = {255,255,255}},
    focus =   {bg = {100,100,187}, fg = {255,255,255}},
    none =    {bg = { 66, 66, 66}, fg = {188,188,188}},
  }
end

-- add control to static controls table
function gui.addControl(name, c)
  gui.controls[name] = c
end

-- render gui
function gui:draw()
  -- stop adding new controls
  self:exitFrame()
  
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
  self:enterFrame()
end

function gui:id()
  self.id = self.id + 1
  return self.id
end

function gui:tabIndex(id,idx)
  if idx then
    table.insert(self.tabOrder, idx, id)
    return
  end
  self.tabOrder[#self.tabOrder + 1] = id
end

local function tabGet(order, focus, reverse)
  local add = 1
  if reverse then add = -1 end
  local tblidx
  if focus then 
    tblidx = table.indexOf(order, focus)
  else
    tblidx = 0
  end
  local idx = math.fmod((tblidx+add), (#order+1))
  if idx == 0 and add == -1 then idx = #order end
  if idx == 0 then idx = 1 end
  if idx == -1 then idx = #order end
  return order[idx]
end

function gui:tab()
  local down = love.keyboard.isDown("lshift", "rshift")
  if self.focus == nil then
    self:getFocus(tabGet(self.tabOrder, nil, down))
    return
  end
  self:getFocus(tabGet(self.tabOrder, self.focus, down))
end
function gui:tabDisable()
  
end

function gui:updateTab()
  if self.tabDisabled and string.find(self.keyPressed, "tab") and love.keyboard.isDown("lctrl", "rctrl") then
    self:tab()
    return
  elseif string.find(self.keyPressed, "tab") then
    self:tab()
    return
  end
end
function gui:keyDown(t)
  if self.escExit and t == "escape" and love.keyboard.isDown("lshift", "rshift") then
    love.event.quit()
  end
  if t == "escape" then self:getFocus(nil) end
  self.keyPressed = self.keyPressed .. t .. " "
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
  -- reset active when mouse released
  if not self.mouseDown then
    self.active = nil
  end

  -- reset hit
  self.hit = nil

  self.keyPressed = ""
  self.text = ""
  self.tabOrder = {}
  self.idx = 0
  self.tabDisabled = false

  -- set hovered last frame
  self.lastHovered, self.hovered = self.hovered, nil

  -- set new mouse stats
  self:updateMouse(love.mouse.getX(), love.mouse.getY(), love.mouse.isDown(1))
end

-- set mouse x/y/down
function gui:updateMouse(x, y, down)
  self.mouseX = x
  self.mouseY = y
  self.mouseDown = down
end

-- is mouse over any control
function gui:anyHovered()
  return self.hovered ~= nil
end

-- is mouse over this control
function gui:isHovered(id)
  return self.hovered == id
end

function gui:wasHovered(id)
  return self.lastHovered == id
end

-- is anything active
function gui:anyActive()
  return self.active ~= nil
end

-- is this control active
function gui:isActive(id)
  return self.active == id
end

function gui:anyHit()
  return self.hit ~= nil
end

function gui:isHit(id)
  return self.hit == id
end

function gui:anyFocus()
  return self.focus ~= nil
end

function gui:isFocus(id)
  return self.focus == id
end

function gui:getFocus(id)
  self.focus = id
end

function gui:textinput(t)
  self.text = self.text .. t
end

function gui:getState(id)
  if self:isActive(id) then
    return "active"
  elseif self:isHovered(id) then
    return "hovered"
  elseif  self:isHit(id) then
    return "hit"
  elseif self:isFocus(id) then
    return "focus"
  end
  return "none"
end

-- is this control hit
-- callback(X relative to top left, Y relative to top left)
function gui:registerMouseHit(id, relX, relY, callback)
  if callback(self.mouseX - relX, self.mouseY - relY) then
    self.hovered = id
    if self.active == nil and self.mouseDown then
      self.active = id
    end
  end
  return self:getState(id)
end

-- is hitbox hit
function gui:registerHitBox(id, x, y, w, h)
  return self:registerMouseHit(id, x, y, function(x,y)
    return x >= 0 and y >= 0 and x <= w and y <= h 
  end)
end

function gui:mouseClick(id)
  if not self.mouseDown and self:isActive(id) and self:isHovered(id) then
    self.hit = id
    return true
  end
  return false
end

function gui:getThemeColor(state)
  return self.theme[state]
end

function gui:getOptions(opt, ...)
  if type(opt) == "table" then
    return opt, ...
  end
  return {}, opt, ...
end

function gui:__index(index)
  local this = self

  -- get from this instance
  local get = getmetatable(self)[index]

  if get  ~= nil then 
    return get -- this instance has item with this index
  elseif gui.controls[index] ~= nil then
    -- index not found, return control if exists or nil
    return function(...) 
      return gui.controls[index](...)
    end
  else
    return nil
  end
end

function gui:__call(...)
  local obj = setmetatable({}, getmetatable(self))
  obj:new(...)
  return obj
end

return gui()