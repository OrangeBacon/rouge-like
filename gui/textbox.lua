local guicontrol = require "gui.guicontrol"
local ResourceManager = require "engine.resorcemanager"
local utf8 = require "utf8"

local textbox = guicontrol:extend()

local text = ""

function love.textinput(t)
	text = text .. t
end

function love.keypressed(key)
	if key == "backspace" then
    -- get the byte offset to the last UTF-8 character in the string.
    local byteoffset = utf8.offset(text, -1)
 
    if byteoffset then
      -- remove the last UTF-8 character.
      -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
      text = string.sub(text, 1, byteoffset - 1)
    end
  end
end

function textbox:init()
	self.color = 0
end

function textbox:update(dt)
	self.color = (self.color + 6 * dt) % 255
end

function textbox:draw()
	love.graphics.setColor(self.color, 0, 0)
	love.graphics.rectangle("fill", 0, 100, 100, 100)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print(text, 0, 100)
end

return textbox