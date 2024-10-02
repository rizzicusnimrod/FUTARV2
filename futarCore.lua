local players = game:GetService("Players")
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BusDataEvent = ReplicatedStorage:WaitForChild("BusDataEvent")
local SoundService = game:GetService("SoundService")
local futar_rovidsip = SoundService.bkkfutar:WaitForChild("futar_rovidsip")
local futar_hosszusip = SoundService.bkkfutar:WaitForChild("futar_hosszusip")
local BusesFolder = game.Workspace.Buses
local currentModelPath
local currentModelID
local currentModulePath = ""
local futarGui = player.PlayerGui:FindFirstChild("futar")
local foundDirs = {}
local foundNums = {}
local nextStop = nil

local function isDriverSeat(part)
    return part:IsA("VehicleSeat") and part.Name == "VehicleSeat"
end

local function getModelNameInFolder(part, folder)
    local model = part.Parent
    while model.Parent and model.Parent ~= folder do
        model = model.Parent
    end
    if model.Parent == folder then
        return model
    else
        return nil
    end
end

local function generateUniqueID()
    return tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999))
end

local function countDirsInModel(model)
    local count = 0
    local function searchForDirs(currentModel)
        for _, child in ipairs(currentModel:GetChildren()) do
            if string.match(child.Name, "^Dir%d+$") then
                count = count + 1
            end
            searchForDirs(child)
        end
    end
    searchForDirs(model)
    return count
end

local function countNumsInModel(model)
    local count = 0
    local function searchForNums(currentModel)
        for _, child in ipairs(currentModel:GetChildren()) do
            if string.match(child.Name, "^Num%d+$") then
                count = count + 1
            end
            searchForNums(child)
        end
    end
    searchForNums(model)
    return count
end

local function populateFoundDirs(model)
    local count = countDirsInModel(model)
    for i = 1, count do
        local dir = model:FindFirstChild("Dir" .. i, true)
        if dir then
            table.insert(foundDirs, dir.Name)
        end
    end
end

local function populateFoundNums(model)
    local count = countNumsInModel(model)
    for i = 1, count do
        local num = model:FindFirstChild("Num" .. i, true)
        if num then
            table.insert(foundNums, num.Name)
        end
    end
end

local function enableFutarGUI()
    if futarGui then
        futarGui.Enabled = true
    end
end

local function disableFutarGUI()
    if futarGui then
        futarGui.Enabled = false
    end
end

local function updateTimeLabel()
    if futarGui then
        local futar_alap = futarGui:FindFirstChild("futar_alap")
        if futar_alap then
            local timeLabel = futar_alap:FindFirstChild("time")
            if timeLabel then
                local clockTime = game.Lighting.ClockTime

                local hours = math.floor(clockTime)
                local minutes = math.floor((clockTime - hours) * 60)
                local seconds = math.floor(((clockTime - hours) * 3600) % 60)

                local formattedTime = string.format("%02d:%02d:%02d", hours, minutes, seconds)

                timeLabel.Text = formattedTime
            end
        end
    end
end

local function updateDateLabel()
    if futarGui then
        local futar_alap = futarGui:FindFirstChild("futar_alap")
        if futar_alap then
            local dateLabel = futar_alap:FindFirstChild("date")
            if dateLabel then
                local dayAbbreviations = {
                    ["Monday"] = "Hé",
                    ["Tuesday"] = "Ke",
                    ["Wednesday"] = "Sze",
                    ["Thursday"] = "Cs",
                    ["Friday"] = "Pé",
                    ["Saturday"] = "Szo",
                    ["Sunday"] = "Va"
                }
                local currentDate = os.date("%A", os.time())
                local abbreviation = dayAbbreviations[currentDate] or "???"
                local formattedDate = string.format("%s. %s", abbreviation, os.date("%y.%m.%d", os.time()))
                dateLabel.Text = formattedDate
            end
        end
    end
end

