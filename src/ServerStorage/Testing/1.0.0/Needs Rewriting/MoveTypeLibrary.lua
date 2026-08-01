--Services
local ServerScriptService = game:GetService("ServerScriptService")

local MoveTypeLibrary = {}

local blueprints = {
	["Slash"] = {
		name = "Slash",
		category = "Offensive",
		
		OnWin = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then
				print("ERROR: Drawn against a move that does nothing. Forced to do nothing.")
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Slash" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Pierce" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Blunt" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(ownerMove:GetFinalDamage() - opponentMove:GetFinalBlock())
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			end
			
			ownerMove:Complete()
		end,
		OnLose = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then
				
			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
		OnDraw = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
	},
	["Pierce"] = {
		name = "Pierce",
		category = "Offensive",

		OnWin = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Slash" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Pierce" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Blunt" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(ownerMove:GetFinalDamage() - opponentMove:GetFinalBlock())
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			end
			
			ownerMove:Complete()
		end,
		OnLose = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
		OnDraw = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
	},
	["Blunt"] = {
		name = "Blunt",
		category = "Offensive",

		OnWin = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Slash" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Pierce" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Blunt" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(ownerMove:GetFinalDamage() - opponentMove:GetFinalBlock())
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(ownerMove:GetFinalDamage())
			end
			
			ownerMove:Complete()
		end,
		OnLose = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
		OnDraw = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Block" then
				opponent:TakeHit(0)
			elseif opponentMove:GetVariantName() == "Evade" then
				opponent:TakeHit(0)
			end
			
			ownerMove:Complete()
		end,
	},
	["Block"] = {
		name = "Block",
		category = "Defensive",

		OnWin = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then

			elseif opponentMove:GetVariantName() == "Pierce" then

			elseif opponentMove:GetVariantName() == "Blunt" then

			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
		OnLose = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then

			elseif opponentMove:GetVariantName() == "Pierce" then

			elseif opponentMove:GetVariantName() == "Blunt" then

			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
		OnDraw = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then

			elseif opponentMove:GetVariantName() == "Pierce" then

			elseif opponentMove:GetVariantName() == "Blunt" then

			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
	},
	["Evade"] = {
		name = "Evade",
		category = "Defensive",
		
		OnWin = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then
				--TODO: Recycle the dice.
			elseif opponentMove:GetVariantName() == "Pierce" then
				--TODO: Recycle the dice.
			elseif opponentMove:GetVariantName() == "Blunt" then
				--TODO: Recycle the dice.
			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
		OnLose = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then

			elseif opponentMove:GetVariantName() == "Pierce" then

			elseif opponentMove:GetVariantName() == "Blunt" then

			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
		OnDraw = function(owner, ownerMove, opponent, opponentMove)
			if not opponentMove then

			elseif opponentMove:GetVariantName() == "Slash" then

			elseif opponentMove:GetVariantName() == "Pierce" then

			elseif opponentMove:GetVariantName() == "Blunt" then

			elseif opponentMove:GetVariantName() == "Block" then

			elseif opponentMove:GetVariantName() == "Evade" then

			end
			
			ownerMove:Complete()
		end,
	}
}

function MoveTypeLibrary.Get(variant)
	return blueprints[variant]
end

return MoveTypeLibrary