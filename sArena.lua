----------------------------------------
-- Credits
----------------------------------------
-- Wowwiki
-- Kouri
-- Kollektiv
-- Lyn
-- haste
-- evl
-- Blizzard

local addonName, L = ...
local sArenaDB
local sArena = CreateFrame("Frame")
sArena.trinkets = {}
local init = false
local TestMode, FrameXOffsetSlider, FrameYOffsetSlider, TrinketXOffsetSlider, TrinketYOffsetSlider

----------------------------------------
-- Called when an option is changed
----------------------------------------
function sArena:Update()
	if not IsAddOnLoaded("Blizzard_ArenaUI") then
		LoadAddOn("Blizzard_ArenaUI")
	end
	ArenaEnemyFrames:SetScale(sArenaDB.frames.scale)
	ArenaEnemyFrame1:ClearAllPoints()
	ArenaEnemyFrame1:SetPoint(sArenaDB.frames.point, sArenaDB.frames.anchor, sArenaDB.frames.relativePoint, sArenaDB.frames.xOffset, sArenaDB.frames.yOffset)
	local arenaFrame
	for i = 1, MAX_ARENA_ENEMIES do
		arenaFrame = "ArenaEnemyFrame"..i
		sArena.trinkets["arena"..i]:SetSize(sArenaDB.trinkets.size, sArenaDB.trinkets.size)
		sArena.trinkets["arena"..i]:ClearAllPoints()
		sArena.trinkets["arena"..i]:SetPoint(sArenaDB.trinkets.point, arenaFrame, sArenaDB.trinkets.relativePoint, sArenaDB.trinkets.xOffset, sArenaDB.trinkets.yOffset)
	end
	FrameXOffsetSlider:SetValue(sArenaDB.frames.xOffset)
	FrameYOffsetSlider:SetValue(sArenaDB.frames.yOffset)
	TrinketXOffsetSlider:SetValue(sArenaDB.trinkets.xOffset)
	TrinketYOffsetSlider:SetValue(sArenaDB.trinkets.yOffset)
end

----------------------------------------
-- Create elements once arena frames loaded
----------------------------------------
function sArena:init()
	if init then return end
	local arenaFrame, trinket
	for i = 1, MAX_ARENA_ENEMIES do
		arenaFrame = "ArenaEnemyFrame"..i
		trinket = CreateFrame("Cooldown", arenaFrame.."Trinket", ArenaEnemyFrames)
		trinket:SetPoint(sArenaDB.trinkets.point, arenaFrame, sArenaDB.trinkets.relativePoint, sArenaDB.trinkets.xOffset, sArenaDB.trinkets.yOffset)
		trinket:SetSize(sArenaDB.trinkets.size, sArenaDB.trinkets.size)
		trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
		trinket.icon:SetAllPoints()
		trinket.icon:SetTexture("Interface\\Icons\\inv_jewelry_trinketpvp_01")
		trinket:Hide()
		sArena.trinkets["arena"..i] = trinket
	end
	sArena:Update()
	init = true
end

----------------------------------------
-- Default settings
----------------------------------------
local DBdefaults = {
	testmode = false,
	version = 1,
	frames = {
		scale = 1,
		point = "TOPRIGHT",
		anchor = "ArenaEnemyFrames",
		relativePoint = "TOPRIGHT",
		xOffset = -2,
		yOffset = 0,
	},
	trinkets = {
		enabled = true,
		size = 22,
		point = "LEFT",
		relativePoint = "RIGHT",
		xOffset = 2,
		yOffset = -2,
	},
}

----------------------------------------
-- OnEvent Scripts
----------------------------------------
sArena:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)

function sArena:ADDON_LOADED(arg1)
	if arg1 == addonName then
		if not _G.sArenaDB then
			_G.sArenaDB = CopyTable(DBdefaults)
		end
		sArenaDB = _G.sArenaDB
		sArenaDB.testmode = false
	elseif arg1 == "Blizzard_ArenaUI" then
		sArena.init()
	end
end
sArena:RegisterEvent("ADDON_LOADED")

function sArena:UNIT_SPELLCAST_SUCCEEDED(unitID, spell, rank, lineID, spellID)
	if not sArena.trinkets[unitID] then
		return
	end
	if spellID == 59752 or spellID == 42292 then
		CooldownFrame_SetTimer(sArena.trinkets[unitID], GetTime(), 120, 1)
		--SendChatMessage("Trinket used by: "..GetUnitName(unitID, true), "PARTY")
	elseif spellID == 7744 then
		CooldownFrame_SetTimer(sArena.trinkets[unitID], GetTime(), 30, 1)
		--SendChatMessage("WotF used by: "..GetUnitName(unitID, true), "PARTY")
	end
end

function sArena:PLAYER_ENTERING_WORLD()
	TestMode:SetChecked(false)
	TestMode:OnClick()
	local _, instanceType = IsInInstance()
	if instanceType == "arena" then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	elseif self:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED") then
		self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	end
