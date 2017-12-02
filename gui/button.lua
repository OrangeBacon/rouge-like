local gui = require "gui"
local inspect = require "vendor.inspect"

gui.addControl("button", function(core, text, x, y, w, h)
	core:registerHitBox(text, x,y,w,h)
	core:addDraw(function()
		local c = core:getThemeColor(core:getState(text)).bg
		love.graphics.setColor(c[1], c[2], c[3])
		love.graphics.rectangle("fill", x, y, w, h)
	end)
--print(core:getState(text))
	return {
		id=text,
		hit = core:mouseClick(text),
		--hovered = core:isHovered(text),
		--entered = core:isHovered(text) and not core:wasHovered(text),
		--left = not core:isHovered(text) and core:wasHovered(text),
		state = core:getState(text)
	}
end)