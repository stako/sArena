--[[
ToDo List:

Fix interface taint that is caused by manipulating UVars
Add functionality to allow arena frames to grow in different directions
Add LibSharedMedia to customize fonts & statusbars
Pet Frames - movable, mirrored, simple
Fix status text display in test mode
MoveAnything compatability?
]]

local sArena = LibStub("AceAddon-3.0"):NewAddon("sArena", "AceConsole-3.0", "AceHook-3.0", "AceEvent-3.0")
sArena.events = sArena.events or LibStub("CallbackHandler-1.0"):New(sArena)

sArena.testMode = false

sArena.options = {
	name = "sArena",
	handler = sArena,
	type = "group",
	args = {
		test = {
			name = "Test Mode",
			type = "execute",
			func = function() sArena:TestMode(not sArena.testMode) end,
			order = 1,
		},
		general = {
			name = "General",
			type = "group",
			order = 0,
			args = {
				scale = {
					name = "Scale",
					type = "range",
					order = 1,
					min = 0.1,
					max = 5.0,
					softMin = 0.5,
					softMax = 3.0,
					step = 0.01,
					bigStep = 0.1,
					get = function() return sArena.db.profile.scale end,
					set = function(info, val) if sArena:Combat() then return end sArena.db.profile.scale = val sArena.ArenaEnemyFrames:SetScale(val) end,
				},
				specScale = {
					name = "Spec Icon Scale",
					type = "range",
					order = 2,
					min = 0.1,
					max = 5.0,
					softMin = 0.5,
					softMax = 3.0,
					step = 0.01,
					bigStep = 0.1,
					get = function() return sArena.db.profile.specScale end,
					set = function(info, val) if sArena:Combat() then return end sArena.db.profile.specScale = val sArena:RefreshConfig() end,
				},
				trinketSize = {
					name = "Trinket Icon Size",
					type = "range",
					order = 3,
					min = 4,
					max = 100,
					softMin = 6,
					softMax = 60,
					step = 1,
					bigStep = 1,
					get = function() return sArena.db.profile.trinketSize end,
					set = function(info, val) if sArena:Combat() then return end sArena.db.profile.trinketSize = val sArena:RefreshConfig() end,
				},
				castBarScale = {
					name = "Cast Bar Scale",
					type = "range",
					order = 3,
					min = 0.1,
					max = 5.0,
					softMin = 0.5,
					softMax = 3.0,
					step = 0.01,
					bigStep = 0.1,
					get = function() return sArena.db.profile.castBarScale end,
					set = function(info, val) if sArena:Combat() then return end sArena.db.profile.castBarScale = val sArena:RefreshConfig() end,
				},
				trinketFontSize = {
					name = "Trinket Font Size",
					desc = "Font size of Blizzard's built-in cooldown count",
					type = "range",
					order = 4,
					min = 4,
					max = 32,
					softMin = 4,
					softMax = 32,
					step = 1,
					bigStep = 1,
					get = function() return sArena.db.profile.trinketFontSize end,
					set = function(info, val) sArena.db.profile.trinketFontSize = val sArena:RefreshConfig() end,
				},
				statusTextFontSize = {
					name = "Health/Mana Font Size",
					desc = "Font size of text for health & mana bars",
					type = "range",
					order = 5,
					min = 4,
					max = 32,
					softMin = 4,
					softMax = 32,
					step = 1,
					bigStep = 1,
					get = function() return sArena.db.profile.statusTextFontSize end,
					set = function(info, val) sArena.db.profile.statusTextFontSize = val sArena:RefreshConfig() end,
				},
				simpleFrames = {
					name = "Simple arena frames",
					desc = "Removes the unitframe texture and makes icons square-shaped",
					type = "toggle",
					order = 6,
					width = "double",
					get = function() return sArena.db.profile.simpleFrames end,
					set = function(info, val) sArena.db.profile.simpleFrames = val sArena:RefreshConfig() end,
				},
				mirroredFrames = {
					name = "Mirrored arena frames",
					type = "toggle",
					order = 7,
					width = "double",
					get = function() return sArena.db.profile.mirroredFrames end,
					set = function(info, val) sArena.db.profile.mirroredFrames = val sArena:RefreshConfig() end,
				},
				classColours = {
					name = "Class-coloured health bars",
					type = "toggle",
					order = 8,
					width = "double",
					get = function() return sArena.db.profile.classColours end,
					set = function(info, val) sArena.db.profile.classColours = val sArena:RefreshConfig() end,
				},
				hideNames = {
					name = "Hide player names",
					type = "toggle",
					order = 9,
					width = "double",
					get = function() return sArena.db.profile.hideNames end,
					set = function(info, val) sArena.db.profile.hideNames = val sArena:RefreshConfig() end,
				},
				statusText = {
					name = "Health/mana text",
					desc = "Must have party text enabled in Blizz options for this to work",
					type = "toggle",
					order = 10,
					width = "double",
					get = function() return sArena.db.profile.statusText end,
					set = function(info, val) sArena.db.profile.statusText = val sArena:RefreshConfig() end,
				},
				legacyOptions = {
					name = "Legacy Options",
					type = "group",
					order = 11,
					inline = true,
					args = {
						description = {
							name = "Blizzard options that were removed in the past. |nAlways character-specific. |n|TInterface\\Icons\\ability_creature_cursed_01:16|t |cFFFF0000WARNING: UI should be reloaded after changing these options|r|n ",
							type = "description",
							order = 1,
						},
						showPets = {
							name = "Show Pets",
							type = "toggle",
							order = 2,
							width = "half",
							get = function() return (SHOW_ARENA_ENEMY_PETS == "1") end,
							set = function(info, val) if sArena:Combat() then return end SHOW_ARENA_ENEMY_PETS = val and "1" or "0" SetCVar("showArenaEnemyPets", val) sArena:RefreshConfig() end,
						},
						showBackground = {
							name = "Show Background",
							type = "toggle",
							order = 3,
							get = function() return (SHOW_PARTY_BACKGROUND == "1") end,
							set = function(info, val) if sArena:Combat() then return end SHOW_PARTY_BACKGROUND = val and "1" or "0" SetCVar("showPartyBackground", val) sArena:RefreshConfig() end,
						},
						reload = {
							name = "Reload UI",
							type = "execute",
							func = ReloadUI,
							order = 4,
						},
					},
				},
			},
		},
		help = {
			name = "|cFFFF4400Help|r",
			type = "group",
			order = -1,
			args = {
				howToMoveHeader = {
					name = "How do I move stuff?",
					type = "header",
					order = 1,
				},
				howToMoveDesc = {
					name = "Ctrl + Shift + Click",
					type = "description",
					order = 2,
				},
				whatToMoveHeader = {
					name = "What can I move?",
					type = "header",
					order = 3,
				},
				whatToMoveDesc = {
					name = " - Arena frame|n - Spec icon|n - Trinket|n - Cast bar|n - DR Tracker (The |cFFFF4400orange|r one)",
					type = "description",
					order = 4,
				},
			},
		},
	},
}

