local gui = require "gui"
local inspect = require "vendor.inspect"

local function draw(core, x, y, text)
	local c = core:getThemeColor("none")
	love.graphics.setColor(c.fg[1], c.fg[2], c.fg[3])
	love.graphics.print(text, x+2, y+2)
end

gui.addControl("label", function(core, text, ...)
	local opt, x, y, w, h = core:getOptions(...)
	local id = opt.id or text
	if id == true then id = core:id() end
	local font = opt.font or love.graphics.getFont()

	local w = w or font:getWidth(text) + 4
	local h = h or font:getHeight() + 4

	core:registerHitBox(id, x,y,w,h)

	core:addDraw(draw, core, x, y, text)

	return {
		id=id,
		hit = core:mouseClick(id),
		hovered = core:isHovered(id),
		entered = core:isHovered(id) and not core:wasHovered(id),
		left = not core:isHovered(id) and core:wasHovered(id),
		state = core:getState(text)
	}
end)