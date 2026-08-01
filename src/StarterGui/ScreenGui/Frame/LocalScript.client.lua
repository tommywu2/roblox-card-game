--Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--Remotes
local GetHand = ReplicatedStorage:WaitForChild("GetHand")
local GetSpeedDice = ReplicatedStorage:WaitForChild("GetSpeedDice")




local selectedCard = nil
local selectedButton = nil
local function SelectCard(card, button)
	selectedCard = card
	selectedButton = button
	print(card.name .. " selected.")
	
	button.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end

local hand = GetHand:InvokeServer()
print("Got hand.")
print(hand)
for i, card in ipairs(hand) do
	local button = Instance.new("TextButton")
	button.Text = card.name
	button.Parent = script.Parent
	button.Name = card.name
	button.Position = UDim2.new(0, 100, 0, 100 * i)
	button.Size = UDim2.new(0, 100, 0, 100)
	
	button.MouseButton1Click:Connect(function()
		print("Clicked")
		SelectCard(card, button)
	end)
end

local speedDice = GetSpeedDice:InvokeServer()
for i, die in ipairs(speedDice) do
	local button = Instance.new("TextButton")
	button.Text = "Speed Die " .. i
	button.Parent = script.Parent
	button.Name = die
	button.Position = UDim2.new(0, 300, 0, 100 * i)
	button.Size = UDim2.new(0, 100, 0, 100)

	button.MouseButton1Click:Connect(function()
		print("Clicked")
		
	end)
end



local readyButton = Instance.new("TextButton")
readyButton.Text = "Ready"
readyButton.Parent = script.Parent
readyButton.Name = "ReadyButton"
readyButton.Position = UDim2.new(0, 500, 0, 100)
readyButton.Size = UDim2.new(0, 100, 0, 100)
readyButton.MouseButton1Click:Connect(function()
	print("Ready clicked.")
	if selectedCard then
		print("Sending " .. selectedCard.name .. " to server.")
		
		selectedButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		selectedButton = nil
		selectedCard = nil
	end
end)