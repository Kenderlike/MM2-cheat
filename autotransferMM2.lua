local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local guiName = "RoleSelectorWindow"
if PlayerGui:FindFirstChild(guiName) then
    PlayerGui[guiName]:Destroy()
end

local function runReceiverScript()
    for _, item in ipairs(PlayerGui:GetChildren()) do
        if item.Name == "MM2AcceptSpamWindow" then
            item:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2AcceptSpamWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 140, 255)
    MainFrame.Position = UDim2.new(0.5, -125, 0.35, 0)
    MainFrame.Size = UDim2.new(0, 250, 0, 180)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "MM2 Auto Accept"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = MainFrame
    TextBox.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    TextBox.BorderSizePixel = 1
    TextBox.BorderColor3 = Color3.fromRGB(75, 75, 75)
    TextBox.Position = UDim2.new(0.1, 0, 0.28, 0)
    TextBox.Size = UDim2.new(0.8, 0, 0, 35)
    TextBox.Font = Enum.Font.SourceSans
    TextBox.PlaceholderText = "Ник отправителя"
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = MainFrame
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Position = UDim2.new(0.1, 0, 0.60, 0)
    ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "Включить авто-принятие"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 15

    task.spawn(function()
        local Trade = ReplicatedStorage:WaitForChild("Trade")

        local targetName = ""
        local isListening = false
        local inTradeWithTarget = false
        local currentToken = 19746.27066437801

        local function checkIsTarget(name)
            if not name or targetName == "" then return false end
            return string.lower(tostring(name)) == string.lower(targetName)
        end

        local function getTradeStatus()
            local ok, res = pcall(function()
                return Trade.GetTradeStatus:InvokeServer()
            end)
            return ok and res or "None"
        end

        local function acceptIncomingRequest()
            pcall(function()
                local remote = Trade:FindFirstChild("AcceptRequest")
                if remote then
                    if remote:IsA("RemoteEvent") then
                        remote:FireServer()
                    else
                        remote:InvokeServer()
                    end
                end
            end)
        end

        local function resetState()
            isListening = false
            inTradeWithTarget = false
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            ToggleButton.Text = "Включить авто-принятие"
        end

        Trade:WaitForChild("UpdateTrade").OnClientEvent:Connect(function(data)
            if type(data) == "table" and data.LastOffer ~= nil then
                currentToken = data.LastOffer
            end
        end)

        Trade:WaitForChild("DeclineTrade").OnClientEvent:Connect(function()
            inTradeWithTarget = false
        end)

        Trade:WaitForChild("AcceptTrade").OnClientEvent:Connect(function()
            inTradeWithTarget = false
        end)

        Trade:WaitForChild("StartTrade").OnClientEvent:Connect(function(tradeData, partnerName)
            if not isListening then return end

            local isMatch = false
            if checkIsTarget(partnerName) then
                isMatch = true
            elseif type(tradeData) == "table" then
                local p1 = tradeData.Player1 and tradeData.Player1.Player
                local p2 = tradeData.Player2 and tradeData.Player2.Player
                local p1Name = typeof(p1) == "Instance" and p1.Name or tostring(p1)
                local p2Name = typeof(p2) == "Instance" and p2.Name or tostring(p2)

                if checkIsTarget(p1Name) or checkIsTarget(p2Name) then
                    isMatch = true
                end
            end

            if isMatch then
                inTradeWithTarget = true

                task.spawn(function()
                    while inTradeWithTarget and isListening do
                        task.spawn(function()
                            pcall(function()
                                ReplicatedStorage.Remotes.Extras.GetChance:InvokeServer()
                            end)
                        end)

                        pcall(function()
                            Trade.AcceptTrade:FireServer(table.unpack({
                                [1] = 428469873,
                                [2] = currentToken,
                            }))
                        end)

                        task.wait(0.5)
                    end
                end)
            end
        end)

        task.spawn(function()
            while true do
                if isListening and not inTradeWithTarget then
                    local status = getTradeStatus()
                    if status == "ReceivingRequest" then
                        acceptIncomingRequest()
                        task.wait(0.5)
                    end
                end
                task.wait(0.3)
            end
        end)

        ToggleButton.MouseButton1Click:Connect(function()
            if isListening then
                resetState()
                return
            end

            local input = TextBox.Text:gsub("%s+", "")
            if input == "" then
                warn("Введите ник игрока")
                return
            end

            targetName = input
            isListening = true
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
            ToggleButton.Text = "Остановить слежение"
        end)
    end)
end

