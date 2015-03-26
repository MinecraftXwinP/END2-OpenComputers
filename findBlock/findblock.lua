--find block
--author:WinXp

--components settings
local debugCard = require("component").debug

local function consoleLog(msg,level)
	checkArg(1,msg,"string")
	local levelLable = "細節"
	if level == 1 then
		levelLable = "通知"
	else 
		if level == 2 then
			levelLable = "錯誤"
		else 
			if level == 3 then
			levelLable = "緊急"
			end
		end
	end
	print("[" .. os.date() .. "] [" .. levelLable .. "] " .. msg)
end

function findBlock(id,x1,y1,z1,x2,y2,z2,meatadata)
	checkArg(1,id,"number")
	checkArg(2,x1,"number")
	checkArg(3,y1,"number")
	checkArg(4,z1,"number")
	checkArg(5,x2,"number")
	checkArg(6,y2,"number")
	checkArg(6,z2,"number")
	local compareMetadata = false
	if metadata ~= nil then
		checkArg(7,metadata,"number")
		if metadata < 0 or metadata > 15 then
		error("Meatadatas must be a integer between 0(include) and 15(include)!")
		end
		compareMetadata = true
	end
	
	resultList = {}
	
	if math.abs(x2 - x1) == 0 then 
		dx = 1
	else
		dx = (x2 - x1) / math.abs(x2 - x1)
	end
	if math.abs(y2 - y1) == 0 then
		dy = 1
	else
		dy = (y2 - y1) / math.abs(y2 - y1)
	end
	if math.abs(z2 - z1) == 0 then
		dz = 1
	else
		dz = (z2 - z1) / math.abs(z2 - z1)
	end
	
	for i=x1,x2,dx do
		for j=y1,y2,dy do
			for k=z1,z2,dz do
				--compare
				consoleLog("examing block: " .. i .. " " .. j .. " " .. k)
				if id == debugCard.getWorld().getBlockId(i,j,k) then
					if compareMetadata and meatadata == debugCard.getWorld().getMetadata(i,j,k) then
						local result = {i,j,k,metadata}
					else
						local result = {i,j,k,debugCard.getWorld().getMetadata(i,j,k)}
					end
					consoleLog("found!")
					table.insert(resultList,result)
				end
			end
		end
	end
	return resultList
end

local function boardcast(result)
	checkArg(1,result,"string")
end

local function display(result)
	checkArg(1,result,"table")
	consoleLog("||_________|_________|_________|_________||")
	consoleLog("||    X    |    Y    |    Z    |Metadata ||")
	consoleLog("===========================================")
	print(result)
	for k,v in ipairs(result) do
		local record = "||"
		for i=1,4 do
			local nL = math.floor(math.log(v[i],10)+1)
			for i=0,math.floor(4 - nL / 2) do
				record = record .. " "
			end
			record = record .. v[i]
		end
	end
end

local param = table.pack(...)

if #param == 0 or #param > 9  then
	error("指令：<command> <ID> <X1> <Y1> <Z1> <X2> <Y2> <Z2> [metadata] [boardcast]")
end
--[[
local paramType = {"number","number","number","number","number","number","number","number"}

for i=1,8 do
	if type(param[i]) ~= paramType[i] then
		error("指令：<command> <ID> <X1> <Y1> <Z1> <X2> <Y2> <Z2> [metadata] [boardcast]")
	end
end
]]--
display(findBlock(tonumber(param[1]),
		tonumber(param[2]),tonumber(param[3]),tonumber(param[4]),
		tonumber(param[5]),tonumber(param[6]),tonumber(param[7]),tonumber(param[8])))









