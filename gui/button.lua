local gui = require "gui"

gui.addControl("button", function(core, text, x, y, w, h)
	print(core:getState(text))
end)