function love.load(...)
	-- graphics settings
	love.window.setMode(800, 600, {resizable=true})
	love.graphics.setDefaultFilter("nearest")

	-- map settings
	mapConfig = {}
	mapConfig.seed = love.math.random(10000,100000)/7
	mapConfig.width = 5000 -- width of map
	mapConfig.height = 100 -- height of map
	mapConfig.scrollX = 0  -- pixels scrolled left-right
	mapConfig.scrollY = 40*32 -- pixels scrolled up-down
	mapConfig.firstX = 0 -- x coordinate of lower left hand corner of rendered tiles using in game coordinates
	mapConfig.firstY = 0 -- y coordinate of lower left hand corner of rendered tiles using in game coordinates
	mapConfig.offsetX = 0 -- pixels in x direction that the tile grid is offset by for rendering
	mapConfig.offsetY = 0 -- pixels in y direction that the tile grid is offset by for rendering

	player = {}
	player.x = 0
	player.y = math.floor(love.math.noise(0, mapConfig.seed)*mapConfig.height) + 20 -- get ground height at x=0
	player.xvel = 0
	player.yvel = 0
	player.isFalling = true
	player.hasFallMoved = false

	map = {}
	for x=0, mapConfig.width do  -- very basic terrain generator, maybe bugged, might need replacing
		map[x] = {}
		height = math.floor(love.math.noise(x/100, mapConfig.seed)*mapConfig.height) -- stone height
		for y=0, height do
			map[x][y] = 1
		end
		map[x][height+1] = 2 -- add grass
		for y=height+2, mapConfig.height do
			--[[if y < 40 then
			    map[x][y] = 3
			else]]
				map[x][y] = 0
			--end
		end
	end

	width = love.graphics.getWidth() -- screen width
	height = love.graphics.getHeight() -- screen height


	tileConfig = {}
	tileConfig.size = 32 -- pixel width/height of each tile
	tileConfig.screenWidth = math.ceil(width / tileConfig.size) -- how many tiles can fit on screen verticaly
	tileConfig.screenHeight = math.ceil(height / tileConfig.size) -- how many tiles can fit on screen horizontaly
	tileConfig.bufferSize = 2 -- how many tiles are rendered off screen so all possible map can be displayed
	tileConfig.imageSize = 16 -- how many pixels wide each tile is

	tiles = {}
	tiles[1] = love.graphics.newImage("block.png")
	tiles[2] = love.graphics.newImage("grass.png")
	tiles[3] = love.graphics.newImage("water.png")
end

function screen2game(x,y) -- pixels along window to in game coordinates
	local xPos = math.floor((x+mapConfig.offsetX)/tileConfig.size+0.5)+mapConfig.firstX
	local yPos = math.ceil((2 * height + 2 * mapConfig.offsetY - 2 * y + tileConfig.size)/(2 * tileConfig.size))+mapConfig.firstY
	return xPos, yPos
end

function game2screen(x,y) -- ingame coordinates to top left of rect render location
	local xPos = tileConfig.size*(x-mapConfig.firstX) - mapConfig.offsetX - tileConfig.size/2
	local yPos = height - (tileConfig.size*(y-mapConfig.firstY) - mapConfig.offsetY - tileConfig.size/2)
	return xPos, yPos
end

function math.round(num,prec)
	num = num or 0
	prec = prec or 1
	prec = math.floor(prec)
	local t = math.pow(10, prec)
	return math.floor(num*t+0.5)/t
end
tileBelowXY={}
function love.update(dt)
	speed = 100 * (tileConfig.size / tileConfig.imageSize) -- how fast keys move map around screen
	if love.keyboard.isDown("up") then  -- move map
		mapConfig.scrollY = mapConfig.scrollY + speed*dt
	end
	if love.keyboard.isDown("down") then
		mapConfig.scrollY = mapConfig.scrollY -  speed*dt
	end
	if love.keyboard.isDown("left") then
	  mapConfig.scrollX = mapConfig.scrollX - speed*dt
	end
	if love.keyboard.isDown("right") then
	  mapConfig.scrollX = mapConfig.scrollX + speed*dt
	end

	-- player movement
	if love.keyboard.isDown("w") --[[and not player.isFalling]] then
	  player.yvel = 0.1
	  player.isFalling = true
	  player.hasFallMoved = false
	end

	-- update player velocities
	player.yvel = player.yvel - 0.0017

	-- tile below player
	local tileBL = (map[math.floor(player.x)] or {})[math.floor(player.y)]
	local tileBR = (map[math.ceil(player.x)] or {})[math.floor(player.y)]
	local tileBelow = nil
	if tileBL == 0 or tileBL == 3 or tileBL == nil then
		tileBelow = tileBR
		tileBelowXY = {x=math.ceil(player.x),y=math.floor(player.y)}
	else 
		tileBelow = tileBL
		tileBelowXY = {x=math.floor(player.x),y=math.floor(player.y)}
	end
	if not(tileBelow == 0 or tileBelow == 3 or tileBelow == nil) then
		player.y = math.ceil(player.y)
		player.yvel = 0
		player.isFalling = false
	elseif player.isFalling == false then
		player.isFalling = true
		player.hasFallMoved = false
	end

	-- tile above player
	local tileAL = (map[math.floor(player.x)] or {})[math.ceil(player.y)]
	local tileAR = (map[math.ceil(player.x)] or {})[math.ceil(player.y)]
	local tileAbove = nil
	if tileAL == 0 or tileAL == 3 or tileAL == nil then
		tileAbove = tileAR
	else 
		tileAbove = tileAL
	end
	if not(tileAbove == 0 or tileAbove == 3 or tileAbove == nil) then
		player.yvel = -0.01
	end

	if love.keyboard.isDown("a") --[[and not player.hasFallMoved]] then
		player.xvel = -0.2
		player.hasFallMoved = true
	end
	if love.keyboard.isDown("d") --[[and not player.hasFallMoved]] then
	  player.xvel = 0.2
	  player.hasFallMoved = true
	end
	if not player.isFalling then
		player.xvel = player.xvel * 0.75
	else
		player.xvel = player.xvel * 0.96
	end

	-- tile left of player
	local tileLA = (map[math.ceil(player.x)-1] or {})[math.ceil(player.y)]
	local tileLB = (map[math.ceil(player.x)-1] or {})[math.floor(player.y)]
	local tileLeft = nil
	if tileLA == 0 or tileLA == 3 or tileLA == nil then
		tileLeft = tileLA
	else 
		tileLeft = tileLB
	end
	if not(tileLeft == 0 or tileLeft == 3 or tileLeft == nil) and player.xvel < 0 then
		player.xvel = 0
		player.x = math.ceil(player.x)
	end

	-- tile right of player
	local tileRA = (map[math.floor(player.x)+1] or {})[math.ceil(player.y)]
	local tileRB = (map[math.floor(player.x)+1] or {})[math.floor(player.y)]
	local tileRight = nil
	if tileRA == 0 or tileRA == 3 or tileRA == nil then
		tileRight = tileRA
	else 
		tileRight = tileRB
	end
	if not(tileRight == 0 or tileRight == 3 or tileRight == nil) and player.xvel > 0 then
		player.xvel = 0
		player.x = math.floor(player.x)
	end

	player.y = player.y + player.yvel
	player.x = player.x + player.xvel