-- Default Saved Variables
sArena.defaults = {
	profile = {
		position = { "TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -100, -25 },
		specPosition = { "CENTER", nil, "CENTER", 43, -12 },
		trinketPosition = { "RIGHT", nil, "LEFT", -12, -3 },
		castBarPosition = { "RIGHT", nil, "LEFT", -32, -3 },
		statusTextFontSize = 8,
		trinketFontSize = 10,
		trinketSize = 18,
		scale = 1.0,
		specScale = 1.0,
		castBarScale = 1.0,
		classColours = true,
		hideNames = false,
		mirroredFrames = false,
		simpleFrames = false,
		statusText = true,
	},
}

local healthBars = {
	ArenaEnemyFrame1HealthBar = 1,
	ArenaEnemyFrame2HealthBar = 1,
	ArenaEnemyFrame3HealthBar = 1,
	ArenaEnemyFrame4HealthBar = 1,
	ArenaEnemyFrame5HealthBar = 1
}

local classIcons = {
	["DRUID"] = 625999,
	["HUNTER"] = 626000,
	["MAGE"] = 626001,
	["MONK"] = 626002,
	["PALADIN"] = 626003,
	["PRIEST"] = 626004,
	["ROGUE"] = 626005,
	["SHAMAN"] = 626006,
	["WARLOCK"] = 626007,
	["WARRIOR"] = 626008,
	["DEATHKNIGHT"] = 135771,
	["DEMONHUNTER"] = 1260827,
}

local testModeClasses = { "ROGUE", "MAGE", "PRIEST" }
local specIcons = { 132320, 135846, 135940 }

local textTable = {
	"healthtext",
	"healthtextleft",
	"healthtextright",
	"manatext",
	"manatextleft",
	"manatextright",
}

function sArena:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("sArenaDB", sArena.defaults, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self.options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("sArena", sArena.options)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("sArena")
	self:RegisterChatCommand("sarena", "ChatCommand")
end

function sArena:OnEnable()
	SetCVar("showArenaEnemyCastbar", true)

	-- ArenaEnemyFrames gets repositioned all time, so we'll just make our own & anchor everything to it
	self.ArenaEnemyFrames = CreateFrame("Frame", nil, UIParent)
	self.ArenaEnemyFrames:SetMovable(true)
	self.ArenaEnemyFrames:SetClampedToScreen(true)
	self.ArenaEnemyFrames:SetSize(130, 50)

	ArenaEnemyBackground:SetParent(sArena.ArenaEnemyFrames)
	ArenaPrepBackground:SetParent(sArena.ArenaEnemyFrames)

	-- Loop through all of the arena frames
	for i = 1, 5 do
		-- Make a 'for loop' to modify both ArenaEnemyFramex and ArenaPrepFramex
		for k, v in pairs({"ArenaEnemyFrame"..i, "ArenaPrepFrame"..i}) do
			local frame = _G[v]

			frame:SetParent(sArena.ArenaEnemyFrames)

			if k == 1 then
				-- Stuff that only needs to be done to arena frames (but not prep frames)

				local cc = frame["CC"]

				-- Make trinket icons movable
				cc:SetMovable(true)
				cc:SetClampedToScreen(true)
				cc:EnableMouse(true)

				-- Find fontstring for trinket cooldown count
				for _, region in next, { cc.Cooldown:GetRegions() } do
					if region:GetObjectType() == "FontString" then
						cc.Cooldown.Text = region
					end
				end

				-- Create mock castbars for test mode
				frame.castFrame = CreateFrame("StatusBar", nil, frame, "sArenaCastBarTemplate")
				frame.castFrame:SetAllPoints(frame.castBar)
				frame.castFrame.Icon:SetAllPoints(frame.castBar.Icon)
				frame.castFrame:EnableMouse(true)

				frame.castBar:SetMovable(true)
				frame.castBar:SetClampedToScreen(true)
			else
				-- Stuff that only needs to be done to prep frames (but not arena frames)
				frame.name = _G[v.."Name"]
				frame.healthbar = _G[v.."HealthBar"]
				frame.manabar = _G[v.."ManaBar"]
				frame.specPortrait = _G[v.."SpecPortrait"]
				frame.specBorder = _G[v.."SpecBorder"]
			end

			frame.texture = _G[v.."Texture"]
			frame.background = _G[v.."Background"]
			frame.healthtext = _G[v.."HealthBarText"]
			frame.healthtextleft = _G[v.."HealthBarTextLeft"]
			frame.healthtextright = _G[v.."HealthBarTextRight"]
			frame.manatext = _G[v.."ManaBarText"]
			frame.manatextleft = _G[v.."ManaBarTextLeft"]
			frame.manatextright = _G[v.."ManaBarTextRight"]

			frame.background:SetPoint("TOPLEFT", frame.healthbar, "TOPLEFT", 0, 0)
			frame.background:SetPoint("BOTTOMRIGHT", frame.manabar, "BOTTOMRIGHT", 0, 0)

			frame.specFrame = CreateFrame("Frame", nil, frame, "sArenaSpecIconTemplate")
			frame.specFrame:SetMovable(true)
			frame.specFrame:SetClampedToScreen(true)
			frame.specFrame:EnableMouse(true)

			frame.specPortrait:ClearAllPoints()
			frame.specPortrait:SetPoint("CENTER", frame.specFrame, "CENTER", 0, 0)
			frame.specPortrait:SetParent(frame.specFrame)

			frame.specBorder:ClearAllPoints()
			frame.specBorder:SetPoint("CENTER", frame.specFrame, "CENTER", 12, -12)
			frame.specBorder:SetParent(frame.specFrame)

		end

		_G["ArenaEnemyFrame"..i.."PetFrame"]:SetParent(sArena.ArenaEnemyFrames)
	end

	self:SecureHook("PartyMemberBackground_SetOpacity")
	self:SecureHook("HealthBar_OnValueChanged", "ClassColours")
	self:SecureHook("UnitFrameHealthBar_Update", "ClassColours")
	self:SecureHook("ArenaEnemyFrame_SetMysteryPlayer")
	self:SecureHook("ArenaEnemyFrame_UpdatePlayer")
	self:SecureHook("ArenaPrepFrames_UpdateFrames")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.events:Fire("sArena_OnEnable")

	self:RefreshConfig()
end

-- We want to call this function when most settings are changed
function sArena:RefreshConfig()
	if self:Combat() then return end

	self.ArenaEnemyFrames:ClearAllPoints()
	self.ArenaEnemyFrames:SetPoint(unpack(self.db.profile.position))
	self.ArenaEnemyFrames:SetScale(self.db.profile.scale)

	local _, instanceType = IsInInstance()

	local font, _, flags = ArenaEnemyFrame1.healthtext:GetFont()

	-- Loop through all of the arena frames
	for i = 1, 5 do
		-- Make a 'for loop' to modify both ArenaEnemyFramex and ArenaPrepFramex
		for k, v in pairs({"ArenaEnemyFrame"..i, "ArenaPrepFrame"..i}) do
			local frame = _G[v]

			frame.specFrame:SetScale(self.db.profile.specScale)
			frame.specFrame:ClearAllPoints()
			frame.specFrame:SetPoint(self.db.profile.specPosition[1], frame, self.db.profile.specPosition[3], self.db.profile.specPosition[4], self.db.profile.specPosition[5])
			self:SetupDrag(frame.specFrame, nil, self.db.profile.specPosition, true, true)

			frame.healthbar:ClearAllPoints()
			frame.manabar:ClearAllPoints()

			for k, v in pairs(textTable) do
				frame[v]:ClearAllPoints()
			end

			if self.db.profile.mirroredFrames then
				frame.name:SetPoint("BOTTOMLEFT", 32, 24)
				frame.classPortrait:SetPoint("TOPRIGHT", -83, -6)

				if self.db.profile.simpleFrames then
					frame.healthbar:SetPoint("TOPLEFT", frame.classPortrait, "TOPRIGHT", 2, -2)

					frame.manabar:SetPoint("TOP", frame.healthbar, "BOTTOM", 0, 0)
					frame.manabar:SetPoint("BOTTOMLEFT", frame.classPortrait, "BOTTOMRIGHT", 2, 2)
				else
					frame.texture:SetTexCoord(0.796, 0, 0, 0.5)
					frame.healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 29, -12)

					frame.manabar:SetPoint("TOPLEFT", frame, "TOPLEFT", 29, -20)
				end
			else
				frame.name:SetPoint("BOTTOMLEFT", 3, 24)
				frame.classPortrait:SetPoint("TOPRIGHT", -13, -6)

				if self.db.profile.simpleFrames then
					frame.healthbar:SetPoint("TOPRIGHT", frame.classPortrait, "TOPLEFT", -2, -2)

					frame.manabar:SetPoint("TOP", frame.healthbar, "BOTTOM", 0, 0)
					frame.manabar:SetPoint("BOTTOMRIGHT", frame.classPortrait, "BOTTOMLEFT", -2, 2)
				else
					frame.texture:SetTexCoord(0, 0.796, 0, 0.5)
					frame.healthbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -12)

					frame.manabar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -20)
				end
			end

			if self.db.profile.simpleFrames then
				frame.texture:Hide()
				frame.classPortrait:SetSize(30, 30)

				frame.healthbar:SetHeight(19)

				frame.healthtext:SetPoint("CENTER", frame.healthbar)
				frame.healthtextleft:SetPoint("LEFT", frame.healthbar)
				frame.healthtextright:SetPoint("RIGHT", frame.healthbar)

				frame.manatext:SetPoint("CENTER", frame.manabar)
				frame.manatextleft:SetPoint("LEFT", frame.manabar)
				frame.manatextright:SetPoint("RIGHT", frame.manabar)
			else
				frame.texture:Show()
				frame.classPortrait:SetSize(26, 26)

				frame.healthbar:SetHeight(8)

				frame.healthtext:SetPoint("CENTER", frame.healthbar, 0, 2)
				frame.healthtextleft:SetPoint("LEFT", frame.healthbar, 0, 2)
				frame.healthtextright:SetPoint("RIGHT", frame.healthbar, 0, 2)

				frame.manatext:SetPoint("CENTER", frame.manabar, 0, 2)
				frame.manatextleft:SetPoint("LEFT", frame.manabar, 0, 2)
				frame.manatextright:SetPoint("RIGHT", frame.manabar, 0, 2)
			end

			-- Make frame movable
			self:SetupDrag(frame, self.ArenaEnemyFrames, self.db.profile.position, false, false)

			-- Also adding drag functionality to health & mana bars for ease of use
			for _, v in pairs({v.."HealthBar", v.."ManaBar"}) do
				self:SetupDrag(_G[v], self.ArenaEnemyFrames, self.db.profile.position, false, false)
			end

			frame:ClearAllPoints()

			if i == 1 then
				-- Anchor first frame to the top of ArenaEnemyFrames
				frame:SetPoint("TOP")
			elseif k == 1 then
				-- Anchor all remaining remaining frames underneath the previous frame
				frame:SetPoint("TOP", _G["ArenaEnemyFrame"..i-1], "BOTTOM", 0, -20)
			else
				frame:SetPoint("TOP", _G["ArenaPrepFrame"..i-1], "BOTTOM", 0, -20)
			end

			if instanceType ~= "pvp" then
				frame:SetPoint("RIGHT", -2)
			else
				-- When in a battleground, shift frames left to make space for faction icon (these are really flag carriers, not arena opponents)
				frame:SetPoint("RIGHT", -18)
			end

			if k == 1 then
				-- Trinkets: position & font size
				local cc = frame["CC"]
				cc:SetSize(self.db.profile.trinketSize, self.db.profile.trinketSize)
				cc:ClearAllPoints()
				cc:SetPoint(self.db.profile.trinketPosition[1], frame, self.db.profile.trinketPosition[3], self.db.profile.trinketPosition[4], self.db.profile.trinketPosition[5])
				local fontFace, _, fontFlags = cc.Cooldown.Text:GetFont()
				cc.Cooldown.Text:SetFont(fontFace, sArena.db.profile.trinketFontSize, fontFlags)
				cc.Cooldown:SetHideCountdownNumbers(false)
				self:SetupDrag(cc, nil, self.db.profile.trinketPosition, true, true)

				frame.castBar:SetScale(self.db.profile.castBarScale)
				frame.castBar:ClearAllPoints()
				frame.castBar:SetPoint(self.db.profile.castBarPosition[1], frame, self.db.profile.castBarPosition[3], self.db.profile.castBarPosition[4], self.db.profile.castBarPosition[5])
				self:SetupDrag(frame.castFrame, frame.castBar, self.db.profile.castBarPosition, true, true)

				frame.healthbar.textLockable = self.db.profile.statusText
				frame.manabar.textLockable = self.db.profile.statusText

				for k, v in pairs(textTable) do
					frame[v]:SetFont(font, self.db.profile.statusTextFontSize, flags)

					if self.db.profile.statusText then
						frame[v]:Show()
					else
						frame[v]:Hide()
					end
				end
			end
		end
	end

	self.events:Fire("sArena_RefreshConfig")

	if sArena.testMode then self:TestMode() end
