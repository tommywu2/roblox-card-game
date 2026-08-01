local StatusEffectBlueprints = {
	[1] = {
		name = "Burn",
		description = "Placeholder description",

		events = {
			["OnTurnEnd"] = {
				function(self, context)
					context.owner:TakeHit(self:GetStacks())
					game.LogService:Info(`{context.owner:GetName()} took {self:GetStacks()} damage from {self:GetName()}`)

					self:ChangeStacks(-math.floor(self:GetStacks() * (1 / 3)))
				end,
			}
		}
	},
}

return StatusEffectBlueprints