local function onSeated(isSeated, seatPart)
    if isSeated then
        if isDriverSeat(seatPart) then
            enableFutarGUI()
            local modelName = getModelNameInFolder(seatPart, BusesFolder)
            if modelName then
                currentModelPath = modelName:GetFullName()
                local mainIdValue = modelName:FindFirstChildOfClass("StringValue")
                if not mainIdValue then
                    currentModelID = generateUniqueID()
                    mainIdValue = Instance.new("StringValue")
                    mainIdValue.Name = currentModelID
                    mainIdValue.Value = currentModelID
                    mainIdValue.Parent = modelName
                else
                    currentModelID = mainIdValue.Value
                end
                foundDirs = {}
                foundNums = {}
                populateFoundDirs(modelName)
                populateFoundNums(modelName)

                BusDataEvent:FireServer(currentModelPath, currentModelID, foundDirs, foundNums)
            end
        end
    else
        disableFutarGUI()
    end
end

local function onLoginButtonClicked()
    if futarGui then
        local futar_alap = futarGui:FindFirstChild("futar_alap")
        if futar_alap then
            local futar_hatter = futar_alap:FindFirstChild("futar_hatter")
            if futar_hatter then
                local loginButton = futar_hatter:FindFirstChild("login")
                local futar_bevitel = futar_alap:FindFirstChild("futar_bevitel")
                if loginButton and futar_bevitel then
                    futar_rovidsip:Play()
                    futar_hatter.Visible = false
                    futar_bevitel.Visible = true
                end
            end
        end
    end
end

local function onNumberButtonClicked(number)
    local futar_bevitel = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel
    if futar_bevitel then
        local label = futar_bevitel:FindFirstChild("label")
        if label then
            if string.len(label.Text) < 9 then
                label.Text = label.Text .. number
                futar_rovidsip:Play()
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function onClearButtonClicked()
    local futar_bevitel = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel
    if futar_bevitel then
        local label = futar_bevitel:FindFirstChild("label")
        if label then
            if string.len(label.Text) > 0 then
                label.Text = ""
                futar_rovidsip:Play()
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function onBackButtonClicked()
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_alap then
        local futar_bevitel = futar_alap:FindFirstChild("futar_bevitel")
        local futar_hatter = futar_alap:FindFirstChild("futar_hatter")
        if futar_bevitel and futar_hatter then
            futar_rovidsip:Play()
            futar_bevitel.Visible = false
            futar_hatter.Visible = true
        end
    end
end

local function onNextButtonClicked()
    local futar_bevitel = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_bevitel and futar_alap then
        local label = futar_bevitel:FindFirstChild("label")
        local futar_nev = futar_alap:FindFirstChild("futar_nev")
        if label and futar_nev then
            if label.Text == tostring(game.Players.LocalPlayer.UserId) then
                futar_rovidsip:Play()
                futar_bevitel.Visible = false
                futar_nev.Visible = true
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function onFutarNevButtonClicked()
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_alap then
        local futar_nev = futar_alap:FindFirstChild("futar_nev")
        local futar_forgalmi = futar_alap:FindFirstChild("futar_forgalmi")
        if futar_nev and futar_forgalmi then
            futar_rovidsip:Play()
            futar_nev.Visible = false
            futar_forgalmi.Visible = true
        end
    end
end

local function onForgalmiNumberButtonClicked(number)
    local futar_forgalmi = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_forgalmi
    if futar_forgalmi then
        local Mezo = futar_forgalmi:FindFirstChild("Mezo")
        if Mezo then
            if string.len(Mezo.Text) < 4 then
                Mezo.Text = Mezo.Text .. number
                futar_rovidsip:Play()
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function onForgalmiClearButtonClicked()
    local futar_forgalmi = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_forgalmi
    if futar_forgalmi then
        local Mezo = futar_forgalmi:FindFirstChild("Mezo")
        if Mezo then
            if string.len(Mezo.Text) > 0 then
                Mezo.Text = ""
                futar_rovidsip:Play()
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function clearFutarValaszto()
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_alap then
        local futar_valaszto = futar_alap:FindFirstChild("futar_valaszto")
        if futar_valaszto then
            for _, child in ipairs(futar_valaszto:GetChildren()) do
                if string.match(child.Name, "^item%d+$") or child.Name == "template" then
                    child:Destroy()
                end
            end
            local template = game.Lighting:FindFirstChild("template")
            if template then
                template:Clone().Parent = futar_valaszto
            end
        end
    end
end

local function onFutarEnabledChanged(enabled)
    if not enabled then
        clearFutarValaszto()
    end
end

if futarGui then
    futarGui:GetPropertyChangedSignal("Enabled"):Connect(
        function()
            onFutarEnabledChanged(futarGui.Enabled)
        end
    )
end

