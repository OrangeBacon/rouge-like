local application = require "engine.application"
local loading = require "states.loading"

love.window.setMode(love.graphics.getWidth(), love.graphics.getHeight(), {resizable = true})
application(loading())