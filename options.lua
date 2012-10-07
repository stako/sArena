-- Tekkub from WoWI/GitHub made this so easy!

sArena.OptionsPanel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
sArena.OptionsPanel.name = sArena.addonName
sArena.OptionsPanel:Hide()

function sArena.OptionsPanel:Initialize()
	local Title, SubTitle = LibStub("tekKonfig-Heading").new(self, sArena.addonName, "Improved arena frames")

	local ClearButton = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", -16, -16)
	ClearButton:SetSize(56, 22)
	ClearButton:SetText("Clear")
	ClearButton.tiptext = "Hides any testing frames that are visible"
	ClearButton:SetScript("OnClick", function(s) sArena:HideArenaEnemyFrames() end)

	local Test5Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", ClearButton, "TOPLEFT", -25, 0)
	Test5Button:SetSize(56, 22)
	Test5Button:SetText("Test 5")
	Test5Button.tiptext = "Displays 5 test frames"
	Test5Button:SetScript("OnClick", function(s) sArena:Test(5) end)

	local Test3Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test5Button, "TOPLEFT", -5, 0)
	Test3Button:SetSize(56, 22)
	Test3Button:SetText("Test 3")
	Test3Button.tiptext = "Displays 3 test frames"
	Test3Button:SetScript("OnClick", function(s) sArena:Test(3) end)

	local Test2Button = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test3Button, "TOPLEFT", -5, 0)
	Test2Button:SetSize(56, 22)
	Test2Button:SetText("Test 2")
	Test2Button.tiptext = "Displays 2 test frames"
	Test2Button:SetScript("OnClick", function(s) sArena:Test(2) end)

	local LockButton = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", Test2Button, "TOPLEFT", -25, 0)
	LockButton:SetSize(56, 22)
	LockButton:SetText(sArenaDB.lock and "Unlock" or "Lock")
	LockButton.tiptext = "Hides title bar and prevents dragging"
	LockButton:SetScript("OnClick", function(s)
		if sArena:CombatLockdown() then return end

		sArenaDB.lock = not sArenaDB.lock
		LockButton:SetText(sArenaDB.lock and "Unlock" or "Lock")
		
		if sArenaDB.lock then
			sArena:Hide()
		else
			sArena:Show()
		end
	end)

	local ScaleText = self:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	ScaleText:SetText("Frame Scale: ")
	ScaleText:SetPoint("TOPLEFT", SubTitle, "BOTTOMLEFT", 0, 0)

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 0, right = 0, top = 0, bottom = 0},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8
	}

	local ScaleEditBox = CreateFrame("EditBox", nil, self)
	ScaleEditBox:SetPoint("TOPLEFT", ScaleText, "TOPRIGHT", 4, 2)
	ScaleEditBox:SetSize(35, 20)
	ScaleEditBox:SetFontObject(GameFontHighlight)
	ScaleEditBox:SetTextInsets(4,4,2,2)
	ScaleEditBox:SetBackdrop(backdrop)
	ScaleEditBox:SetBackdropColor(0,0,0,.9)
	ScaleEditBox:SetAutoFocus(false)
	ScaleEditBox:SetText(sArenaDB.scale)
	ScaleEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			ScaleEditBox:SetText(sArenaDB.scale)
			return
		end
		
		if type(tonumber(ScaleEditBox:GetText())) == "number" and tonumber(ScaleEditBox:GetText()) > 0 then
			sArenaDB.scale = ScaleEditBox:GetText()
			sArena.Frame:SetScale(sArenaDB.scale)
		else
			ScaleEditBox:SetText(sArenaDB.scale)
		end
	end)
	ScaleEditBox:SetScript("OnEscapePressed", ScaleEditBox.ClearFocus)
	ScaleEditBox:SetScript("OnEnterPressed", ScaleEditBox.ClearFocus)
	ScaleEditBox.tiptext = "Sets the scale of the arena frames. Numbers between 0.5 and 2 recommended."
	ScaleEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	ScaleEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
	
	local TrinketsFrame = LibStub("tekKonfig-Group").new(self, "Trinkets", "TOPLEFT", ScaleText, "BOTTOMLEFT", 0, -32)
	TrinketsFrame:SetPoint("RIGHT", self, -16, 0)
	TrinketsFrame:SetHeight(80)
	
	local TrinketsEnableCheckbox = LibStub("tekKonfig-Checkbox").new(self, nil, "Enable", "TOPLEFT", TrinketsFrame, 8, -8)
	TrinketsEnableCheckbox.tiptext = "Displays a cooldown icon when an enemy uses their PvP trinket."
	TrinketsEnableCheckbox:SetChecked(sArenaDB.Trinkets.enabled and true or false)
	TrinketsEnableCheckbox:SetScript("OnClick", function()
		sArenaDB.Trinkets.enabled = TrinketsEnableCheckbox:GetChecked() and true or false
		sArena.Trinkets:Clear()
		sArena.Trinkets:Test(5)
		sArena:PLAYER_ENTERING_WORLD()
	end)
	
	local TrinketsIconSizeText = TrinketsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	TrinketsIconSizeText:SetText("Icon Size: ")
	TrinketsIconSizeText:SetPoint("TOPLEFT", TrinketsEnableCheckbox, "BOTTOMLEFT", 6, -8)
	
	local TrinketsIconSizeEditBox = CreateFrame("EditBox", nil, self)
	TrinketsIconSizeEditBox:SetPoint("LEFT", TrinketsIconSizeText, "RIGHT", 4, -1)
	TrinketsIconSizeEditBox:SetSize(35, 20)
	TrinketsIconSizeEditBox:SetFontObject(GameFontHighlight)
	TrinketsIconSizeEditBox:SetTextInsets(4,4,2,2)
	TrinketsIconSizeEditBox:SetBackdrop(backdrop)
	TrinketsIconSizeEditBox:SetBackdropColor(0,0,0,.9)
	TrinketsIconSizeEditBox:SetAutoFocus(false)
	TrinketsIconSizeEditBox:SetText(sArenaDB.Trinkets.size)
	TrinketsIconSizeEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			TrinketsIconSizeEditBox:SetText(sArenaDB.Trinkets.size)
			return
		end
		
		if type(tonumber(TrinketsIconSizeEditBox:GetText())) == "number" and tonumber(TrinketsIconSizeEditBox:GetText()) > 0 then
			sArenaDB.Trinkets.size = TrinketsIconSizeEditBox:GetText()
			sArena.Trinkets:Resize(sArenaDB.Trinkets.size)
		else
			TrinketsIconSizeEditBox:SetText(sArenaDB.Trinkets.size)
		end
	end)
	TrinketsIconSizeEditBox:SetScript("OnEscapePressed", TrinketsIconSizeEditBox.ClearFocus)
	TrinketsIconSizeEditBox:SetScript("OnEnterPressed", TrinketsIconSizeEditBox.ClearFocus)
	TrinketsIconSizeEditBox.tiptext = "Sets the size of the trinket icons."
	TrinketsIconSizeEditBox:SetScript("OnEnter", ClearButton:GetScript("OnEnter"))
	TrinketsIconSizeEditBox:SetScript("OnLeave", ClearButton:GetScript("OnLeave"))
end

InterfaceOptions_AddCategory(sArena.OptionsPanel)
SLASH_sArena1 = "/sarena"
SlashCmdList[sArena.addonName] = function() InterfaceOptionsFrame_OpenToCategory(sArena.OptionsPanel) end