local currentPage = 1
local maxItemsPerPage = 5
local totalItems = 0
local futar_valaszto = nil

local function updateDisplay()
    if futar_valaszto then
        local positions = {
            UDim2.new(0.016, 0, 0.276, 0),
            UDim2.new(0.016, 0, 0.411, 0),
            UDim2.new(0.016, 0, 0.546, 0),
            UDim2.new(0.016, 0, 0.681, 0),
            UDim2.new(0.016, 0, 0.816, 0)
        }
        local maxItemsPerPage = 5
        local startIndex = (currentPage - 1) * maxItemsPerPage + 1
        local endIndex = math.min(currentPage * maxItemsPerPage, totalItems)
        local itemIndex = 1

        for _, child in pairs(futar_valaszto:GetChildren()) do
            if child:IsA("GuiObject") and child.Name:match("^item%d+$") then
                child.Visible = false
            end
        end

        for i = startIndex, endIndex do
            local item = futar_valaszto:FindFirstChild("item" .. i)
            if item and itemIndex <= maxItemsPerPage then
                item.Visible = true
                item.Position = positions[itemIndex]
                itemIndex = itemIndex + 1
            end
        end

        local imageIndex
        if totalItems > 0 then
            imageIndex = math.ceil(totalItems / maxItemsPerPage)
            imageIndex = math.min(imageIndex, 5)
        else
            imageIndex = 1
        end
    end
end

local function onUpButtonClicked()
    if currentPage > 1 then
        currentPage = currentPage - 1
        updateDisplay()
        futar_rovidsip:Play()
    else
        futar_hosszusip:Play()
    end
end

local function onDownButtonClicked()
    local totalPages = math.ceil(totalItems / maxItemsPerPage)
    if currentPage < totalPages then
        currentPage = currentPage + 1
        updateDisplay()
        futar_rovidsip:Play()
    else
        futar_hosszusip:Play()
    end
end

