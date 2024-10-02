local player = game.Players.LocalPlayer
local ReplicatedStorage = game:WaitForChild("ReplicatedStorage", 10)
local futar = player:WaitForChild("PlayerGui", 10):WaitForChild("futar", 10)
local futar_alap = futar:WaitForChild("futar_alap", 10)
local timeTextLabel = futar_alap:WaitForChild("time", 10)
local dateTextLabel = futar_alap:WaitForChild("date", 10)
local loginButton = futar_alap:WaitForChild("futar_hatter", 10):WaitForChild("login", 10)
local bevitelFrame = futar_alap:WaitForChild("futar_bevitel", 10)
local nextButtonBevitel = bevitelFrame:WaitForChild("next", 10)
local backButtonBevitel = bevitelFrame:WaitForChild("back", 10)
local labelBevitel = bevitelFrame:WaitForChild("label", 10)
local forgalmiFrame = futar_alap:WaitForChild("futar_forgalmi", 10)
local nextButtonForgalmi = forgalmiFrame:WaitForChild("next", 10)
local backButtonForgalmi = forgalmiFrame:WaitForChild("back", 10)
local labelForgalmi = forgalmiFrame:WaitForChild("label", 10)
local futarConfig = require(ReplicatedStorage:WaitForChild("Modules", 10):WaitForChild("futarConfig", 10))
local futarValaszto = futar_alap:WaitForChild("futar_valaszto", 10)
local backButtonValaszto = futarValaszto:WaitForChild("back", 10)
local RunService = game:GetService("RunService")
local futar_alap1 = futar_alap:WaitForChild("futar_alap1", 10)
local futar_ertesites = futar_alap:WaitForChild("futar_ertesites", 10)
local LawoNagy = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("LawoNagy", 10)
local LawoKicsi = game.Workspace:WaitForChild("LawoKicsi", 10)
local BUSEP = game.Workspace:WaitForChild("BUSEP", 10)
local BUSEF = game.Workspace:WaitForChild("BUSEF", 10)
local UzenetRemoteEvent = ReplicatedStorage:WaitForChild("EventsAndFunctions", 10):WaitForChild("UzenetRemoteEvent", 10)
local kesesLabel = futar_alap1:WaitForChild("keses", 10)
local dir1 = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("Dir1", 10)
local dir2 = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("Dir2", 10)
local num1 = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("Num1", 10)
local num2 = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("Num2", 10)
local num3 = game.Workspace:WaitForChild("bus", 10).Body:WaitForChild("Num3", 10)
local upcomingStops = futar_alap1:WaitForChild("upcomingStops", 10)
local SoundService = game:GetService("SoundService")
local bkkfutar = SoundService:WaitForChild("bkkfutar", 10)
local altalanos = bkkfutar:WaitForChild("altalanos", 10)
local megallok = bkkfutar:WaitForChild("megallok", 10)
local nextStop = nil
local currentlyPlayingSound = nil
local F01Folder = futarValaszto:WaitForChild("F01", 10)
local templateFrame = F01Folder:WaitForChild("template", 10)
local futarBevitel = futar_alap:WaitForChild("futar_bevitel", 10)
local futarHatter = futar_alap:WaitForChild("futar_hatter")
local futarNev = futar_alap:WaitForChild("futar_nev")

local function playSound(soundName, folder, callback)
	local sound = folder:FindFirstChild(soundName)
	if sound and currentlyPlayingSound ~= sound then
		currentlyPlayingSound = sound
		sound:Play()
		sound.Ended:Connect(function()
			currentlyPlayingSound = nil
			if callback then
				callback()
			end
		end)
	end
end

local function playStopSound(stopName)
	local sound = megallok:FindFirstChild(stopName)
	if sound then
		sound:Play()
		nextStop = nil
	end
end

local function playGreetingAndStopSound()
	if nextStop and currentlyPlayingSound == nil then
		playSound("udvozoljuk", altalanos, function()
			playSound("kovetkezo", altalanos, function()
				wait(math.random(1,3))
				playSound(nextStop, megallok, function()
					nextStop = nil
				end)
			end)
		end)
	end
end

local function updateInGameTime()
	local currentTime = game.Lighting.ClockTime
	local hours = math.floor(currentTime)
	local minutes = math.floor((currentTime - hours) * 60)
	local seconds = math.floor(((currentTime - hours) * 60 - minutes) * 60)
	timeTextLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

local function updateDate()
	local currentDate = os.date("!*t")
	dateTextLabel.Text = string.format("%s %02d. %02d. %02d", futarConfig.daysOfWeek[currentDate.wday], currentDate.year % 100, currentDate.month, currentDate.day)