local function runSenderScript()
    for _, item in ipairs(PlayerGui:GetChildren()) do
        if item.Name == "MM2AutoTradeWindow" then
            item:Destroy()
        end
    end

    local selectedRarities = {
        Ancient = true,
        Godly = true,
        Vintage = true,
        Legendary = true,
        Rare = true,
        Uncommon = true,
        Common = true
    }

    local rarityDisplayList = {
        "Ancient", "Godly", "Vintage", "Legendary", "Rare", "Uncommon", "Common"
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MM2AutoTradeWindow"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 999999
    ScreenGui.Parent = PlayerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(0, 140, 255)
    MainFrame.Position = UDim2.new(0.5, -135, 0.25, 0)
    MainFrame.Size = UDim2.new(0, 270, 0, 360)
    MainFrame.Active = true
    MainFrame.Draggable = true

    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Font = Enum.Font.SourceSansBold
    Title.Text = "MM2 AutoTransfer"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16

    local TextBox = Instance.new("TextBox")
    TextBox.Parent = MainFrame
    TextBox.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
    TextBox.BorderSizePixel = 1
    TextBox.BorderColor3 = Color3.fromRGB(75, 75, 75)
    TextBox.Position = UDim2.new(0.08, 0, 0, 40)
    TextBox.Size = UDim2.new(0.84, 0, 0, 32)
    TextBox.Font = Enum.Font.SourceSans
    TextBox.PlaceholderText = "Ник игрока"
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.TextSize = 14

    local RarityLabel = Instance.new("TextLabel")
    RarityLabel.Parent = MainFrame
    RarityLabel.BackgroundTransparency = 1
    RarityLabel.Position = UDim2.new(0.08, 0, 0, 78)
    RarityLabel.Size = UDim2.new(0.84, 0, 0, 18)
    RarityLabel.Font = Enum.Font.SourceSansBold
    RarityLabel.Text = "Выберите редкости для передачи:"
    RarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    RarityLabel.TextSize = 13
    RarityLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Parent = MainFrame
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(36, 36, 36)
    ScrollFrame.BorderSizePixel = 1
    ScrollFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    ScrollFrame.Position = UDim2.new(0.08, 0, 0, 100)
    ScrollFrame.Size = UDim2.new(0.84, 0, 0, 190)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, #rarityDisplayList * 27)
    ScrollFrame.ScrollBarThickness = 5

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = ScrollFrame
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 2)

    for i, rarity in ipairs(rarityDisplayList) do
        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Name = rarity
        ItemBtn.Parent = ScrollFrame
        ItemBtn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
        ItemBtn.BorderSizePixel = 0
        ItemBtn.Size = UDim2.new(1, -8, 0, 25)
        ItemBtn.Font = Enum.Font.SourceSans
        ItemBtn.Text = "  [✓] " .. rarity
        ItemBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
        ItemBtn.TextSize = 14
        ItemBtn.TextXAlignment = Enum.TextXAlignment.Left

        ItemBtn.MouseButton1Click:Connect(function()
            selectedRarities[rarity] = not selectedRarities[rarity]
            if selectedRarities[rarity] then
                ItemBtn.Text = "  [✓] " .. rarity
                ItemBtn.TextColor3 = Color3.fromRGB(0, 255, 128)
            else
                ItemBtn.Text = "  [✗] " .. rarity
                ItemBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
    end

    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Parent = MainFrame
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    ExecuteButton.BorderSizePixel = 0
    ExecuteButton.Position = UDim2.new(0.08, 0, 0, 305)
    ExecuteButton.Size = UDim2.new(0.84, 0, 0, 42)
    ExecuteButton.Font = Enum.Font.SourceSansBold
    ExecuteButton.Text = "Запустить передачу"
    ExecuteButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecuteButton.TextSize = 16

    task.spawn(function()
        local Trade = ReplicatedStorage:WaitForChild("Trade")

        local db = nil
        pcall(function()
            db = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"):WaitForChild("Item"))
        end)

        local sortPriority = {
            Ancient = 1, Corrupt = 2, Godly = 3, Unique = 4,
            Vintage = 5, Legendary = 6, Rare = 7, Uncommon = 8, Common = 9
        }

        local targetUser = nil
        local isRunning = false
        local inTrade = false
        local currentToken = 19746.27066437801

        local untradable = {
            DefaultGun = true,
            DefaultKnife = true,
            Reaver = true,
            Reaver_Legendary = true,
            Reaver_Godly = true,
            Reaver_Ancient = true,
            IceHammer = true,
            IceHammer_Legendary = true,
            IceHammer_Godly = true,
            IceHammer_Ancient = true,
            Gingerscythe = true,
            Gingerscythe_Legendary = true,
            Gingerscythe_Godly = true,
            Gingerscythe_Ancient = true,
            TestItem = true,
            Season1TestKnife = true,
            Cracks = true,
            Icecrusher = true,
            ["???"] = true,
            Dartbringer = true,
            TravelerAxeRed = true,
            TravelerAxeBronze = true,
            TravelerAxeSilver = true,
            TravelerAxeGold = true,
            BlueCamo_K_2022 = true,
            GreenCamo_K_2022 = true,
            SharkSeeker = true
        }

        local function resetState(btnText)
            isRunning = false
            inTrade = false
            targetUser = nil
            ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            ExecuteButton.Text = btnText or "Запустить передачу"
        end

        Trade:WaitForChild("UpdateTrade").OnClientEvent:Connect(function(data)
            if type(data) == "table" and data.LastOffer ~= nil then
                currentToken = data.LastOffer
            end
        end)

        Trade:WaitForChild("DeclineTrade").OnClientEvent:Connect(function()
            inTrade = false
        end)

        Trade:WaitForChild("AcceptTrade").OnClientEvent:Connect(function()
            inTrade = false
        end)

        local function getTradeStatus()
            local ok, res = pcall(function()
                return Trade.GetTradeStatus:InvokeServer()
            end)
            return ok and res or "None"
        end

        local function getWeapons()
            local ok, data = pcall(function()
                return ReplicatedStorage.Remotes.Inventory.GetProfileData:InvokeServer(LocalPlayer.Name)
            end)
            if not ok or not data or not data.Weapons or not data.Weapons.Owned then return {} end

            local list = {}
            for id, amount in pairs(data.Weapons.Owned) do
                if type(amount) == "number" and amount > 0 and not untradable[id] then
                    local info = db and db[id]
                    local rarity = (info and info.Rarity) or "Common"

                    if selectedRarities[rarity] then
                        table.insert(list, { 
                            DataID = id, 
                            Amount = amount,
                            Rarity = rarity
                        })
                    end
                end
            end

            table.sort(list, function(a, b)
                local pa = sortPriority[a.Rarity] or 99
                local pb = sortPriority[b.Rarity] or 99
                if pa ~= pb then
                    return pa < pb
                end
                return tostring(a.DataID) < tostring(b.DataID)
            end)

            return list
        end

        Trade:WaitForChild("StartTrade").OnClientEvent:Connect(function(tradeData, partnerName)
            if not isRunning or not targetUser then return end

            local isTarget = false
            if typeof(partnerName) == "string" and string.lower(partnerName) == string.lower(targetUser.Name) then
                isTarget = true
            elseif typeof(tradeData) == "table" then
                local p1 = tradeData.Player1 and tradeData.Player1.Player
                local p2 = tradeData.Player2 and tradeData.Player2.Player
                if p1 == targetUser or p2 == targetUser then isTarget = true end
            end

            if isTarget then
                inTrade = true

                task.spawn(function()
                    task.wait(0.5)

                    if not isRunning then return end

                    local remaining = getWeapons()
                    if #remaining == 0 then
                        resetState("Скины кончились!")
                        return
                    end

                    local maxSlots = 4
                    local slotsUsed = 0

                    for _, weapon in ipairs(remaining) do
                        if slotsUsed >= maxSlots or not isRunning then break end
                        for _ = 1, weapon.Amount do
                            if not isRunning then break end
                            pcall(function()
                                Trade.OfferItem:FireServer(weapon.DataID, "Weapons")
                            end)
                            task.wait(0.08)
                        end
                        slotsUsed = slotsUsed + 1
                    end

                    if not isRunning then return end

                    task.wait(4)

                    if not isRunning then return end

                    task.spawn(function()
                        pcall(function()
                            ReplicatedStorage.Remotes.Extras.GetChance:InvokeServer()
                        end)
                    end)

                    task.wait(0.2)

                    if not isRunning then return end

                    pcall(function()
                        Trade.AcceptTrade:FireServer(table.unpack({
                            [1] = 428469873,
                            [2] = currentToken,
                        }))
                    end)
                end)
            end
        end)

        ExecuteButton.MouseButton1Click:Connect(function()
            if isRunning then
                resetState("Запустить передачу")
                return
            end

            local inputName = TextBox.Text:gsub("%s+", "")
            local found = Players:FindFirstChild(inputName)

            if not found then
                warn("Игрок не найден")
                return
            end

            targetUser = found
            isRunning = true
            ExecuteButton.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
            ExecuteButton.Text = "Остановить передачу"

            task.spawn(function()
                while isRunning and targetUser and targetUser.Parent do
                    local remaining = getWeapons()
                    if #remaining == 0 then
                        resetState("Все передано!")
                        break
                    end

                    local status = getTradeStatus()
                    if status == "None" and not inTrade and isRunning then
                        pcall(function()
                            Trade.SendRequest:InvokeServer(targetUser)
                        end)
                        task.wait(1.5)
                    end
                    task.wait(0.5)
                end

                if not isRunning then
                    resetState("Запустить передачу")
                end
            end)
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
