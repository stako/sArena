sArena.Trinkets = {}

function sArena:CreateTrinketIcon(frame)
	local id = frame:GetID()
	self.Trinkets["arena"..id] = CreateFrame("Cooldown", nil, self.Frame)
	
end