local function handleCloneClick(clone, timetable)
    clone.MouseButton1Click:Connect(
        function()
            futar_rovidsip:Play()
            local i = tonumber(string.match(clone.Name, "%d+"))
            local term1Value = timetable.timetable[i].term1
            local lineValue = timetable.timetable[i].line
            local eafArg = timetable.timetable[i].args and timetable.timetable[i].args[1] or nil
            local busesFolder = game.Workspace.Buses
            local modelPath

            for _, model in ipairs(busesFolder:GetChildren()) do
                local idValue = model:FindFirstChild(currentModelID)
                if idValue then
                    modelPath = model
                    break
                end
            end

            if modelPath then
                for _, dirName in ipairs(foundDirs) do
                    local dir = modelPath:FindFirstChild(dirName, true)
                    if dir then
                        local gui = dir:FindFirstChild("GUI")
                        if gui then
                            if eafArg then
                                local alternatingText = {
                                    term1Value,
                                    "Elsőajtós járat\n Front-door boarding"
                                }
                                local index = 1
                                spawn(
                                    function()
                                        while eafArg do
                                            ReplicatedStorage.UpdateBusText:FireServer(gui, alternatingText[index])
                                            wait(index == 1 and 5 or 3)
                                            index = 3 - index
                                        end
                                    end
                                )
                            else
                                ReplicatedStorage.UpdateBusText:FireServer(gui, term1Value)
                            end
                        end
                    end
                end

                for _, numName in ipairs(foundNums) do
                    local num = modelPath:FindFirstChild(numName, true)
                    if num then
                        local gui = num:FindFirstChild("GUI")
                        if gui then
                            ReplicatedStorage.UpdateBusText:FireServer(gui, lineValue)
                        end
                    end
                end

                print(timetable.timetable[i].forda)

                local futar_alap = futarGui and futarGui.futar_alap
                if futar_alap then
                    local futar_alap1 = futar_alap:FindFirstChild("futar_alap1")
                    if futar_alap1 then
                        local jaratLabel = futar_alap1:FindFirstChild("jarat")
                        local eafLabel = futar_alap1:FindFirstChild("eaf")
                        if jaratLabel then
                            local localPlayerUserId = game.Players.LocalPlayer.UserId
                            jaratLabel.Text =
                                string.format(
                                "%s/   %s     %d",
                                timetable.timetable[i].futarCode,
                                lineValue,
                                localPlayerUserId
                            )
                        end
                        if eafLabel then
                            if eafArg then
                                eafLabel.Text = term1Value .. " EAF"
                            else
                                eafLabel.Text = term1Value
                            end
                        end

                        local function updateUpcomingStops(currentStartIndex)
                            local upcomingStopsFolder = futar_alap1:FindFirstChild("upcomingStops")
                            if upcomingStopsFolder then
                                local stops = timetable.timetable[i].stops
                                local numStops = #stops
                                local endIndex = math.min(currentStartIndex + 5, numStops)

                                for stopIndex = 1, 6 do
                                    local stopFrame = upcomingStopsFolder:FindFirstChild("stop" .. stopIndex)
                                    if stopFrame then
                                        local stopData = stops[currentStartIndex + stopIndex - 1]
                                        if stopData then
                                            stopFrame.Visible = true
                                            for stopKey, stopName in pairs(stopData) do
                                                if stopKey:match("^stop%d+$") then
                                                    stopFrame.name.Text = stopName
                                                end
                                            end
                                            stopFrame.time.Text = stopData.departure
                                        else
                                            stopFrame.Visible = false
                                        end
                                    end
                                end
                            end
                        end

                        local currentStartIndex = 1
                        local scrollBuffer = 5
                        local function canScrollUp()
                            return currentStartIndex > 1
                        end
                        local function canScrollDown()
                            return currentStartIndex + 5 < #timetable.timetable[i].stops + scrollBuffer
                        end
                        updateUpcomingStops(currentStartIndex)

                        local upcomingStopsFolder = futar_alap1:FindFirstChild("upcomingStops")
                        if upcomingStopsFolder then
                            local upButton = upcomingStopsFolder:FindFirstChild("up")
                            local downButton = upcomingStopsFolder:FindFirstChild("down")

                            if upButton and downButton then
                                upButton.MouseButton1Click:Connect(
                                    function()
                                        if canScrollUp() then
                                            currentStartIndex = currentStartIndex - 1
                                            updateUpcomingStops(currentStartIndex)
                                            futar_rovidsip:Play()
                                        else
                                            futar_hosszusip:Play()
                                        end
                                    end
                                )

                                downButton.MouseButton1Click:Connect(
                                    function()
                                        if canScrollDown() then
                                            currentStartIndex = currentStartIndex + 1
                                            updateUpcomingStops(currentStartIndex)
                                            futar_rovidsip:Play()
                                        else
                                            futar_hosszusip:Play()
                                        end
                                    end
                                )
                            end
                        end

                        futar_alap1.Visible = true

                        nextStop = timetable.timetable[i].stops[1].stop1
                        print(nextStop)

                        local supportedDisplays = {"LawoNagyClassic"}
                        local function findDisplayInChildren(parent)
                            for _, child in ipairs(parent:GetChildren()) do
                                if child.Name == "LawoNagyClassic" then
                                    print("LawoNagyClassic display found in the bus model.")
                                    return child
                                else
                                    local found = findDisplayInChildren(child)
                                    if found then
                                        return found
                                    end
                                end
                            end
                            return nil
                        end

                        local displayModel = findDisplayInChildren(modelPath)

                        if displayModel then
                            if displayModel.Name == "LawoNagyClassic" then
                                local base = displayModel:FindFirstChild("Base")
                                if base then
                                    local gui = base:FindFirstChild("GUI")
                                    if gui then
                                        local imageLabel = gui:FindFirstChild("ImageLabel")
                                        if imageLabel then
                                            local dirLabel = imageLabel:FindFirstChild("Dir")
                                            local numLabel = imageLabel:FindFirstChild("Num")
                                            local stop1Label = imageLabel:FindFirstChild("Stop1")
                                            local stop2Label = imageLabel:FindFirstChild("Stop2")
                                            local stop3Label = imageLabel:FindFirstChild("Stop3")
                                            local timeLabel = imageLabel:FindFirstChild("time")

                                            local ReplicatedStorage = game:GetService("ReplicatedStorage")
                                            local UpdateDirLabelText = Instance.new("RemoteEvent")
                                            UpdateDirLabelText.Name = "UpdateDirLabelText"
                                            UpdateDirLabelText.Parent = ReplicatedStorage

                                            if dirLabel then
                                                dirLabel.Text = timetable.timetable[i].term1
                                                ReplicatedStorage.UpdateDirLabelText:FireServer(dirLabel.Text)
                                            end

                                            if numLabel then
                                                numLabel.Text = timetable.timetable[i].line
                                            end

                                            if stop1Label then
                                                stop1Label.Text = nextStop
                                            end

                                            if stop2Label then
                                                local stop2Index = nextStop + 1
                                                if timetable.timetable[i].stops[stop2Index] then
                                                    stop2Label.Text =
                                                        timetable.timetable[i].stops[stop2Index]["stop" .. stop2Index]
                                                else
                                                    stop2Label.Text = ""
                                                end
                                            end

                                            if stop3Label then
                                                local stop3Index = nextStop + 2
                                                if timetable.timetable[i].stops[stop3Index] then
                                                    stop3Label.Text =
                                                        timetable.timetable[i].stops[stop3Index]["stop" .. stop3Index]
                                                else
                                                    stop3Label.Text = ""
                                                end
                                            end
                                        else
                                            print("ImageLabel not found under LawoNagyClassic.Base.GUI.")
                                        end
                                    else
                                        print("GUI not found under Base.")
                                    end
                                else
                                    print("Base not found under LawoNagyClassic.")
                                end
                            end
                        end
                    end
                end

                local futar_valaszto = futar_alap and futar_alap:FindFirstChild("futar_valaszto")
                if futar_valaszto then
                    futar_valaszto.Visible = false
                end
            end
        end
    )