end

function love.draw()
	love.graphics.setBackgroundColor(136, 196, 236)
	love.graphics.setColor(255, 255, 255)

	-- calculate offsets
	mapConfig.offsetX = mapConfig.scrollX % tileConfig.size
	mapConfig.offsetY = mapConfig.scrollY % tileConfig.size
	mapConfig.firstX = math.floor(mapConfig.scrollX / tileConfig.size)
	mapConfig.firstY = math.floor(mapConfig.scrollY / tileConfig.size)

	-- render tiles

	print(tileBelowXY.x..' '..tileBelowXY.y) 

	for x=0, tileConfig.screenWidth + tileConfig.bufferSize do
		for y=0, tileConfig.screenHeight + tileConfig.bufferSize do

			-- is the tile in the map?
			if y + mapConfig.firstY >= 0 and y + mapConfig.firstY <= mapConfig.height 
				and x + mapConfig.firstX >= 0 and x + mapConfig.firstX <= mapConfig.width 
				and map[x+mapConfig.firstX][y+mapConfig.firstY] ~= 0 then
				  -- calculate render position - different algo to game2screen
			    local xPos = tileConfig.size*x - mapConfig.offsetX - tileConfig.size/2
			    local yPos = height - (tileConfig.size*y - mapConfig.offsetY - tileConfig.size/2)

			    -- render tile
			    if x+mapConfig.firstX==tileBelowXY.x and y+mapConfig.firstY==tileBelowXY.y then
			    	love.graphics.setColor(150, 0, 0)
			    end
			    love.graphics.draw(tiles[map[x+mapConfig.firstX][y+mapConfig.firstY]], xPos, yPos, 0, tileConfig.size / tileConfig.imageSize)
			    love.graphics.setColor(255, 255, 255)
			end
		end
	end

	-- render player
	local x,y = game2screen(player.x, player.y)
	love.graphics.setColor(0, 0, 255)
	love.graphics.rectangle("fill", x, y, tileConfig.size, tileConfig.size)

	-- debugging infomation
	love.graphics.setColor(255, 255, 255)
	x, y = screen2game(love.mouse.getX(), love.mouse.getY())
	if love.mouse.isDown(1) and (oldMouseX ~= x or oldMouseY ~= y) then
		oldMouseX = x
		oldMouseY = y
		map[x][y] = (map[x][y]+1)%(#tiles+1)
	end
	if love.mouse.isDown(2) and (oldMouseX ~= x or oldMouseY ~= y) then
		oldMouseX = x
		oldMouseY = y
		map[x][y] = (map[x][y]-1)%(#tiles+1)
	end
	love.graphics.print("x: "..x.." y: "..y, 20, 20)
	love.graphics.print("playerX: "..player.x.." playerY: "..player.y, 20, 40)
	love.graphics.print("xvel: "..math.round(player.xvel,2).." yvel: "..player.yvel, 20, 60)
	love.graphics.print(tileBelowXY.x.." "..tileBelowXY.y, 20, 80)

	-- render cursor
  x,y = game2screen(x,y)
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", x, y, tileConfig.size, tileConfig.size, 5)
end

function love.wheelmoved(x, y)
	-- zoom controls
	if y > 0 then
		tileConfig.size = tileConfig.size + 1
		love.resize()
  elseif y < 0 then
  	tileConfig.size = tileConfig.size - 1
  	love.resize()
  end
end

function love.mousepressed(x, y, button)
	x,y=screen2game(x,y)
	if button == 1 then
		map[x][y]=(map[x][y]+1)%(#tiles+1)
	elseif button == 2 then
		map[x][y]=(map[x][y]-1)%(#tiles+1)
	end
end

function love.resize()
	-- update graphics config for screen resize
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()

	tileConfig.screenWidth = math.ceil(width / tileConfig.size)
	tileConfig.screenHeight = math.ceil(height / tileConfig.size)
end

