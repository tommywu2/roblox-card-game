--1/08/2026

local StatusEffectTemplates = {
    [1] = {
        name = "Burn",
        description = "Burn placeholder description.",

        events = {
			["OnTurnEnd"] = function(self, context)
				context.owner:TakeHit(self:GetStacks())
				game.LogService:Info(`{context.owner:GetName()} took {self:GetStacks()} damage from {self:GetName()}`)

				self:ChangeStacks(-math.floor(self:GetStacks() * (1 / 3)))
            end,
        }
    },
}

return StatusEffectTemplates