end

local function onForgalmiNextButtonClicked()
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_alap then
        local futar_forgalmi = futar_alap:FindFirstChild("futar_forgalmi")
        futar_valaszto = futar_alap:FindFirstChild("futar_valaszto")
        local Mezo = futar_forgalmi and futar_forgalmi:FindFirstChild("Mezo")
        local template = game.Lighting.template
        if Mezo then
            local moduleName = Mezo.Text
            local moduleScript = game.ReplicatedStorage.Shared:FindFirstChild(moduleName)
            if moduleScript then
                local success, timetable = pcall(require, moduleScript)
                if success and timetable and type(timetable) == "table" and #timetable.timetable > 0 then
                    clearFutarValaszto()
                    futar_valaszto.Visible = true
                    totalItems = 0
                    currentPage = 1

                    for i = 1, #timetable.timetable do
                        local args = timetable.timetable[i].args or {}
                        local hasInaktiv = false

                        for _, arg in ipairs(args) do
                            if (arg == "inaktiv") then
                                hasInaktiv = true
                                break
                            end
                        end

                        if (not hasInaktiv) then
                            totalItems = totalItems + 1
                            local clone = template:Clone()
                            clone.Name = "item" .. totalItems
                            clone.Visible = true
                            clone.Parent = futar_valaszto
                            handleCloneClick(clone, timetable)
                            clone.terminus0.Text = timetable.timetable[i].term0
                            clone.terminus1.Text = timetable.timetable[i].term1
                            clone.line.Text = timetable.timetable[i].line
                            clone.forda.Text = timetable.timetable[i].forda

                            local firstStop = timetable.timetable[i].stops[1]
                            local departureTime = firstStop and firstStop.departure or "00:00"
                            local hh, mm = string.match(departureTime, "(%d%d):(%d%d)")
                            if (hh and mm) then
                                departureTime = string.format("%02d:%02d", hh, mm)
                            else
                                departureTime = "--:--"
                            end
                            clone.dept.Text = departureTime

                            local eafActive = false
                            for _, arg in ipairs(args) do
                                if (arg == "eaf") then
                                    eafActive = true
                                    break
                                end
                            end
                            if (eafActive) then
                                clone.aux.Text = "EAF"
                            else
                                clone.aux.Text = ""
                            end
                        end
                    end

                    local originalTemplate = futar_valaszto:FindFirstChild("template")
                    if (originalTemplate) then
                        originalTemplate:Destroy()
                    end

                    updateDisplay()

                    local activeItemCount = futar_valaszto:GetChildren()
                    local imageIndex = math.min(#activeItemCount, 5)
                    local imageId = {
                        [1] = "http://www.roblox.com/asset/?id=16231388819",
                        [2] = "http://www.roblox.com/asset/?id=16231391876",
                        [3] = "http://www.roblox.com/asset/?id=16231395266",
                        [4] = "http://www.roblox.com/asset/?id=16231402542",
                        [5] = "http://www.roblox.com/asset/?id=16231405508"
                    }

                    if (imageId[imageIndex]) then
                        print("mcisti")
                    end

                    local upButton = futar_valaszto:FindFirstChild("up")
                    local downButton = futar_valaszto:FindFirstChild("down")
                    if (upButton) then
                        upButton.MouseButton1Click:Connect(onUpButtonClicked)
                    end
                    if (downButton) then
                        downButton.MouseButton1Click:Connect(onDownButtonClicked)
                    end

                    if (futar_forgalmi) then
                        futar_forgalmi.Visible = false
                    end

                    futar_rovidsip:Play()
                else
                    futar_hosszusip:Play()
                end
            else
                futar_hosszusip:Play()
            end
        end
    end
end

local function onForgalmiBackButtonClicked()
    local futar_alap = futarGui and futarGui.futar_alap
    if futar_alap then
        local futar_forgalmi = futar_alap:FindFirstChild("futar_forgalmi")
        local futar_bevitel = futar_alap:FindFirstChild("futar_bevitel")
        if futar_forgalmi and futar_bevitel then
            futar_forgalmi.Visible = false
            futar_bevitel.Visible = true
            futar_rovidsip:Play()
        end
    end
end

local loginButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_hatter and
    futarGui.futar_alap.futar_hatter:FindFirstChild("login")
if loginButton then
    loginButton.MouseButton1Click:Connect(onLoginButtonClicked)
    loginButton.MouseButton1Click:Connect(
        function()
            futar_rovidsip:Play()
        end
    )
end

local idLabel =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_nev and
    futarGui.futar_alap.futar_nev:FindFirstChild("id")
local nameLabel =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_nev and
    futarGui.futar_alap.futar_nev:FindFirstChild("name")
if idLabel and nameLabel then
    idLabel.Text = tostring(game.Players.LocalPlayer.UserId)
    nameLabel.Text = game.Players.LocalPlayer.Name
end

local backButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel and
    futarGui.futar_alap.futar_bevitel:FindFirstChild("back")
if backButton then
    backButton.MouseButton1Click:Connect(onBackButtonClicked)
end

local nextButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel and
    futarGui.futar_alap.futar_bevitel:FindFirstChild("next")
if nextButton then
    nextButton.MouseButton1Click:Connect(onNextButtonClicked)
end

local futarNevButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_nev and
    futarGui.futar_alap.futar_nev:FindFirstChild("TextButton")
if futarNevButton then
    futarNevButton.MouseButton1Click:Connect(onFutarNevButtonClicked)
end

local numberButtons = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_bevitel
for i = 0, 9 do
    local button = numberButtons and numberButtons:FindFirstChild(tostring(i))
    if button then
        button.MouseButton1Click:Connect(
            function()
                onNumberButtonClicked(tostring(i))
            end
        )
    end
end

local clearButton = numberButtons and numberButtons:FindFirstChild("C")
if clearButton then
    clearButton.MouseButton1Click:Connect(onClearButtonClicked)
end

local forgalmiNumberButtons = futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_forgalmi
for i = 0, 9 do
    local button = forgalmiNumberButtons and forgalmiNumberButtons:FindFirstChild(tostring(i))
    if button then
        button.MouseButton1Click:Connect(
            function()
                onForgalmiNumberButtonClicked(tostring(i))
            end
        )
    end
end

local forgalmiClearButton = forgalmiNumberButtons and forgalmiNumberButtons:FindFirstChild("C")
if forgalmiClearButton then
    forgalmiClearButton.MouseButton1Click:Connect(onForgalmiClearButtonClicked)
end

local forgalmiBackButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_forgalmi and
    futarGui.futar_alap.futar_forgalmi:FindFirstChild("back")
if forgalmiBackButton then
    forgalmiBackButton.MouseButton1Click:Connect(onForgalmiBackButtonClicked)
end

local forgalmiNextButton =
    futarGui and futarGui.futar_alap and futarGui.futar_alap.futar_forgalmi and
    futarGui.futar_alap.futar_forgalmi:FindFirstChild("next")
if forgalmiNextButton then
    forgalmiNextButton.MouseButton1Click:Connect(onForgalmiNextButtonClicked)
end

humanoid.Seated:Connect(onSeated)
game:GetService("RunService").Heartbeat:Connect(updateTimeLabel)
game:GetService("RunService").Heartbeat:Connect(updateDateLabel)