end

function sArena:TestMode(setting)
	if self:Combat() then return end

	if setting ~= nil then
		sArena.testMode = setting
	end

	if not sArena.testMode then
		-- If test mode is disabled & we are outside of a pvp environment, hide the frames
		local _, instanceType = IsInInstance()
		if instanceType ~= "pvp" and instanceType ~= "arena" then self.ArenaEnemyFrames:Hide() end

		-- Hide castbar dragframes
		for i = 1, 5 do
			local arenaFrame = _G["ArenaEnemyFrame"..i]
			arenaFrame.castFrame:Hide()
		end
	else
		self.ArenaEnemyFrames:Show()

		for i = 1, 3 do
			local arenaFrame = _G["ArenaEnemyFrame"..i]
			local petFrame = _G["ArenaEnemyFrame"..i.."PetFrame"]

			arenaFrame:Show()
			if SHOW_ARENA_ENEMY_PETS == "1" then petFrame:Show() else petFrame:Hide() end

			arenaFrame.castFrame:Show()

			arenaFrame.CC.Icon:SetTexture("Interface\\Icons\\ability_pvp_gladiatormedallion")
			CooldownFrame_Set(arenaFrame.CC.Cooldown, GetTime(), 120, 1, true)

			arenaFrame.healthbar:Show()
			arenaFrame.healthbar:SetMinMaxValues(0,100)
			arenaFrame.healthbar:SetValue(100)
			arenaFrame.healthbar.forceHideText = false
			arenaFrame.manabar:Show()
			arenaFrame.manabar:SetMinMaxValues(0,100)
			arenaFrame.manabar:SetValue(100)
			arenaFrame.manabar.forceHideText = false
			if self.db.profile.simpleFrames then
				arenaFrame.classPortrait:SetTexture(classIcons[testModeClasses[i]])
				arenaFrame.classPortrait:SetTexCoord(0, 1, 0, 1)
				arenaFrame.specBorder:Hide()
				arenaFrame.specPortrait:SetTexture(specIcons[i])
			else
				arenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				arenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[testModeClasses[i]]))
				arenaFrame.specBorder:Show()
				SetPortraitToTexture(arenaFrame.specPortrait, specIcons[i])
			end

			if self.db.profile.hideNames then
				arenaFrame.name:SetText("")
			else
				arenaFrame.name:SetText("arena"..i)
			end

			local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[testModeClasses[i]] or RAID_CLASS_COLORS[testModeClasses[i]]

			if self.db.profile.classColours then arenaFrame.healthbar:SetStatusBarColor(c.r, c.g, c.b)
			else arenaFrame.healthbar:SetStatusBarColor(0, 1, 0)
			end

			if i == 1 then c = PowerBarColor["ENERGY"]
			else c = PowerBarColor["MANA"]
			end

			arenaFrame.manabar:SetStatusBarColor(c.r, c.g, c.b)
		end

		ArenaEnemyBackground:SetPoint("BOTTOMLEFT", "ArenaEnemyFrame3PetFrame", "BOTTOMLEFT", -15, -10)
		if (SHOW_PARTY_BACKGROUND == "1") then ArenaEnemyBackground:Show() else ArenaEnemyBackground:Hide() end
	end

	self.events:Fire("sArena_TestMode")
