

# futarCore

##  Tartalomjegyzék
majd

##  Bevezetés
majd

##  Inicializáció

> ***Figyelem!***
> *A FUTÁR csak akkor fog rendeltetés szerűen működni, ha a busz modellje a `Workspace`-ben van elhelyezve, egy mappában aminek a neve `"Buses"`!*


A FUTÁR onnan tudja, hogy meg kell jelennie, hogy ha a játékos egy `VehicleSeat`-ben ül, aminek a neve `"VehicleSeat"`.

```lua
local function isDriverSeat(part)
	return part:IsA("VehicleSeat") and part.Name == "VehicleSeat"
end
```
Ezt a függvényt a `"onSeated"` függvény használja.

A kijelző kezeléshéz tudnia kell, hogy hány darab kijelző van az adott buszban. Két féle kijelző típus létzik: `Dir` és `Num`. A Dir az irányt, a Num pedig a járatszámot jeleníti meg.

> ***Figyelem!***
> *A futár egy megadott úton keresi ezt a két kijelző típust, ezért fontos, hogy ha több kijelzőt szeretnénk hozzáadni, akkor ezt ne változtassuk, inkább duplikáljuk a már meglévő kijelzőket.
> Egyébként nincs maximum, csak minimum (1-1) limit a kijelzők darabszámában.*

```lua
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
```

Amikor a játékos be ül a buszba, a script lekéri a busz modell nevét, annak elérési útját, és megnézi, hogy létezik-e már a busznak egy egyedi azonosítója, ha nincs, akkor csinál. A nyert adatokat elküldi a szervernek, illetve ha a játékos nem ül (vagy nem a megfelelő helyen), akkor a FUTÁR kikapcsol, eltünik.

```lua
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
```