end

local function playButtonClickSound()
	local sound = game.SoundService.bkkfutar.futar_rovidsip
	if sound and sound.IsLoaded then
		sound:Play()
	else
		sound.Loaded:Connect(function()
			sound:Play()
		end)
	end
end

local function playLongBeepSound()
	local sound = game.SoundService.bkkfutar.futar_hosszusip
	if sound and sound.IsLoaded then
		sound:Play()
	else
		sound.Loaded:Connect(function()
			sound:Play()
		end)
	end
end


local function handleNumberButtonClick(label, number, maxChars)
	if #label.Text < maxChars then
		playButtonClickSound()
		label.Text = label.Text .. number
	else
		playLongBeepSound()
	end
end

local function setupNumberButtonClickHandling(frame, label, maxChars)
	for i = 0, 9 do
		local numberButton = frame:FindFirstChild(tostring(i))
		if numberButton then
			numberButton.MouseButton1Click:Connect(function()
				handleNumberButtonClick(label, tostring(i), maxChars)
			end)
		end
	end
end

local isHandlingForgalmi = false

local function handleNextButtonForgalmi()

	if isHandlingForgalmi then return end

	isHandlingForgalmi = true

	local forgalmiText = labelForgalmi.Text
	local foundLine = nil
	local correctTimetable = nil

	-- Iterate through the bus lines to find the matching line
	for _, line in ipairs(futarConfig.busLines) do
		if forgalmiText == line.lineCode then
			foundLine = line
			break
		end
	end

	-- If the line is not found, play a sound and exit the function
	if not foundLine then
		playLongBeepSound()
		isHandlingForgalmi = false
		return
	end

	-- Access the Timetables folder in ReplicatedStorage
	local timetables = game.ReplicatedStorage.Modules.Timetables

	-- Find the matching timetable module using the 'timetable' prefix and the line code
	for _, timetableModule in ipairs(timetables:GetChildren()) do
		-- Construct the expected timetable module name based on the found line code
		local expectedModuleName = "timetable" .. foundLine.lineCode
		if timetableModule.Name == expectedModuleName then
			correctTimetable = require(timetableModule)
			break
		end
	end

	-- Proceed if a correct timetable has been found
	if correctTimetable then
		playButtonClickSound()
		wait(math.random(1,3))
		local currentPage = 1
		local totalFordas = #correctTimetable.timetable
		local maxFordasPerPage = 5
		local totalPages = math.ceil(totalFordas / maxFordasPerPage)

		local function updateFordasDisplay()
			print("Updating display for page:", currentPage, "of", totalPages)  -- Debugging

			for _, item in ipairs(F01Folder:GetChildren()) do
				if item ~= templateFrame and item.Name ~= "up" and item.Name ~= "down" then
					item:Destroy()
				end
			end
			templateFrame.Visible = false

			print("Total fordas in correctTimetable: ", #correctTimetable.timetable)  -- Debugging print

			local totalFordas = #correctTimetable.timetable
			local startIdx = (currentPage - 1) * maxFordasPerPage + 1
			local endIdx = math.min(startIdx + maxFordasPerPage - 1, #correctTimetable.timetable)
			local numFordasOnPage = endIdx - startIdx + 1
			local yOffset = 0

			local futarValasztoImage = futarValaszto
			if futarValasztoImage then
				local imageId
				if numFordasOnPage == 0 then
					imageId = "rbxassetid://16231385494"
				elseif numFordasOnPage == 1 then
					imageId = "rbxassetid://16231388819"
				elseif numFordasOnPage == 2 then
					imageId = "rbxassetid://16231391876"
				elseif numFordasOnPage == 3 then
					imageId = "rbxassetid://16231395266"
				elseif numFordasOnPage == 4 then
					imageId = "rbxassetid://16231402542"
				elseif numFordasOnPage >= 5 then
					imageId = "rbxassetid://16231405508"
				end
				futarValasztoImage.Image = imageId
			end

			for i = startIdx, endIdx do
				local TTData = correctTimetable.timetable[i]
				local newFrame = templateFrame:Clone()
				newFrame.Name = "F" .. i
				newFrame.Visible = true
				newFrame.Parent = F01Folder
				if not TTData then
					print("Error: Missing TTData for index ", i)  -- Debugging print
					break  -- Avoid trying to index nil values in TTData
				end

				local fordaLabel = newFrame:FindFirstChild("forda")
				local lineLabel = newFrame:FindFirstChild("line")
				local terminus0Label = newFrame:FindFirstChild("terminus0")
				local terminus1Label = newFrame:FindFirstChild("terminus1")
				local deptLabel = newFrame:FindFirstChild("dept")
				local aux = newFrame:FindFirstChild("aux")

				if fordaLabel then fordaLabel.Text = TTData.forda end
				if lineLabel then lineLabel.Text = TTData.line end
				if terminus0Label then terminus0Label.Text = TTData.term0FUTAR end
				if terminus1Label then terminus1Label.Text = TTData.term1FUTAR end
				if aux and TTData.aux then aux.Text = TTData.aux end

				if deptLabel and TTData.stops[1] then
					local hours, minutes = TTData.stops[1].departure:match("(%d+):(%d+)")
					if hours and minutes then
						deptLabel.Text = hours .. ":" .. minutes
					end
				end
				
				newFrame.Position = UDim2.new(0.016, 0, 0.276 + yOffset, 0)
				yOffset = yOffset + 0.135
			end
		end		

		local function navigate(direction)
			currentPage = math.clamp(currentPage + direction, 1, totalPages)
			print("Navigating to page:", currentPage, "Total pages:", totalPages, "For current timetable:", #correctTimetable.timetable)
			updateFordasDisplay()  -- This should now reflect the updated state
		end
		
		
		
		local upButton = futarValaszto:WaitForChild("up")
		local downButton = futarValaszto:WaitForChild("down")

		upButton.MouseButton1Click:Connect(function()
			if currentPage > 1 then
				navigate(-1)
				playButtonClickSound()
			else
				playLongBeepSound()
			end
		end)

		downButton.MouseButton1Click:Connect(function()
			if currentPage < totalPages then
				navigate(1)
				playButtonClickSound()
			else
				playLongBeepSound()
			end
		end)

		updateFordasDisplay()
		isHandlingForgalmi = false
	else
		playLongBeepSound()
	end

	bevitelFrame.Visible = false
	forgalmiFrame.Visible = false
	futarValaszto.Visible = true
end

backButtonValaszto.MouseButton1Click:Connect(function()
	futarValaszto.Visible, forgalmiFrame.Visible = false, true
	playButtonClickSound()
end)

loginButton.MouseButton1Click:Connect(function()
	bevitelFrame.Visible = true
	futarHatter.Visible = false
	playButtonClickSound()
end)

backButtonBevitel.MouseButton1Click:Connect(function()
	bevitelFrame.Visible = false
	futarHatter.Visible = true
	playButtonClickSound()
end)

setupNumberButtonClickHandling(bevitelFrame, labelBevitel, 9)
setupNumberButtonClickHandling(forgalmiFrame, labelForgalmi, 4)

local clearButtonBevitel = bevitelFrame:FindFirstChild("C")

if clearButtonBevitel then
	clearButtonBevitel.MouseButton1Click:Connect(function()
		if labelBevitel.Text ~= "" then
			labelBevitel.Text = ""
			playButtonClickSound()
		else
			playLongBeepSound()
		end
	end)
end

local clearButtonForgalmi = forgalmiFrame:FindFirstChild("C")

if clearButtonForgalmi then
	clearButtonForgalmi.MouseButton1Click:Connect(function()
		if labelForgalmi.Text ~= "" then
			labelForgalmi.Text = ""
			playButtonClickSound()
		else
			playLongBeepSound()
		end
	end)
end

local clearButtonBevitel = futar_alap:WaitForChild("futar_bevitel"):FindFirstChild("next")
local pressCount = 0
local lastPressTime = 0

clearButtonBevitel.MouseButton1Click:Connect(function()
	local currentTime = tick()
	if currentTime - lastPressTime <= 1 then
		pressCount = pressCount + 1
		if pressCount == 3 then
			futar_alap:WaitForChild("futar_bevitel").label.Text = tostring(game.Players.LocalPlayer.UserId)
			pressCount = 0
		end
	else
		pressCount = 1
	end
	lastPressTime = currentTime
end)

local isActionInProgress = false

nextButtonBevitel.MouseButton1Click:Connect(function()
	if isActionInProgress then return end

	isActionInProgress = true

	if futar_alap:WaitForChild("futar_bevitel").label.Text == tostring(game.Players.LocalPlayer.UserId) then
		playButtonClickSound()
		wait(math.random(1,3))
		forgalmiFrame.Visible = not forgalmiFrame.Visible
		futarNev.Visible = true
	else
		playLongBeepSound()
	end

	isActionInProgress = false
end)


nextButtonForgalmi.MouseButton1Click:Connect(handleNextButtonForgalmi)

RunService.Heartbeat:Connect(function()
	updateInGameTime()
	updateDate()
end)