end

function sArena:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "pvp" or instanceType == "arena" then
		self.testMode = false
		self:TestMode()
		self.ArenaEnemyFrames:Show()

		-- Prevent objective tracker from anchoring itself to arena frames while in arena/bg
		SetCVar("showArenaEnemyFrames", false)
		ArenaEnemyFrames_CheckEffectiveEnableState(ArenaEnemyFrames)
	else
		self.ArenaEnemyFrames:Hide()
		SetCVar("showArenaEnemyFrames", true)
	end
end

function sArena:Combat()
	if InCombatLockdown() then
		self:Print("Must leave combat to do that.")
		return true
	end
end

function sArena:PartyMemberBackground_SetOpacity()
	-- Fix opacity slider for ArenaPrepBackground
	local alpha = 1.0 - OpacityFrameSlider:GetValue();
	if ( ArenaPrepBackground_SetOpacity ) then
		ArenaPrepBackground_SetOpacity();
	end
end

function sArena:ArenaEnemyFrame_SetMysteryPlayer(frame)
	if self.db.profile.simpleFrames then
		frame.classPortrait:SetTexture(134400)
	end
end

function sArena:ArenaEnemyFrame_UpdatePlayer(frame)
	if self.db.profile.simpleFrames then
			local id = frame:GetID()

			local _, class = UnitClass(frame.unit)
			if class then
				frame.classPortrait:SetTexture(classIcons[class])
				frame.classPortrait:SetTexCoord(0, 1, 0, 1)
			end
			local specID = GetArenaOpponentSpec(id)
			if specID and specID > 0 then
				local _, _, _, specIcon = GetSpecializationInfoByID(specID)
				frame.specBorder:Hide()
				frame.specPortrait:SetTexture(specIcon)
			end
	end
	if self.db.profile.hideNames and frame.name then
		frame.name:SetText("")
	end
