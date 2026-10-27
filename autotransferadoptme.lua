local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiName = "FantasyPlatformSelector"
if PlayerGui:FindFirstChild(guiName) then
    PlayerGui[guiName]:Destroy()
end

local function runReceiverScript()
    local oldGui = PlayerGui:FindFirstChild("AdoptMeAutoReceiverUI")
    if oldGui then
        oldGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdoptMeAutoReceiverUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 210)
    MainFrame.Position = UDim2.new(0.5, -160, 0.4, -105)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "AUTO TRADE RECEIVER"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.Parent = MainFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Name = "SenderInput"
    TextBox.Size = UDim2.new(0.88, 0, 0, 36)
    TextBox.Position = UDim2.new(0.06, 0, 0.22, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Ник отправителя (пусто = любой)..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 13
    TextBox.ClearTextOnFocus = false
    TextBox.Text = ""
    TextBox.Parent = MainFrame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 8)
    BoxCorner.Parent = TextBox

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.88, 0, 0, 22)
    StatusLabel.Position = UDim2.new(0.06, 0, 0.44, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Ожидание запуска..."
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    StatusLabel.TextSize = 12
    StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    StatusLabel.Parent = MainFrame

    local StartBtn = Instance.new("TextButton")
    StartBtn.Name = "StartButton"
    StartBtn.Size = UDim2.new(0.88, 0, 0, 42)
    StartBtn.Position = UDim2.new(0.06, 0, 0.62, 0)
    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    StartBtn.Font = Enum.Font.GothamBold
    StartBtn.Text = "START LISTENER"
    StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartBtn.TextSize = 15
    StartBtn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = StartBtn

    local function setStatus(text, color)
        pcall(function()
            StatusLabel.Text = text
            StatusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 210)
        end)
    end

    local API = ReplicatedStorage:WaitForChild("API", 5)
    local TradeRequestReceived = API and API:WaitForChild("TradeAPI/TradeRequestReceived", 5)
    local AcceptOrDecline = API and API:WaitForChild("TradeAPI/AcceptOrDeclineTradeRequest", 5)
    local AcceptNegotiation = API and API:WaitForChild("TradeAPI/AcceptNegotiation", 5)
    local ConfirmTrade = API and API:WaitForChild("TradeAPI/ConfirmTrade", 5)

    local UIManager
    pcall(function()
        local clientModules = ReplicatedStorage:WaitForChild("ClientModules", 3)
        if clientModules then
            local core = clientModules:WaitForChild("Core", 3)
            if core then
                UIManager = require(core:WaitForChild("UIManager", 3))
            end
        end
    end)

    local function getTradeApp()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        return pg and pg:FindFirstChild("TradeApp")
    end

    local function isTrulyVisible(guiObj)
        if not guiObj then return false end
        local current = guiObj
        while current and current:IsA("GuiObject") do
            if not current.Visible then
                return false
            end
            current = current.Parent
        end
        return true
    end

    local function isTradeWindowOpen()
        local tradeApp = getTradeApp()
        if tradeApp then
            local frame = tradeApp:FindFirstChild("Frame") or tradeApp:FindFirstChild("Container")
            if frame and isTrulyVisible(frame) then
                return true
            end
        end
        return false
    end

    local function dismissDiscoveryScreen()
        local pg = LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then return end

        local petApp = pg:FindFirstChild("PetDiscoveryApp")
        if not petApp or not petApp.Enabled then
            return
        end

        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.04)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        task.wait(0.1)

        if UIManager and UIManager.close_app then
            pcall(function() UIManager.close_app("PetDiscoveryApp") end)
        end

        local doneBtn = petApp:FindFirstChild("Frame")
            and petApp.Frame:FindFirstChild("NewPetsPage")
            and petApp.Frame.NewPetsPage:FindFirstChild("FooterButtons")
            and petApp.Frame.NewPetsPage.FooterButtons:FindFirstChild("Done")
            and petApp.Frame.NewPetsPage.FooterButtons.Done:FindFirstChild("DepthButton")

        if doneBtn and doneBtn.Visible then
            local inset = GuiService:GetGuiInset()
            local pos = doneBtn.AbsolutePosition
            local size = doneBtn.AbsoluteSize
            local clickX = pos.X + (size.X / 2)
            local clickY = pos.Y + (size.Y / 2) + inset.Y

            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
            task.wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
        end

        for _, item in ipairs(Lighting:GetChildren()) do
            if item:IsA("BlurEffect") then
                item.Size = 0
                item.Enabled = false
            end
        end
    end

    local isListening = false
    local filterSender = nil
    local activeConnection = nil

    local function handleActiveTrade()
        setStatus("Трейд открыт. Спам Accept/Confirm...", Color3.fromRGB(120, 240, 150))

        while isListening and isTradeWindowOpen() do
            pcall(function()
                AcceptNegotiation:FireServer()
            end)
            pcall(function()
                ConfirmTrade:FireServer()
            end)
            task.wait(1)
        end

        setStatus("Окно закрыто. Снятие экрана...", Color3.fromRGB(100, 220, 255))
        
        local closeStart = tick()
        while tick() - closeStart < 4 do
            dismissDiscoveryScreen()
            task.wait(0.3)
        end

        setStatus("Ожидание запроса на трейд...", Color3.fromRGB(240, 220, 100))
    end

    local function startListener(targetName)
        filterSender = targetName
        isListening = true

        setStatus("Ожидание запроса на трейд...", Color3.fromRGB(240, 220, 100))

        if activeConnection then
            activeConnection:Disconnect()
            activeConnection = nil
        end

        task.spawn(function()
            while isListening do
                if not isTradeWindowOpen() then
                    dismissDiscoveryScreen()
                end
                task.wait(0.5)
            end
        end)

        activeConnection = TradeRequestReceived.OnClientEvent:Connect(function(senderPlayer)
            if not isListening then return end
            if not senderPlayer or typeof(senderPlayer) ~= "Instance" or not senderPlayer:IsA("Player") then return end

            if filterSender and string.lower(senderPlayer.Name) ~= string.lower(filterSender) then
                return
            end

            dismissDiscoveryScreen()
            setStatus("Принятие от: " .. senderPlayer.Name, Color3.fromRGB(100, 200, 255))
            
            pcall(function()
                AcceptOrDecline:InvokeServer(senderPlayer, true)
            end)

            task.spawn(function()
                local waitOpen = tick()
                while tick() - waitOpen < 15 do
                    if not isListening then break end
                    if isTradeWindowOpen() then
                        handleActiveTrade()
                        break
                    end
                    task.wait(0.3)
                end
            end)
        end)
    end

    local function stopListener()
        isListening = false
        if activeConnection then
            activeConnection:Disconnect()
            activeConnection = nil
        end
        setStatus("Остановлено", Color3.fromRGB(240, 200, 80))
    end

    StartBtn.MouseButton1Click:Connect(function()
        if isListening then
            stopListener()
            StartBtn.Text = "START LISTENER"
            StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            return
        end

        local rawInput = TextBox.Text
        local cleanName = string.match(rawInput, "^%s*(.-)%s*$")
        local filterTarget = nil

        if cleanName and cleanName ~= "" then
            for _, plr in ipairs(Players:GetPlayers()) do
                if string.lower(plr.Name) == string.lower(cleanName) or string.lower(plr.DisplayName) == string.lower(cleanName) then
                    filterTarget = plr.Name
                    break
                end
            end
            if not filterTarget then
                setStatus("Игрок не найден на сервере!", Color3.fromRGB(255, 80, 80))
                return
            end
        end

        StartBtn.Text = "STOP LISTENER"
        StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

        startListener(filterTarget)
    end)
