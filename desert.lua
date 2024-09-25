-- Desert Bus for ComputerCraft
-- Originally created by Featherwhisker on 2024-24-9
-- SPDX-License-Identifier: MPL-2.0

local termX, termY = term.getSize()
local buseng = {}
do
	local framebuffer = {}
	for y=1,termY do
		framebuffer[y] = {}
		for x=1,termX do
			framebuffer[y][x] = {" ","0","f"}
		end
	end
	function buseng.write(x,y,text,textColor,backColor)
		local text = tostring(text)
		if not textColor or not backColor then
			textColor = colors.white
			backColor = colors.black
		end
		local blit1 = colors.toBlit(textColor)
		local blit2 = colors.toBlit(backColor)
		for i=0,#text-1 do
			local char = text:sub(i+1,i+1)
			if framebuffer[y][x+i] then
				framebuffer[y][x+i] = {char,blit1,blit2}
			end
		end
	end
	function buseng.setChar(x,y,char,textColor,backColor)
		local blit1 = colors.toBlit(textColor)
		local blit2 = colors.toBlit(backColor)
		if framebuffer[y][x] then
			framebuffer[y][x] = {char,blit1,blit2}
		end
	end
	function buseng.draw() 
		for y=1,#framebuffer do
			local blit1,blit2,blit3 = "","",""
			for x=1,#framebuffer[y] do
				blit1 = blit1..framebuffer[y][x][1]
				blit2 = blit2..framebuffer[y][x][2]
				blit3 = blit3..framebuffer[y][x][3]
			end
			term.setCursorPos(1,y)
			term.blit(blit1,blit2,blit3)
		end
	end
end
-- set colors
local teal = colors.cyan
local cyan = colors.pink
local gray = colors.gray
local yellow = colors.yellow
local brown = colors.brown
local orange = colors.orange
local red = colors.red
local black = colors.black
local white = colors.white

term.setPaletteColor(teal,0x36BECC)
term.setPaletteColor(cyan, 0x77DAD4)
term.setPaletteColor(brown, 0x876107)
term.setPaletteColor(red, 0x890D00)
term.setPaletteColor(orange,0xD1871B)
term.setPaletteColor(yellow, 0xEBC543)
term.setPaletteColor(gray,0x656565)

-- game logic
local addFrameNum = 4 --amount of frames between the bus moving right
if termX > 81 then
	addFrameNum = 2
elseif termX > 51 then
	addFrameNum = 3
end
local movementAmount = 3 --amount you move when pressing left or right, doesn't scale so the game isnt that much easier on big screens
local offset = 0 --used to determine road stripe position
local fromMid = 0 --ofset of the road from the center of the screen
local roadStart = math.floor((termY-4) * (1/3)) --where the skybox ends and road begins
local maxRoadSize = math.floor((termX-4) * (1/3)) --the offset from the center where you game over
local timer = 0 --used to make sure the game ends after 8 hours
local function mainLoop()
	while true do
		local mid = math.floor(termX/2 + 0.5) - fromMid
		for y=1,roadStart-2 do
			buseng.write(1,y,(" "):rep(termX),teal,teal)
		end
		buseng.write(1,roadStart-1,(" "):rep(termX),cyan,cyan)
		for y=roadStart,termY do
			local offsetX = y --originally was going to do some math for perspective, now just used to make the code easier to read
			-- draws the road and the desert background
			-- its not a driving game without a road
			for x=1,termX do
				if x > mid-(2+offsetX) and x < mid+(2+offsetX) then
					buseng.setChar(x,y," ",gray,gray) -- road
				elseif x > mid-(6+offsetX) and x < mid+(6+offsetX) then
					buseng.setChar(x,y,"\127",black,brown) -- road border
				else
					buseng.setChar(x,y," ",orange,orange) -- desert background
				end
			end
			-- draw road stripes
			-- drawn after the road itself so we don't have to make
			-- the road avoid the center
			if (y-offset) % 5 == 0 then
				buseng.setChar(mid,y," ",gray,gray)
			else
				buseng.setChar(mid,y," ",yellow,yellow)
			end
		end
		buseng.write(1,1,"DesertBusCC v1.0",colors.white,colors.black)
		if timer > 8*60*60 then --8 hours exactly
			buseng.write(1,2,"You won Desert Bus!",colors.white,colors.black)
			break
		else
			buseng.write(1,2,"Running for "..math.floor(timer).." seconds",colors.white,colors.black)
		end
		buseng.draw()
		sleep(1/17) --game run at 17fps
		timer = timer + (1/17) --works if the game actually runs at full speed
		offset = offset + 1 --
		if offset >= roadStart then
			offset = 0 --rset time
		end
		if offset % addFrameNum == 0 or offset % addFrameNum == addFrameNum then
			if math.abs(fromMid) > maxRoadSize then --end the game if the bus goes off the road
				buseng.write(1,3,"The bus went offroad and broke down!",colors.white,colors.black)
				buseng.draw()
				break
			end
			fromMid = fromMid + 1 -- move the bus right
		end
	end
end
local function inputLoop()
	while true do
		local _,key,held = os.pullEvent("key")
		if key == keys.right or key == keys.d then
			fromMid = fromMid + movementAmount
		elseif key == keys.left or key == keys.a then
			fromMid = fromMid - movementAmount
		end
	end
end
parallel.waitForAny(mainLoop,inputLoop)

sleep(5) --so you can take screenshots
for i=0,15 do --reset colors to native
	term.setPaletteColor(math.pow(2,i),term.nativePaletteColor(math.pow(2,i)))
end
--print the end of game message
term.clear()
term.setCursorPos(1,1)
term.setBackgroundColor(colors.blue)
term.setTextColor(colors.white)
local phrase = "Thank you for playing DesertBusCC!"
term.write("\156"..("\140"):rep(#phrase + 2)) term.blit("\147","b","0") print("")
term.write("\149 "..phrase.." ") term.blit("\149","b","0") print("")
print("\141"..("\140"):rep(#phrase + 2).."\142")
term.setBackgroundColor(colors.black)