end
sArena:RegisterEvent("PLAYER_ENTERING_WORLD")

----------------------------------------
-- Options Panel Declarations
----------------------------------------
local O = addonName .. "OptionsPanel"

local OptionsPanel = CreateFrame("Frame", O)
OptionsPanel.name = addonName

----------------------------------------
-- TestMode Checkbox
----------------------------------------
TestMode = CreateFrame("CheckButton", O.."TestMode", OptionsPanel, "OptionsCheckButtonTemplate")
_G[O.."TestModeText"]:SetText(L["Test Mode"])
function TestMode:OnClick()
	local _, instanceType = IsInInstance();
	if self:GetChecked() then
		if not IsAddOnLoaded("Blizzard_ArenaUI") then
			LoadAddOn("Blizzard_ArenaUI")
		end
		ArenaEnemyFrames:Show()
		local arenaFrame
		for i = 1, MAX_ARENA_ENEMIES do
			arenaFrame = _G["ArenaEnemyFrame"..i]
			arenaFrame.classPortrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			arenaFrame.classPortrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS["WARRIOR"]))
			arenaFrame.name:SetText("Mingebag")
			arenaFrame:Show()
			CooldownFrame_SetTimer(sArena.trinkets["arena"..i], GetTime(), 300, 1)
		end
	else
		if instanceType ~= "arena" then
			if ArenaEnemyFrames then ArenaEnemyFrames:Hide() end
		end
		for _, trinket in pairs(sArena.trinkets) do
			trinket:SetCooldown(0, 0)
			trinket:Hide()
		end
	end
end
TestMode:SetScript("OnClick", TestMode.OnClick)

----------------------------------------
-- DropDownMenu helper function
----------------------------------------
local info = UIDropDownMenu_CreateInfo()
local function AddItem(owner, text, value)
	info.owner = owner
	info.func = owner.OnClick
	info.text = text
	info.value = value
	info.checked = nil -- initially set the menu item to being unchecked
	UIDropDownMenu_AddButton(info)
end

----------------------------------------
-- Frame Anchor Drop Down
----------------------------------------
local FrameAnchorDropDown = CreateFrame("Frame", O.."FrameAnchorDropDown", OptionsPanel, "UIDropDownMenuTemplate")
function FrameAnchorDropDown:OnClick()
	UIDropDownMenu_SetSelectedValue(FrameAnchorDropDown, self.value)
	if self.value == "ArenaEnemyFrames" then
		sArenaDB.frames.point = DBdefaults.frames.point
		sArenaDB.frames.anchor = DBdefaults.frames.anchor
		sArenaDB.frames.relativePoint = DBdefaults.frames.relativePoint
		sArenaDB.frames.xOffset = DBdefaults.frames.xOffset
		sArenaDB.frames.yOffset = DBdefaults.frames.yOffset
	else
		sArenaDB.frames.point = "CENTER"
		sArenaDB.frames.anchor = self.value
		sArenaDB.frames.relativePoint = "CENTER"
		sArenaDB.frames.xOffset = 0
		sArenaDB.frames.yOffset = 0
	end
	sArena:Update()
end
UIDropDownMenu_Initialize(FrameAnchorDropDown, function()
	for _, v in ipairs({ "ArenaEnemyFrames", "PlayerFrame", "FocusFrame", "UIParent" }) do
		AddItem(FrameAnchorDropDown, L[v], v)
	end
end)

----------------------------------------
-- Slider helper function, thanks to Kollektiv
----------------------------------------
local function CreateSlider(text, parent, low, high, step)
	local name = parent:GetName() .. text
	local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
	slider:SetWidth(160)
	slider:SetMinMaxValues(low, high)
	slider:SetValueStep(step)
	--_G[name .. "Text"]:SetText(text)
	_G[name .. "Low"]:SetText(low)
	_G[name .. "High"]:SetText(high)
	return slider
end

----------------------------------------
-- Frame Scale Slider
----------------------------------------
local FrameScaleSlider = CreateSlider("FrameScaleSlider", OptionsPanel, 0.5, 3.0, 0.1)
FrameScaleSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Scale"] .. " (" .. tonumber(string.format("%." .. 1 .. "f", value)) .. ")")
	sArenaDB.frames.scale = value
	sArena:Update()
end)

----------------------------------------
-- Frame XOffset Slider
----------------------------------------
FrameXOffsetSlider = CreateSlider("FrameXOffsetSlider", OptionsPanel, -1024, 1024, 16)
FrameXOffsetSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Horizontal"] .. " (" .. value .. ")")
	sArenaDB.frames.xOffset = value
	sArena:Update()
end)

----------------------------------------
-- Frame YOffset Slider
----------------------------------------
FrameYOffsetSlider = CreateSlider("FrameYOffsetSlider", OptionsPanel, -1024, 1024, 16)
FrameYOffsetSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Vertical"] .. " (" .. value .. ")")
	sArenaDB.frames.yOffset = value
	sArena:Update()
