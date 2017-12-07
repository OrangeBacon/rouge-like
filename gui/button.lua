local gui = require "gui"
local inspect = require "vendor.inspect"

local function draw(core, id, x, y, w, h, text)
		local c = core:getThemeColor(core:getState(id)).bg
		love.graphics.setColor(c[1], c[2], c[3])
		love.graphics.rectangle("fill", x, y, w, h)
		love.graphics.setColor(0, 0, 0)
		love.graphics.print(text, x+2, y+2)
	end

gui.addControl("button", function(core, text, ...)
	local opt, x, y, w, h = core:getOptions(...)
	local id = opt.id or text
	if id == true then id = core:id() end
	local font = opt.font or love.graphics.getFont()

	local w = w or font:getWidth(text) + 4
	local h = h or font:getHeight() + 4

	core:tabIndex(id)

	core:registerHitBox(id, x,y,w,h)

	local hit = core:mouseClick(id)
	if hit then
		core:getFocus(id)
		love.keyboard.setKeyRepeat(false)
	end
	if core:isFocus(id) and (string.find(core.text, "return") or string.find(core.text, "space")) then
		hit = true
	end

	core:addDraw(draw, core, id, x, y, w, h, text)

	return {
		id=id,
		hit = hit,
		hovered = core:isHovered(id),
		entered = core:isHovered(id) and not core:wasHovered(id),
		left = not core:isHovered(id) and core:wasHovered(id),
		state = core:getState(text)
	}
end)