end

local function runSenderScript()
    local oldGui = PlayerGui:FindFirstChild("AdoptMeTradeTransferUI")
    if oldGui then
        oldGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdoptMeTradeTransferUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 210)
    MainFrame.Position = UDim2.new(0.5, -160, 0.4, -105)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 36)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = "AUTO TRANSFER & TELEPORT"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.TextSize = 14
    Title.Parent = MainFrame

    local TextBox = Instance.new("TextBox")
    TextBox.Name = "TargetInput"
    TextBox.Size = UDim2.new(0.88, 0, 0, 36)
    TextBox.Position = UDim2.new(0.06, 0, 0.22, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.PlaceholderText = "Введите ник игрока..."
    TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 160)
    TextBox.Font = Enum.Font.Gotham
    TextBox.TextSize = 14
    TextBox.ClearTextOnFocus = false
    TextBox.Text = ""
    TextBox.Parent = MainFrame

    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 8)
    BoxCorner.Parent = TextBox

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(0.88, 0, 0, 22)
    StatusLabel.Position = UDim2.new(0.06, 0, 0.44, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Text = "Ожидание ввода..."
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    StatusLabel.TextSize = 12
    StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    StatusLabel.Parent = MainFrame

    local StartBtn = Instance.new("TextButton")
    StartBtn.Name = "StartButton"
    StartBtn.Size = UDim2.new(0.88, 0, 0, 42)
    StartBtn.Position = UDim2.new(0.06, 0, 0.62, 0)
    StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    StartBtn.Font = Enum.Font.GothamBold
    StartBtn.Text = "начать передачу"
    StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartBtn.TextSize = 15
    StartBtn.Parent = MainFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = StartBtn

    local function setStatus(text, color)
        pcall(function()
            StatusLabel.Text = text
            StatusLabel.TextColor3 = color or Color3.fromRGB(200, 200, 210)
        end)
    end

    local isRunning = false
    local failedUntradableIds = {}

    local function runTransfer(targetPlayer)
        local API = ReplicatedStorage:WaitForChild("API", 3)
        if not API then
            setStatus("Ошибка: папка API не найдена", Color3.fromRGB(255, 80, 80))
            return
        end

        local SendTrade = API:WaitForChild("TradeAPI/SendTradeRequest", 3)
        local AddItem = API:WaitForChild("TradeAPI/AddItemToOffer", 3)
        local AcceptNegotiation = API:WaitForChild("TradeAPI/AcceptNegotiation", 3)
        local ConfirmTrade = API:WaitForChild("TradeAPI/ConfirmTrade", 3)

        local ClientData
        pcall(function()
            local clientModules = ReplicatedStorage:WaitForChild("ClientModules", 3)
            if clientModules then
                local core = clientModules:WaitForChild("Core", 3)
                if core then
                    ClientData = require(core:WaitForChild("ClientData", 3))
                end
            end
        end)

        local InventoryDB
        pcall(function()
            local clientModules = ReplicatedStorage:WaitForChild("ClientModules", 3)
            if clientModules then
                local core = clientModules:WaitForChild("Core", 3)
                if core then
                    InventoryDB = require(core:WaitForChild("InventoryDB", 3))
                end
            end
        end)

        local function getInventory()
            local inv
            pcall(function()
                if ClientData and ClientData.get then
                    inv = ClientData.get("inventory")
                end
                if not inv and ClientData and ClientData.get_data then
                    local all = ClientData.get_data()
                    local myData = all[LocalPlayer.Name] or all[tostring(LocalPlayer.UserId)]
                    inv = myData and myData.inventory
                end
            end)
            return inv
        end

        local function getTradeData()
            local tradeData
            pcall(function()
                if ClientData and ClientData.get then
                    tradeData = ClientData.get("trade")
                end
                if not tradeData and ClientData and ClientData.get_data then
                    local all = ClientData.get_data()
                    local myData = all[LocalPlayer.Name] or all[tostring(LocalPlayer.UserId)]
                    tradeData = myData and myData.trade
                end
            end)
            return tradeData
        end

        local function getTradeApp()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            return pg and pg:FindFirstChild("TradeApp")
        end

        local function isTrulyVisible(guiObj)
            if not guiObj then return false end
            local current = guiObj
            while current and current:IsA("GuiObject") do
                if not current.Visible then
                    return false
                end
                current = current.Parent
            end
            return true
        end

        local function isTradeWindowOpen()
            local tradeApp = getTradeApp()
            if tradeApp then
                local frame = tradeApp:FindFirstChild("Frame") or tradeApp:FindFirstChild("Container")
                if frame and isTrulyVisible(frame) then
                    return true
                end
            end
            return false
        end

        local function isStillWaitingOnStage1()
            local tradeApp = getTradeApp()
            if not tradeApp then return false end
            for _, obj in ipairs(tradeApp:GetDescendants()) do
                if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                    if string.find(string.lower(obj.Text), "unaccept") and isTrulyVisible(obj) then
                        return true
                    end
                end
            end
            return false
        end

        local function isStage2Active()
            local t = getTradeData()
            if t and t.current_trade then
                local stage = tostring(t.current_trade.stage or "")
                if stage == "confirmation" or stage == "2" then
                    return true
                end
            end
            local tradeApp = getTradeApp()
            if tradeApp then
                for _, obj in ipairs(tradeApp:GetDescendants()) do
                    if obj:IsA("TextLabel") and isTrulyVisible(obj) then
                        if string.find(string.lower(obj.Text), "fair") then
                            return true
                        end
                    end
                end
            end
            return false
        end

        local function isTradable(uniqueId, petData)
            if failedUntradableIds[uniqueId] then
                return false
            end
            if petData.untradable == true or petData.is_untradable == true or petData.tradeable == false then
                return false
            end
            if petData.properties then
                if petData.properties.untradable or petData.properties.is_untradable or petData.properties.tradeable == false then
                    return false
                end
            end

            local petKind = tostring(petData.id or petData.kind or ""):lower()
            if string.find(petKind, "starter") or string.find(petKind, "tutorial") then
                return false
            end

            if InventoryDB and InventoryDB.pets then
                local staticData = InventoryDB.pets[petKind] or (InventoryDB.get and InventoryDB.get(petKind))
                if staticData then
                    if staticData.untradable == true or staticData.is_untradable == true or staticData.tradeable == false then
                        return false
                    end
                end
            end

            return true
        end

        local function getConfirmDelay(itemCount)
            if itemCount <= 2 then return 1
            elseif itemCount == 3 then return 1
            elseif itemCount == 4 then return 1
            elseif itemCount == 5 then return 1
            elseif itemCount == 6 then return 1
            elseif itemCount == 7 then return 1
            else return 1 end
        end

        local function getTradablePets(limit)
            local petIds = {}
            local inv = getInventory()
            if not inv or not inv.pets then return petIds end

            for uniqueId, petData in pairs(inv.pets) do
                if isTradable(uniqueId, petData) then
                    table.insert(petIds, uniqueId)
                    if limit and #petIds >= limit then
                        break
                    end
                end
            end
            return petIds
        end

        local function teleportToPlayer(target)
            if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    task.wait(0.4)
                end
            end
        end

        local sessionCount = 0

        while isRunning do
            local remaining = getTradablePets(nil)
            if #remaining == 0 then
                setStatus("Все питомцы переданы!", Color3.fromRGB(80, 255, 120))
                break
            end

            sessionCount = sessionCount + 1
            setStatus("Трейд #" .. sessionCount .. " (Осталось: " .. #remaining .. ")", Color3.fromRGB(240, 240, 240))

            if not targetPlayer or not targetPlayer.Parent then
                setStatus("Игрок вышел с сервера", Color3.fromRGB(255, 80, 80))
                break
            end

            teleportToPlayer(targetPlayer)

            setStatus("Отправка трейда...", Color3.fromRGB(240, 220, 100))
            SendTrade:FireServer(targetPlayer)

            local opened = false
            local startWait = tick()
            while tick() - startWait < 45 do
                if not isRunning then return end
                if isTradeWindowOpen() then
                    opened = true
                    break
                end
                task.wait(0.5)
            end

            if not opened then
                setStatus("Трейд не принят, повтор...", Color3.fromRGB(255, 160, 60))
                task.wait(2)
                continue
            end

            setStatus("Выкладывание предметов...", Color3.fromRGB(100, 200, 255))
            task.wait(1.2)

            local currentBatch = getTradablePets(18)
            local totalAdded = #currentBatch
            if totalAdded == 0 then break end

            local aborted = false
            for i, uniqueId in ipairs(currentBatch) do
                if not isTradeWindowOpen() or not isRunning then
                    aborted = true
                    break
                end

                AddItem:FireServer(uniqueId)
                task.wait(0.01)

                local pg = LocalPlayer:FindFirstChild("PlayerGui")
                if pg then
                    for _, label in ipairs(pg:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Visible then
                            if string.find(string.lower(label.Text), "not tradeable") then
                                failedUntradableIds[uniqueId] = true
                                break
                            end
                        end
                    end
                end
            end

            if aborted then
                task.wait(2)
                continue
            end

            setStatus("Ожидание 5 сек перед Accept...", Color3.fromRGB(240, 240, 100))
            task.wait(5)

            if not isTradeWindowOpen() or not isRunning then
                task.wait(2)
                continue
            end

            setStatus("Нажатие Accept...", Color3.fromRGB(100, 220, 100))
            AcceptNegotiation:FireServer()

            setStatus("Ожидание оппонента...", Color3.fromRGB(240, 220, 100))
            local stage2Reached = false
            local waitOpponent = tick()

            while tick() - waitOpponent < 60 do
                if not isTradeWindowOpen() or not isRunning then
                    aborted = true
                    break
                end
                if not isStillWaitingOnStage1() and isStage2Active() then
                    stage2Reached = true
                    break
                end
                task.wait(0.25)
            end

            if aborted or not stage2Reached then
                setStatus("Трейд сброшен оппонентом", Color3.fromRGB(255, 100, 100))
                task.wait(2)
                continue
            end

            local waitDuration = getConfirmDelay(totalAdded)
            local timerStart = tick()

            while tick() - timerStart < waitDuration do
                if not isTradeWindowOpen() or not isRunning then
                    aborted = true
                    break
                end
                local left = math.ceil(waitDuration - (tick() - timerStart))
                setStatus("Confirm через: " .. left .. " сек.", Color3.fromRGB(120, 240, 150))
                task.wait(0.2)
            end

            if aborted then
                task.wait(2)
                continue
            end

            setStatus("Подтверждение трейда...", Color3.fromRGB(80, 255, 120))
            ConfirmTrade:FireServer()

            local waitClose = tick()
            while tick() - waitClose < 25 do
                if not isTradeWindowOpen() then break end
                task.wait(0.4)
            end

            task.wait(2.5)
        end

        isRunning = false
        pcall(function()
            StartBtn.Text = "начать передачу"
            StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        end)
    end

    StartBtn.MouseButton1Click:Connect(function()
        if isRunning then
            isRunning = false
            StartBtn.Text = "начать передачу"
            StartBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            setStatus("Процесс остановлен", Color3.fromRGB(240, 200, 80))
            return
        end

        local rawInput = TextBox.Text
        local cleanName = string.match(rawInput, "^%s*(.-)%s*$")

        if not cleanName or cleanName == "" then
            setStatus("Введите ник игрока!", Color3.fromRGB(255, 80, 80))
            return
        end

        local foundPlayer = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if string.lower(plr.Name) == string.lower(cleanName) or string.lower(plr.DisplayName) == string.lower(cleanName) then
                foundPlayer = plr
                break
            end
        end

        if not foundPlayer then
            setStatus("Игрок не найден!", Color3.fromRGB(255, 80, 80))
            return
        end

        isRunning = true
        StartBtn.Text = "остановить передачу"
        StartBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        setStatus("Цель: " .. foundPlayer.Name, Color3.fromRGB(100, 220, 255))

        task.spawn(function()
            runTransfer(foundPlayer)
        end)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = guiName
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
MainFrame.Position = UDim2.new(0.5, -165, 0.5, -115)
MainFrame.Size = UDim2.new(0, 330, 0, 230)

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 14)
UICorner_Main.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 54, 62)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 24, 28))
})
MainGradient.Rotation = 45
MainGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(155, 168, 185)
UIStroke.Thickness = 3