end)

----------------------------------------
-- Trinket Size Slider
----------------------------------------
local TrinketSizeSlider = CreateSlider("TrinketSizeSlider", OptionsPanel, 15, 35, 1)
TrinketSizeSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Size"] .. " (" .. value .. ")")
	sArenaDB.trinkets.size = value
	sArena:Update()
end)

----------------------------------------
-- Trinket XOffset Slider
----------------------------------------
TrinketXOffsetSlider = CreateSlider("TrinketXOffsetSlider", OptionsPanel, -134, 32, 1)
TrinketXOffsetSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Horizontal"] .. " (" .. value .. ")")
	sArenaDB.trinkets.xOffset = value
	sArena:Update()
end)

----------------------------------------
-- Trinket YOffset Slider
----------------------------------------
TrinketYOffsetSlider = CreateSlider("TrinketYOffsetSlider", OptionsPanel, -64, 64, 1)
TrinketYOffsetSlider:SetScript("OnValueChanged", function(self, value)
	_G[self:GetName() .. "Text"]:SetText(L["Vertical"] .. " (" .. value .. ")")
	sArenaDB.trinkets.yOffset = value
	sArena:Update()
end)

----------------------------------------
-- Labels
----------------------------------------
local TitleLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
TitleLabel:SetText(addonName)

local SubTitleLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
SubTitleLabel:SetText(GetAddOnMetadata(addonName, "Notes") .. " (" .. GetAddOnMetadata(addonName, "Version") .. ")")

local FramesLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
FramesLabel:SetText(L["Frames"])

local FrameAnchorDropDownLabel = OptionsPanel:CreateFontString(O.."FrameAnchorDropDownLabel", "ARTWORK", "GameFontNormal")
FrameAnchorDropDownLabel:SetText(L["Anchor"])

local TrinketsLabel = OptionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
TrinketsLabel:SetText(L["Trinkets"])

----------------------------------------
-- Options Panel Layout
----------------------------------------
TitleLabel:SetPoint("TOPLEFT", 16, -16)
SubTitleLabel:SetPoint("LEFT", TitleLabel, "RIGHT", 4, -2)

TestMode:SetPoint("TOPLEFT", TitleLabel, "BOTTOMLEFT", 0, -16)

FramesLabel:SetPoint("TOPLEFT", TestMode, "BOTTOMLEFT", 0, -16)
FrameScaleSlider:SetPoint("TOPLEFT", FramesLabel, "BOTTOMLEFT", 2, -24)

FrameAnchorDropDownLabel:SetPoint("BOTTOMLEFT", FrameScaleSlider, "TOPRIGHT", 32, 8)
FrameAnchorDropDown:SetPoint("TOP", FrameAnchorDropDownLabel, "BOTTOMLEFT", 0, 0)

FrameXOffsetSlider:SetPoint("TOPLEFT", FrameScaleSlider, "BOTTOMLEFT", 0, -32)
FrameYOffsetSlider:SetPoint("LEFT", FrameXOffsetSlider, "RIGHT", 24, 0)

TrinketsLabel:SetPoint("TOPLEFT", FrameXOffsetSlider, "BOTTOMLEFT", 0, -24)
TrinketSizeSlider:SetPoint("TOPLEFT", TrinketsLabel, "BOTTOMLEFT", 2, -24)

TrinketXOffsetSlider:SetPoint("TOPLEFT", TrinketSizeSlider, "BOTTOMLEFT", 0, -32)
TrinketYOffsetSlider:SetPoint("LEFT", TrinketXOffsetSlider, "RIGHT", 24, 0)

----------------------------------------
-- Called when options panel is opened
----------------------------------------
OptionsPanel.refresh = function()
	sArenaOptionsPanelFrameAnchorDropDownText:SetText(L[sArenaDB.frames.anchor])
	FrameScaleSlider:SetValue(sArenaDB.frames.scale)
	FrameXOffsetSlider:SetValue(sArenaDB.frames.xOffset)
	FrameYOffsetSlider:SetValue(sArenaDB.frames.yOffset)
	TrinketSizeSlider:SetValue(sArenaDB.trinkets.size)
	TrinketXOffsetSlider:SetValue(sArenaDB.trinkets.xOffset)
	TrinketYOffsetSlider:SetValue(sArenaDB.trinkets.yOffset)
end

----------------------------------------
-- Called when defaults button pushed
----------------------------------------
OptionsPanel.default = function()
	sArenaDB = CopyTable(DBdefaults)
	sArena:Update()
end

InterfaceOptions_AddCategory(OptionsPanel)

----------------------------------------
-- Create slash command to open options
----------------------------------------
SLASH_sArena1 = "/sarena"
SlashCmdList[addonName] = function() InterfaceOptionsFrame_OpenToCategory(OptionsPanel) end