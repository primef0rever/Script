local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создание GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExecutorKillFeed"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0, 260, 0, 200)
container.Position = UDim2.new(1, -20, 1, -180)
container.AnchorPoint = Vector2.new(1, 1)
container.BackgroundTransparency = 1
container.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = container

-- Функция добавления записи
local function addEntry(killerName, victimName, weaponName)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 30)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = container

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, 0)
	label.Position = UDim2.new(0, 5, 0, 0)
	label.BackgroundTransparency = 1
	label.TextSize = 13
	label.Font = Enum.Font.SourceSansBold
	label.TextXAlignment = Enum.TextXAlignment.Right
	label.RichText = true

	local wText = (weaponName and weaponName ~= "") and (" [" .. weaponName .. "] ") or " [Kill] "
	label.Text = string.format('<font color="rgb(255,60,60)">%s</font>%s<font color="rgb(60,160,255)">%s</font>', killerName, wText, victimName)
	label.Parent = frame

	frame.Size = UDim2.new(1, 0, 0, 0)
	frame.BackgroundTransparency = 1
	label.TextTransparency = 1

	local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.3}):Play()
	TweenService:Create(label, tweenInfo, {TextTransparency = 0}):Play()

	task.delay(5, function()
		local fadeOut = TweenService:Create(frame, tweenInfo, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
		TweenService:Create(label, tweenInfo, {TextTransparency = 1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Connect(function() frame:Destroy() end)
	end)
end

-- Отслеживание смертей через клиент
local function trackPlayer(p)
	local function onChar(char)
		local hum = char:WaitForChild("Humanoid", 10)
		if not hum then return end

		hum.Died:Connect(function()
			-- Проверяем наличие стандартной метки creator в Humanoid
			local creator = hum:FindFirstChild("creator")
			local killerName = "Неизвестно"
			local weaponName = nil

			if creator and creator.Value then
				killerName = creator.Value.Name
			else
				-- Если метки нет, ищем кто находился ближе всего с оружием в руках
				local minDistance = 20
				for _, otherPlayer in ipairs(Players:GetPlayers()) do
					if otherPlayer ~= p and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
						local dist = (otherPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
						if dist < minDistance then
							minDistance = dist
							killerName = otherPlayer.Name
							local tool = otherPlayer.Character:FindFirstChildOfClass("Tool")
							if tool then weaponName = tool.Name end
						end
					end
				end
			end

			addEntry(killerName, p.Name, weaponName)
		end)
	end

	if p.Character then onChar(p.Character) end
	p.CharacterAdded:Connect(onChar)
end

for _, p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
