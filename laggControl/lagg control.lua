local component = require("component")
local sides = require("sides")
local colors = require("colors")
local event = require("event")

--[[components setup]]--
local gpu = component.gpu
local redstone = component.redstone
local chat = component.chat_box
local info = component.notificationInterface
local onlineDetector = component.onlinedetector

--[[command patterns]]--
local triggerKeywordPattern = "tako"
local showStatusPattern = "status"

--[[ lagg config ]]--
local autoInterval = 600
local manualScheduleInterval = 60
--[[ redstone signaling config ]]--

--[[ chat box setup ]]--


--[[message config ]]--
local computerName = "清道夫控制主機"
local manualScheduleStartingMessage = "已手動啟動清道夫排程"
local infoMessage_1 = "秒後清除物品"
local responseMessage_1 = "狀態: "
local responseMessage_auto = "自動"
local responseMessage_manually = "手動"

--[[timers]]--
local manualScheduleTimer = nil
local autoScheduleTimer = nil
local countDownTimer = nil

local manualSchedule = false
local manualScheduleStarterId = ""

local function consoleLog(msg)
	checkArg(1,msg,"string")
	print("[" .. os.date() .. "]: " ..msg)
end
--[[
local function loadIdList()
	local idTable = {}
	for id in io.lines("/sys/idList") do
		table.inset(idTable,id)
	end
	return idTable
end
]]--
local playerIdList = onlineDetector.getPlayerList()

--[[ notification operation session ]]--

local function informPlayersLagg(s)
	playerIdList = onlineDetector.getPlayerList()
	for k,v in ipairs(playerIdList) do
		info.sendNotification(v,computerName,s .. infoMessage_1,100,"chisel:warningSign",8)
	end
end

local function informPlayerManuallyStart(id)
	playerIdList = onlineDetector.getPlayerList()
	for k,v in ipairs(playerIdList) do
		info.sendNotification(v,computerName,id .. manualScheduleStartingMessage,100,"chisel:warningSign",8)
	end
end

-----------------------------------------------

local function redstoneShortPulse(side,channel)
	redstone.setBundledOutput(side,channel,15)
	os.sleep(0.2)
	redstone.setBundledOutput(side,channel,0)
end

local function disableScheduleTimers()
	if autoScheduleTimer then
		local cancelled = event.cancel(autoScheduleTimer)
		local statusMsg
		if cancelled then
			autoScheduleTimer = nil
			statusMsg = "Success!"
		else
			statusMsg = "Failed!"
		end
		consoleLog("Cancelling Auto Schedule.." .. statusMsg)
	end
	if manualScheduleTimer then
		local cancelled = event.cancel(manualScheduleTimer)
		local statusMsg
		if cancelled then
			manualScheduleTimer = nil
			statusMsg = "Success!"
		else
			statusMsg = "Failed!"
		end
		consoleLog("Cancelling Manual Schedule.." .. statusMsg)
	end
end

local counter = 0

local function countDownFunc()
	consoleLog("[counter] " .. counter)
	if counter == 0 then
		redstoneShortPulse(sides.west,colors.purple)
		--set auto Schedule timer

		--clear up manual schedule information
		manualSchedule = false
		manualScheduleStarterId = ""
		autoScheduleTimer = event.timer(autoInterval - 30,execLagg)
		if autoScheduleTimer then
			consoleLog("Successfully started auto scheduling...")
		else
			consoleLog("auto scheduling starting failure...")
		end
	else
		if counter == 3 then
			informPlayersLagg(counter)
		end
		counter = counter - 1
	end
end

local function execLagg()
	informPlayersLagg(30)
	--start countDown
	counter = 30
	disableScheduleTimers()
	countDownTimer = event.timer(1,countDownFunc,31)
end



local function startManualSchedule(name)
	--disable & reset autoSchedule
	disableScheduleTimers()
	--info
	chat.say(name .. manualScheduleStartingMessage)
	manualScheduleStarterId = name
	informPlayerManuallyStart(name)
	--set the timer
	manualScheduleTimer = event.timer(manualScheduleInterval - 30,execLagg)
end

local function isAutoScheduled()
	return not manualSchedule
end

local function sendLaggStatus(id)
	checkArg(1,id,"string")
	local response = responseMessage_1
	if isAutoScheduled() then
		response = response .. responseMessage_auto
	else
		response = response .. responseMessage_manually .. "(" .. manualScheduleStarterId .. ")"
	end
	info.sendNotification(id,computerName,response,100,"chisel:warningSign",8)
	consoleLog(id .. " had queried the system status.")
	consoleLog("responded: \"" .. response .. "\"")
end

chat.setName(computerName)
disableScheduleTimers()
autoScheduleTimer = event.timer(autoInterval - 30,execLagg)

while true do
	local msg = table.pack(event.pull("chat_message"))
	if #msg ~= 0 then
		if string.match(msg[4],triggerKeywordPattern) then
			if not manualSchedule then
				manualSchedule = true
				consoleLog(msg[3] .. " had manually scheduled Lagg.It will be execute in 60 seconds")
				startManualSchedule(msg[3])
			end
		else
			if string.match(msg[4],showStatusPattern) then
				sendLaggStatus(msg[3])
			end
		end
	end
end