local InnerBevel = Instance.new("Frame")
InnerBevel.Parent = MainFrame
InnerBevel.Size = UDim2.new(1, -10, 1, -10)
InnerBevel.Position = UDim2.new(0, 5, 0, 5)
InnerBevel.BackgroundTransparency = 1
local InnerStroke = Instance.new("UIStroke")
InnerStroke.Parent = InnerBevel
InnerStroke.Color = Color3.fromRGB(12, 13, 16)
InnerStroke.Thickness = 1.5
local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 10)
InnerCorner.Parent = InnerBevel

local function createRune(char, pos)
    local rune = Instance.new("TextLabel")
    rune.Parent = MainFrame
    rune.BackgroundTransparency = 1
    rune.Position = pos
    rune.Size = UDim2.new(0, 20, 0, 20)
    rune.Font = Enum.Font.GothamBold
    rune.Text = char
    rune.TextColor3 = Color3.fromRGB(200, 225, 255)
    rune.TextSize = 13
    rune.ZIndex = 3
    
    local glow = Instance.new("UIStroke")
    glow.Parent = rune
    glow.Color = Color3.fromRGB(120, 175, 255)
    glow.Transparency = 0.3
    glow.Thickness = 1
end

createRune("❖", UDim2.new(0, 10, 0, 10))
createRune("❖", UDim2.new(1, -30, 0, 10))
createRune("❖", UDim2.new(0, 10, 1, -30))
createRune("❖", UDim2.new(1, -30, 1, -30))

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.08, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBlack
Title.Text = "выбери роль"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.ZIndex = 2

