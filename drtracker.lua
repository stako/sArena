local sArena = LibStub("AceAddon-3.0"):GetAddon("sArena")

local DRTracker = {}
LibStub("AceEvent-3.0"):Embed(DRTracker)

sArena.options.plugins = sArena.options.plugins or {}
sArena.options.plugins["DR Tracker"] = {
	drtracker = {
		name = "DR Tracker",
		type = "group",
		desc = "Displays icons to indicate when a type of CC will have diminished effects",
		args = {
			enable = {
				name = "Enable",
				type = "toggle",
				order = 1,
				get = function() return sArena.db.profile.drtracker.enabled end,
				set = function(info, val) sArena.db.profile.drtracker.enabled = val sArena:RefreshConfig() end,
			},
			growRight = {
				name = "Grow Right",
				desc = "DR Icons will grow to the right",
				type = "toggle",
				order = 2,
				get = function() return sArena.db.profile.drtracker.growRight end,
				set = function(info, val) sArena.db.profile.drtracker.growRight = val sArena:RefreshConfig() end,
			},
			iconSize = {
				name = "Icon Size",
				type = "range",
				order = 3,
				min = 6,
				max = 102,
				softMin = 12,
				softMax = 48,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.drtracker.iconSize end,
				set = function(info, val) sArena.db.profile.drtracker.iconSize = val sArena:RefreshConfig() end,
			},
			fontSize = {
				name = "Font Size",
				desc = "Font size of Blizzard's built-in cooldown count",
				type = "range",
				order = 4,
				min = 4,
				max = 32,
				softMin = 4,
				softMax = 32,
				step = 1,
				bigStep = 1,
				get = function() return sArena.db.profile.drtracker.fontSize end,
				set = function(info, val) sArena.db.profile.drtracker.fontSize = val sArena:RefreshConfig() end,
			},
			displayMode = {
				name = "Show DR when CC",
				type = "select",
				order = 5,
				get = function() return sArena.db.profile.drtracker.displayMode end,
				set = function(info, val) sArena.db.profile.drtracker.displayMode = val end,
				values = {
					"Starts",
					"Ends",
				},
			},
		},
	},
}

sArena.defaults.profile.drtracker = {
	enabled = true,
	position = { "CENTER", nil, "CENTER", -70, 20 },
	growRight = false,
	iconSize = 24,
	fontSize = 10,
	displayMode = 1,
}

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetSpellInfo = GetSpellInfo
local UnitDebuff = UnitDebuff
local UnitGUID = UnitGUID

local drTime = 18.5

local categories = {
	"incapacitate",
	"silence",
	"disorient",
	"stun",
	"root",
}

local severityColor = {
	[1] = { 0, 1, 0, 1},
	[2] = { 1, 1, 0, 1},
	[3] = { 1, 0, 0, 1},
}