end

function sArena:ArenaPrepFrames_UpdateFrames()
	local numOpps = GetNumArenaOpponentSpecs()
	for i=1, 5 do
		local prepFrame = _G["ArenaPrepFrame"..i];
		if i <= numOpps then
			local specID = GetArenaOpponentSpec(i)
			if specID > 0 then
				if self.db.profile.simpleFrames then
					local _, _, _, specIcon, _, class = GetSpecializationInfoByID(specID)
					if class then
						prepFrame.classPortrait:SetTexture(classIcons[class]);
						prepFrame.classPortrait:SetTexCoord(0, 1, 0, 1)
					end
					prepFrame.specPortrait:SetTexture(specIcon)
					prepFrame.specBorder:Hide()
				else
					prepFrame.specBorder:Show()
				end
			end
		end
	end
end

function sArena:ClassColours(statusbar)
	if not self.db.profile.classColours then return end
	if healthBars[statusbar:GetName()] then
		local _, class = UnitClass(statusbar.unit)
		if not class then return end

		local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]

		if not statusbar.lockColor then statusbar:SetStatusBarColor(c.r, c.g, c.b) end
	end
end

function sArena:OnMouseDown(frame)
	if IsShiftKeyDown() and IsControlKeyDown() and not frame.targetFrame.isMoving then
		frame.targetFrame:StartMoving()
		frame.targetFrame.isMoving = true
	end
