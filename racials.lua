local sArena = LibStub("AceAddon-3.0"):GetAddon("sArena")

local Racials = {}
LibStub("AceEvent-3.0"):Embed(Racials)

sArena.options.plugins = sArena.options.plugins or {}
sArena.options.plugins["Racials"] = {
	racials = {
		name = "Racials",
		type = "group",
		desc = "Displays icons to indicate racial abilities sharing a cooldown with PvP Trinket",
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				order = 1,
				get = function() return sArena.db.profile.racials.enabled end,
				set = function(info, val) sArena.db.profile.racials.enabled = val sArena:RefreshConfig() end,
			},
			iconSize = {
				name = "Icon Size",
				type = "range",
				order = 2,
				min = 6,
				max = 102,
				softMin = 12,
				softMax = 48,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.racials.iconSize end,
				set = function(info, val) sArena.db.profile.racials.iconSize = val sArena:RefreshConfig() end,
			},
			fontSize = {
				name = "Font Size",
				desc = "Font size of Blizzard's built-in cooldown count",
				type = "range",
				order = 3,
				min = 4,
				max = 32,
				softMin = 4,
				softMax = 32,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.racials.fontSize end,
				set = function(info, val) sArena.db.profile.racials.fontSize = val sArena:RefreshConfig() end,
			},
		},
	},
}


local UnitRace = UnitRace

sArena.defaults.profile.racials = {
	enabled = true,
	position = { "CENTER", nil, "CENTER", 75, -13 },
	iconSize = 20,
	fontSize = 12,
}

-- List of Medallions
local trinketSpells = {
		[195710] = 180, -- Honorable Medallion
		[208683] = 120, -- Gladiator's Medallion
}

-- List of shared cooldowns - abilities that will trigger a 30 second cooldown on Medallions
local racialSpells = {
		[59752] = {cd=120,icon=136129},	-- Every Man for Himself
		[7744] = {cd=120,icon=136187},	-- Will of the Forsaken
		[20594] = {cd=120,icon=136225},	-- Stoneform
}

local racialIcons = {
		["Human"] = 136129,
		["Scourge"] = 136187,
		["Dwarf"] = 136225,
}
--
function Racials:OnEnable()
	for i = 1, 5 do
		local arenaFrame = _G["ArenaEnemyFrame"..i]

		self["arena"..i] = {}

		local frame = CreateFrame("Frame", nil, arenaFrame, "sArenaRacialTemplate")
		frame:SetAlpha(0)
		frame:EnableMouse(true)

		for _, region in next, { frame.Cooldown:GetRegions() } do
			if region:GetObjectType() == "FontString" then
				frame.Cooldown.Text = region
			end
		end

		frame.Cooldown:SetScript("OnHide", function(self)
			-- don't want to hide when it's enabled and cooldown is off
			if not sArena.db.profile.racials.enabled then
				frame:SetAlpha(0)
			end
		end)

		frame.Cooldown:SetHideCountdownNumbers(false)

		self["arena"..i] = frame
	end
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
sArena.RegisterCallback(Racials, "sArena_OnEnable", "OnEnable")

--
function Racials:RefreshConfig()
	for i = 1, 5 do
		self:UpdatePosition("arena"..i)
		local frame = self["arena"..i]

		sArena:SetupDrag(frame, nil, sArena.db.profile.racials.position, true, true)

		if not sArena.db.profile.racials.enabled then
			CooldownFrame_Set(frame.Cooldown, 0, 0, 0, true)
		end
		frame:SetSize(sArena.db.profile.racials.iconSize, sArena.db.profile.racials.iconSize)
		local fontFace, _, fontFlags = frame.Cooldown.Text:GetFont()
		frame.Cooldown.Text:SetFont(fontFace, sArena.db.profile.racials.fontSize, fontFlags)
	end
end
sArena.RegisterCallback(Racials, "sArena_RefreshConfig", "RefreshConfig")

--
function Racials:TestMode()
	for i = 1, 3 do
		local unitID = "arena"..i
		if sArena.testMode and sArena.db.profile.racials.enabled then
			CooldownFrame_Set(self[unitID].Cooldown, GetTime(), 30, 1, true)
			self[unitID].Icon:SetTexture(136129)
			self[unitID]:SetAlpha(1)
		else
			CooldownFrame_Set(self[unitID].Cooldown, 0, 0, 0, true)
		end
	end
end
sArena.RegisterCallback(Racials, "sArena_TestMode", "TestMode")

--
function Racials:UpdatePosition(id)
	local frame = self[id]
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", frame:GetParent(), "CENTER", sArena.db.profile.racials.position[4], sArena.db.profile.racials.position[5])
end

--
function Racials:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		-- hide racials until they trigger cd once
		for i = 1, 5 do
			self["arena"..i]:SetAlpha(0)
		end
	else
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end

-- Returns remaining time on an active cooldown timer
function Racials:GetRemainingTime(unitID)
	local startTime,duration = self[unitID].Cooldown:GetCooldownTimes()
	if startTime == 0 and duration == 0 then
		return 0
	else
		return duration - ((GetTime() * 1000) - startTime)
	end
end

function Racials:UNIT_SPELLCAST_SUCCEEDED(_, unitID, _, spellID)
	if not sArena.db.profile.racials.enabled then return end
	--
	if not self[unitID] then return end -- if not casted by arenaenemy
	--
	local frame = self[unitID]
	--
	if racialSpells[spellID] then -- If Racial was used
		CooldownFrame_Set(frame.Cooldown, GetTime(), racialSpells[spellID].cd, 1, true)
		frame.Icon:SetTexture(racialSpells[spellID].icon)
		self[unitID]:SetAlpha(1)
	elseif trinketSpells[spellID] then -- If Medallion was used
		local _, raceEN = UnitRace(unitID)
		if racialIcons[raceEN] then
			-- If racial cooldown is inferiod to 30 second, activate cooldown timer for 30 seconds
			if self:GetRemainingTime(unitID) < 30000 then
				CooldownFrame_Set(frame.Cooldown, GetTime(), 30, 1, true)
				frame.Icon:SetTexture(racialIcons[raceEN])
				self[unitID]:SetAlpha(1)
			end
		end
	end
end
