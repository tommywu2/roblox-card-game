--27/07/2026

local CardTemplates = {
	[1] = {
		name = "Test Attack",
		cost = 1,
		rarity = "Common",
		moves = {
			{
				type = "Slash",
				min = 5,
				max = 5,

				effects = {
					{
						event = "OnRoll",
						effect = function(owner, ownerMove, opponent, opponentMove)
							print("Triggered Attack effect.")
							ownerMove:SetValue(7)
							opponent:AddStatusEffect(1, 1)
							print("Applied 1 burn to " .. opponent:GetName() .. ".")
						end,
					}
				}
			},
		},
	},
	[2] = {
		name = "Test Block",
		cost = 1,
		rarity = "Common",
		moves = {
			{
				type = "Block",
				min = 6,
				max = 6,

				effects = {
					{
						event = "OnRoll",
						effect = function(owner, ownerMove, opponent, opponentMove)
							print("Triggered Block effect.")
						end,
					}
				}
			},
		},
	},
	[1000] = {
		name = "Bite Off",
		cost = 1,
		rarity = "Common",
		moves = {
			{type = "Slash", min = 1, max = 4},
			{type = "Blunt", min = 1, max = 4},
		},
	},
	[1001] = {
		name = "Backstreets Dash",
		cost = 1,
		rarity = "Common",
		moves = {
			{type = "Pierce", min = 1, max = 8},
		},
	},
}

return CardTemplates