end

function sArena:OnMouseUp(frame)
	if frame.targetFrame.isMoving then
		frame.targetFrame:StopMovingOrSizing()
		frame.targetFrame.isMoving = false

		if frame.setting then
			frame.setting[1], frame.setting[2], frame.setting[3] = "CENTER", "UIParent", "BOTTOMLEFT"
			frame.setting[4], frame.setting[5] = frame.targetFrame:GetCenter()
		end

		if frame.keepRelative then
			frame.setting[1], frame.setting[2], frame.setting[3] = "CENTER", frame.targetFrame:GetParent():GetName(), "CENTER"
			frame.setting[4], frame.setting[5] = self:CalcPoint(frame.targetFrame)
		end

		if frame.refreshConfig then self:RefreshConfig() end
	end
end

function sArena:SetupDrag(frame, targetFrame, setting, keepRelative, refreshConfig)
	frame.setting = setting

	if not frame.setupDrag then
		if not targetFrame then targetFrame = frame end
		frame.targetFrame = targetFrame
		frame.keepRelative = keepRelative
		frame.refreshConfig = refreshConfig
		frame.setupDrag = true

		self:SecureHookScript(frame, "OnMouseDown", OnMouseDown)
		self:SecureHookScript(frame, "OnMouseUp", OnMouseUp)
	end
end

function sArena:CalcPoint(frame)
	local parentX, parentY = frame:GetParent():GetCenter()
	local frameX, frameY = frame:GetCenter()

	parentX, parentY, frameX, frameY = parentX + 0.5, parentY + 0.5, frameX + 0.5, frameY + 0.5

	if ( not frameX ) then return end

	local scale = frame:GetScale()

	parentX, parentY = floor(parentX), floor(parentY)
	frameX, frameY = floor(frameX * scale), floor(frameY * scale)
	frameX, frameY = floor((parentX - frameX) * -1), floor((parentY - frameY) * -1)

	return frameX/scale, frameY/scale
end

function sArena:ChatCommand(input)
	if not input or input:trim() == "" then
		LibStub("AceConfigDialog-3.0"):Open("sArena")
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(sArena, "sarena", "sArena", input)
	end
end
