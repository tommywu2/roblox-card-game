--21/07/2026

local EventBlueprints = {
	[1000] = {
		title = "test1",
		description = "test description dialog here.",
		options = {
			[1] = {
				text = "option 1",
				OnSelection = function()
					print("option 1 selected")			
				end,
				outcome = {
					variant = "Combat",
					data = {}
				}
			},
		}
	},
	[2000] = {
		title = "test",
		description = "test description dialog here.",
		options = {
			[1] = {
				text = "option 1",
				OnSelection = function()
					print("option 1 selected")			
				end,
				outcome = {
					variant = "Combat",
					data = {}
				}
			},
			[2] = {
				text = "option 2",
				OnSelection = function()
					print("option 2 selected")
				end,
				outcome = {
					variant = "Combat",
					data = {}
				}
			},
			[3] = {
				text = "placeholder text: attack the shopkeeper",
				OnSelection = function()
					print("option 3 selected")

					--TELL SERVER TO START COMBAT WITH DEFINED ENEMIES USING ENCOUNTER ID
				end,
				outcome = {
					variant = "Combat",
					data = {}
				}
			},
			[4] = {
				text = "placeholder text: purchase from the shop",
				OnSelection = function()
					print("option 4 selected")
				end,
				outcome = {
					variant = "Shop",
					data = {}
				}
			},
		}
	}
}

return EventBlueprints