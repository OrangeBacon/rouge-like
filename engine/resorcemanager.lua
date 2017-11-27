require "engine.utils"

local ResourceManager = {resources={}}

function ResourceManager:getResource(filename)
  return self.resources[filename] or error(string.format("resource \"%s\" does not exist", filename), 2)
end

function ResourceManager:addResource(filename)
	if self.resources[filename] then return self.resources[filename] end
	if string.endsWith(filename, '.png') then
		self.resources[filename] = love.graphics.newImage(filename)
	end
	return self.resources[filename]
end

return ResourceManager