local Signal = require(script.Parent.Dependency.Signal)

local SignalManager = {
	["OnTurnEnd"] = Signal(),
	
	onCombatStart = Signal(),
	onCombatEnd = Signal(),
	
	onTurnStart = Signal(),
	onTurnEnd = Signal(),
	
	onHit = Signal(),
	onDamage = Signal(),
	onHeal = Signal(),
	
	beforeSpeedDiceRoll = Signal(),
	onSpeedDiceRoll = Signal(),
	afterSpeedDiceRoll = Signal(),
	
	beforeDiceRoll = Signal(),
	onDiceRoll = Signal(),
	afterDiceRoll = Signal(),
	
	onStatusEffectAdded = Signal(),
	onStatusEffectRemoved = Signal(),
	onStatusEffectChanged = Signal(),
	
	onCardPlayed = Signal(),
	onCardDrawn = Signal(),
	onCardDiscarded = Signal(),
	onCardAdded = Signal(),
	onCardRemoved = Signal(),
	onCardBanished = Signal(),
	onCardUnbanished = Signal(),
	
	onClashStart = Signal(),
	onClashWin = Signal(),
	onClashLoss = Signal(),
	onClashDraw = Signal(),
	
	onDeath = Signal(),
}

return SignalManager