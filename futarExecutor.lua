local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BusDataEvent = Instance.new("RemoteEvent")
BusDataEvent.Name = "BusDataEvent"
BusDataEvent.Parent = ReplicatedStorage

local UpdateBusText = ReplicatedStorage.UpdateBusText

BusDataEvent.OnServerEvent:Connect(function(player, currentModelPath, currentModelID, foundDirs, foundNums)
	print("Received data from player", player.Name)
	print("Current Model Path:", currentModelPath)
	print("Current Model ID:", currentModelID)
	print("Current Model ID:", foundDirs)
	print("Current Model ID:", foundNums)
end)

UpdateBusText.OnServerEvent:Connect(function(Player, Gui, Term)
	local text = Gui:FindFirstChild("Text")
	if text then
		local textText = text
		if textText then
			textText.Text = Term
		end
	end
end)
