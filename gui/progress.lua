local gui = require "gui"

local function draw(core, id, x, y, w, h, progX, progY)
	local c = core:getThemeColor(core:getState(id))
	love.graphics.setColor(c.bg[1], c.bg[2], c.bg[3])
	love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.setColor(c.fg[1], c.fg[2], c.fg[3])
	love.graphics.rectangle("fill", x, y, progX, progY)
end

gui.addControl("progressHorizontal", function(core, ...)
	local opt, x, y, length, height, progress = core:getOptions(...)
	local id = opt.id or (progress * 3.1415) -- create hopefuly unique id

	core:registerHitBox(id, x, y, length, height)

	progX = length * math.min(math.max(progress, 0), 100) / 100
	progY = height

	core:addDraw(draw, core, id, x, y, length, height, progX, progY)

	return {
		id=id,
		hit = core:mouseClick(id),
		hovered = core:isHovered(id),
		entered = core:isHovered(id) and not core:wasHovered(id),
		left = not core:isHovered(id) and core:wasHovered(id),
		state = core:getState(text)
	}
end)

gui.addControl("progressVertical", function(core, ...)
	local opt, x, y, length, width, progress = core:getOptions(...)
	local id = opt.id or (progress * 3.1415) -- create hopefuly unique id

	core:registerHitBox(id, x, y, width, length)

	progY = length * math.min(math.max(progress, 0), 100) / 100
	progX = width

	core:addDraw(draw, core, id, x, y, width, length, progX, progY)

	return {
		id=id,
		hit = core:mouseClick(id),
		hovered = core:isHovered(id),
		entered = core:isHovered(id) and not core:wasHovered(id),
		left = not core:isHovered(id) and core:wasHovered(id),
		state = core:getState(text)
	}
end)