local TitleGlow = Instance.new("UIStroke")
TitleGlow.Parent = Title
TitleGlow.Color = Color3.fromRGB(90, 140, 220)
TitleGlow.Thickness = 1.2

local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Line.BorderSizePixel = 0
Line.Position = UDim2.new(0.1, 0, 0.25, 0)
Line.Size = UDim2.new(0.8, 0, 0, 2)
    
local LineGrad = Instance.new("UIGradient")
LineGrad.Parent = Line
LineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 38, 45)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 215, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 38, 45))
})

local function createCrystalButton(name, text, yPos, topColor, bottomColor, strokeColor)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Parent = MainFrame
    Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Button.Position = UDim2.new(0.1, 0, yPos, 0)
    Button.Size = UDim2.new(0.8, 0, 0, 48)
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    Button.Text = ""

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 9)
    UICorner.Parent = Button

    local BtnGradient = Instance.new("UIGradient")
    BtnGradient.Parent = Button
    BtnGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, topColor),
        ColorSequenceKeypoint.new(1, bottomColor)
    })
    BtnGradient.Rotation = 90

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Parent = Button
    BtnStroke.Color = strokeColor
    BtnStroke.Thickness = 2

    local Highlight = Instance.new("Frame")
    Highlight.Parent = Button
    Highlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Highlight.BackgroundTransparency = 0.88
    Highlight.BorderSizePixel = 0
    Highlight.Size = UDim2.new(1, 0, 0.45, 0)
    Highlight.ZIndex = 2
    local HCorner = Instance.new("UICorner")
    HCorner.CornerRadius = UDim.new(0, 9)
    HCorner.Parent = Highlight

    local Label = Instance.new("TextLabel")
    Label.Parent = Button
    Label.BackgroundTransparency = 1
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.Font = Enum.Font.GothamBold
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 15
    Label.ZIndex = 3

    local LabelStroke = Instance.new("UIStroke")
    LabelStroke.Parent = Label
    LabelStroke.Color = Color3.fromRGB(5, 10, 20)
    LabelStroke.Thickness = 1.5

    Button.MouseEnter:Connect(function()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Thickness = 3, Color = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(Highlight, TweenInfo.new(0.2), {BackgroundTransparency = 0.72}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(BtnStroke, TweenInfo.new(0.2), {Thickness = 2, Color = strokeColor}):Play()
        TweenService:Create(Highlight, TweenInfo.new(0.2), {BackgroundTransparency = 0.88}):Play()
    end)

    return Button
end

local AcceptButton = createCrystalButton(
    "AcceptButton", 
    "Принимать скины", 
    0.37, 
    Color3.fromRGB(55, 115, 230),
    Color3.fromRGB(20, 50, 125),
    Color3.fromRGB(130, 195, 255)
)

local SendButton = createCrystalButton(
    "SendButton", 
    "Отдавать скины", 
    0.65, 
    Color3.fromRGB(45, 175, 95),
    Color3.fromRGB(15, 75, 40),
    Color3.fromRGB(130, 255, 175)
)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

AcceptButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    runReceiverScript()
end)

SendButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    runSenderScript()
end)