local drList = {
	[207167]  = "disorient",       -- Blinding Sleet
	[198909]  = "disorient",       -- Song of Chi-ji
	[202274]  = "disorient",       -- Incendiary Brew
	[33786]   = "disorient",       -- Cyclone
	[209753]  = "disorient",       -- Cyclone Honor Talent
	[31661]   = "disorient",       -- Dragon's Breath
	[105421]  = "disorient",       -- Blinding Light
	[8122]    = "disorient",       -- Psychic Scream
	[605]     = "disorient",       -- Mind Control
	[2094]    = "disorient",       -- Blind
	[5782]    = "disorient",       -- Fear
	[118699]  = "disorient",       -- Fear (Incorrect?)
	[130616]  = "disorient",       -- Fear (Incorrect?)
	[5484]    = "disorient",       -- Howl of Terror
	[115268]  = "disorient",       -- Mesmerize
	[6358]    = "disorient",       -- Seduction
	[5246]    = "disorient",       -- Intimidating Shout
	[207685]  = "disorient",       -- Sigil of Misery
	[236748]  = "disorient",       -- Intimidating Roar
	[226943]  = "disorient",       -- Mind Bomb
	[2637]    = "disorient",       -- Hibernate

	[99]      = "incapacitate",    -- Incapacitating Roar
	[203126]  = "incapacitate",    -- Maim (Blood trauma)
	[236025]  = "incapacitate",    -- Enraged Maim
	[3355]    = "incapacitate",    -- Freezing Trap
	[203337]  = "incapacitate",    -- Freezing Trap (Honor Talent)
	[212365]  = "incapacitate",    -- Freezing Trap (Incorrect?)
	[19386]   = "incapacitate",    -- Wyvern Sting
	[209790]  = "incapacitate",    -- Freezing Arrow
	[213691]  = "incapacitate",    -- Scatter Shot
	[118]     = "incapacitate",    -- Polymorph
	[126819]  = "incapacitate",    -- Polymorph (Porcupine)
	[61721]   = "incapacitate",    -- Polymorph (Rabbit)
	[28271]   = "incapacitate",    -- Polymorph (Turtle)
	[28272]   = "incapacitate",    -- Polymorph (Pig)
	[161353]  = "incapacitate",    -- Polymorph (Bear cub)
	[161372]  = "incapacitate",    -- Polymorph (Peacock)
	[61305]   = "incapacitate",    -- Polymorph (Black Cat)
	[61780]   = "incapacitate",    -- Polymorph (Turkey)
	[161355]  = "incapacitate",    -- Polymorph (Penguin)
	[161354]  = "incapacitate",    -- Polymorph (Monkey)
	[277792]  = "incapacitate",    -- Polymorph (Bumblebee)
	[277787]  = "incapacitate",    -- Polymorph (Baby Direhorn)
	[82691]   = "incapacitate",    -- Ring of Frost
	[115078]  = "incapacitate",    -- Paralysis
	[20066]   = "incapacitate",    -- Repentance
	[9484]    = "incapacitate",    -- Shackle Undead
	[200196]  = "incapacitate",    -- Holy Word: Chastise
	[1776]    = "incapacitate",    -- Gouge
	[6770]    = "incapacitate",    -- Sap
	[199743]  = "incapacitate",    -- Parley
	[51514]   = "incapacitate",    -- Hex
	[211004]  = "incapacitate",    -- Hex (Spider)
	[210873]  = "incapacitate",    -- Hex (Raptor)
	[211015]  = "incapacitate",    -- Hex (Cockroach)
	[211010]  = "incapacitate",    -- Hex (Snake)
	[196942]  = "incapacitate",    -- Hex (Voodoo Totem)
	[277784]  = "incapacitate",    -- Hex (Wicker Mongrel)
	[277778]  = "incapacitate",    -- Hex (Zandalari Tendonripper)
	[710]     = "incapacitate",    -- Banish
	[6789]    = "incapacitate",    -- Mortal Coil
	[107079]  = "incapacitate",    -- Quaking Palm
	[217832]  = "incapacitate",    -- Imprison
	[221527]  = "incapacitate",    -- Imprison (Honor Talent)
	[197214]  = "incapacitate",    -- Sundering

	[47476]   = "silence",         -- Strangulate
	[204490]  = "silence",         -- Sigil of Silence
	[78675]   = "silence",         -- Solar Beam
	[202933]  = "silence",         -- Spider Sting
	[233022]  = "silence",         -- Spider Sting 2
	[217824]  = "silence",         -- Shield of Virtue
	[199683]  = "silence",         -- Last Word
	[15487]   = "silence",         -- Silence
	[1330]    = "silence",         -- Garrote
	[43523]   = "silence",         -- Unstable Affliction Silence Effect
	[196364]  = "silence",         -- Unstable Affliction Silence Effect 2

	[210141]  = "stun",            -- Zombie Explosion
	[108194]  = "stun",            -- Asphyxiate (unholy)
	[221562]  = "stun",            -- Asphyxiate (blood)
	[91800]   = "stun",            -- Gnaw
	[212332]  = "stun",            -- Smash
	[91797]   = "stun",            -- Monstrous Blow
	[22570]   = "stun",            -- Maim (invalid?)
	[203123]  = "stun",            -- Maim
	[163505]  = "stun",            -- Rake (Prowl)
	[5211]    = "stun",            -- Mighty Bash
	[19577]   = "stun",            -- Intimidation (no longer used?)
	[24394]   = "stun",            -- Intimidation
	[119381]  = "stun",            -- Leg Sweep
	[853]     = "stun",            -- Hammer of Justice
	[1833]    = "stun",            -- Cheap Shot
	[408]     = "stun",            -- Kidney Shot
	[199804]  = "stun",            -- Between the Eyes
	[118905]  = "stun",            -- Static Charge (Capacitor Totem)
	[118345]  = "stun",            -- Pulverize
	[89766]   = "stun",            -- Axe Toss
	[171017]  = "stun",            -- Meteor Strike (Infernal)
	[171018]  = "stun",            -- Meteor Strike (Abyssal)
--	[22703]   = "stun",            -- Infernal Awakening (doesn't seem to DR)
	[30283]   = "stun",            -- Shadowfury
	[46968]   = "stun",            -- Shockwave
	[132168]  = "stun",            -- Shockwave (Protection)
	[145047]  = "stun",            -- Shockwave (Proving Grounds PvE)
	[132169]  = "stun",            -- Storm Bolt
	[64044]   = "stun",            -- Psychic Horror
	[200200]  = "stun",            -- Holy Word: Chastise Censure
--  [204399]  = "stun",            -- Earthfury (doesn't seem to DR)
	[179057]  = "stun",            -- Chaos Nova
	[205630]  = "stun",            -- Illidan's Grasp, primary effect
	[208618]  = "stun",            -- Illidan's Grasp, secondary effect
	[211881]  = "stun",            -- Fel Eruption
	[20549]   = "stun",            -- War Stomp
	[199085]  = "stun",            -- Warpath
	[204437]  = "stun",            -- Lightning Lasso
	[255723]  = "stun",            -- Bull Rush
	[202244]  = "stun",            -- Overrun
--  [213688]  = "stun",            -- Fel Cleave (doesn't seem to DR)
	[202346]  = "stun",            -- Double Barrel

	[204085]  = "root",            -- Deathchill
	[233395]  = "root",            -- Frozen Center
	[339]     = "root",            -- Entangling Roots
	[170855]  = "root",            -- Entangling Roots (Nature's Grasp)
	[201589]  = "root",            -- Entangling Roots (Tree of Life)
	[235963]  = "root",            -- Entangling Roots (Feral honor talent)
--  [45334]   = "root",            -- Immobilized (Wild Charge) FIXME: only DRs with itself
	[102359]  = "root",            -- Mass Entanglement
	[162480]  = "root",            -- Steel Trap
--	[190927]  = "root",            -- Harpoon FIXME: only DRs with itself
	[200108]  = "root",            -- Ranger's Net
	[212638]  = "root",            -- Tracker's net
	[201158]  = "root",            -- Super Sticky Tar
	[136634]  = "root",            -- Narrow Escape
	[122]     = "root",            -- Frost Nova
	[33395]   = "root",            -- Freeze
	[198121]  = "root",            -- Frostbite
	[220107]  = "root",            -- Frostbite (Water Elemental? needs testing)
	[116706]  = "root",            -- Disable
	[64695]   = "root",            -- Earthgrab (Totem effect)
	[233582]  = "root",            -- Entrenched in Flame
	[117526]  = "root",            -- Binding Shot
	[207171]  = "root",            -- Winter is Coming

	--[[
	[207777]  = "disarm",          -- Dismantle
	[233759]  = "disarm",          -- Grapple Weapon
	[236077]  = "disarm",          -- Disarm
	[236236]  = "disarm",          -- Disarm (Prot)
	[209749]  = "disarm",          -- Faerie Swarm (Balance)
	]]
}

function DRTracker:OnEnable()
	for i = 1, 5 do
		local arenaFrame = _G["ArenaEnemyFrame"..i]

		self["arena"..i] = {}

		for c = 1, #categories do
			local frame = CreateFrame("Frame", nil, arenaFrame, "sArenaDRTrackerTemplate")
			frame:SetAlpha(0)
			if c == 1 then frame:EnableMouse(true) end

			for _, region in next, { frame.Cooldown:GetRegions() } do
				if region:GetObjectType() == "FontString" then
					frame.Cooldown.Text = region
				end
			end

			frame.Cooldown:SetScript("OnShow", function(self)
				frame:SetAlpha(1)
				DRTracker:UpdatePosition("arena"..i)
			end)

			frame.Cooldown:SetScript("OnHide", function(self)
				frame:SetAlpha(0)
				DRTracker:UpdatePosition("arena"..i)
				frame.severity = 1
			end)

			frame.Cooldown:SetHideCountdownNumbers(false)

			self["arena"..i][categories[c]] = frame
		end
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
sArena.RegisterCallback(DRTracker, "sArena_OnEnable", "OnEnable")

function DRTracker:RefreshConfig()
	for i = 1, 5 do
		self:UpdatePosition("arena"..i)
		for c = 1, #categories do
			local frame = self["arena"..i][categories[c]]

			if c == 1 then
				sArena:SetupDrag(frame, nil, sArena.db.profile.drtracker.position, true, true)
			end

			if not sArena.db.profile.drtracker.enabled then
				CooldownFrame_Set(frame.Cooldown, 0, 0, 0, true)
			end
			frame:SetSize(sArena.db.profile.drtracker.iconSize, sArena.db.profile.drtracker.iconSize)
			frame.severity = 1
			local fontFace, _, fontFlags = frame.Cooldown.Text:GetFont()
			frame.Cooldown.Text:SetFont(fontFace, sArena.db.profile.drtracker.fontSize, fontFlags)
		end
	end
end
sArena.RegisterCallback(DRTracker, "sArena_RefreshConfig", "RefreshConfig")

function DRTracker:TestMode()
	for i = 1, 3 do
		local unitID = "arena"..i
		for c = 1, #categories do
			local v = categories[c]
			if sArena.testMode and sArena.db.profile.drtracker.enabled then
				CooldownFrame_Set(self[unitID][v].Cooldown, GetTime(), drTime, 1, true)
				self[unitID][v].Icon:SetTexture(136071)
				if c == 1 then
					self[unitID][v].Border:SetVertexColor(1, 0.25, 0, 1)
				else
					self[unitID][v].Border:SetVertexColor(1, 1, 1, 1)
				end
			else
				CooldownFrame_Set(self[unitID][v].Cooldown, 0, 0, 0, true)
			end
		end
	end
end
sArena.RegisterCallback(DRTracker, "sArena_TestMode", "TestMode")

function DRTracker:UpdatePosition(id)
	local active = 0

	for i = 1, #categories do
		local frame = self[id][categories[i]]
		if frame:GetAlpha() == 1 then
			frame:ClearAllPoints()
			if active == 0 then
				frame:SetPoint("CENTER", frame:GetParent(), "CENTER", sArena.db.profile.drtracker.position[4], sArena.db.profile.drtracker.position[5])
			else
				frame:SetPoint("CENTER", frame:GetParent(), "CENTER", sArena.db.profile.drtracker.position[4] + (active * (sArena.db.profile.drtracker.growRight and sArena.db.profile.drtracker.iconSize or -sArena.db.profile.drtracker.iconSize)), sArena.db.profile.drtracker.position[5])
			end
			active = active + 1
		end
	end
end

function DRTracker:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	else
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function DRTracker:COMBAT_LOG_EVENT_UNFILTERED()
	if not sArena.db.profile.drtracker.enabled then return end

	local _, eventType, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, auraType = CombatLogGetCurrentEventInfo()
	if auraType == "DEBUFF" then
		if eventType == "SPELL_AURA_REMOVED" or eventType == "SPELL_AURA_BROKEN" then
			self:ApplyDR(destGUID, spellID, false)
		elseif eventType == "SPELL_AURA_APPLIED" then
			self:ApplyDR(destGUID, spellID, true)
		end
	end
end

function DRTracker:ApplyDR(GUID, spellID, applied)
	local category = drList[spellID]
	if not category then return end

	local unitID
	for i = 1, 5 do
		if UnitGUID("arena"..i) == GUID then
			unitID = "arena"..i
			break
		end
	end

	if not unitID then return end

	local frame = self[unitID][category]
	if not frame then
		sArena:Print("Unknown DR Category \""..category.."\" for Spell ID " .. spellID)
		return
	end

	if sArena.db.profile.drtracker.displayMode == 1 then
		if applied then -- CC has been applied
			for i = 1, 16 do -- DEBUFF_MAX_DISPLAY
				local _, _, _, _, _, expirationTime, _, _, _, _spellID = UnitDebuff("target", i)
				if expirationTime and spellID == _spellID then
					CooldownFrame_Set(frame.Cooldown, GetTime(), drTime + expirationTime, 1, true)
					break
				end
			end
		else -- CC has been removed (completed, dispelled, broken, etc.)
			-- Adjust timer for early CC breaks
			local startTime, startDuration = frame.Cooldown:GetCooldownTimes()
			startTime, startDuration = startTime/1000, startDuration/1000

			local newDuration = drTime / (1 - ((GetTime() - startTime) / startDuration))
			local newStartTime = drTime + GetTime() - newDuration
			CooldownFrame_Set(frame.Cooldown, newStartTime, newDuration, 1, true)
			return
		end
	else
		if applied then return else
			CooldownFrame_Set(frame.Cooldown, GetTime(), drTime, 1, true)
		end
	end

	local _, _, icon = GetSpellInfo(spellID)
	frame.Icon:SetTexture(icon)

	frame.Border:SetVertexColor(unpack(severityColor[frame.severity]))

	frame.severity = frame.severity + 1
	if frame.severity > 3 then
		frame.severity = 3
	end
end
