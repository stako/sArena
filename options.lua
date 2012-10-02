-- Tekkub from WoWI/GitHub made this so easy!

sArena.OptionsPanel = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
sArena.OptionsPanel.name = sArena.addonName
sArena.OptionsPanel:Hide()

function sArena.OptionsPanel:Initialize()
	local title, subtitle = LibStub("tekKonfig-Heading").new(self, sArena.addonName, "Improved arena frames")

	local clear = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", -16, -16)
	clear:SetSize(56, 22)
	clear:SetText("Clear")
	clear.tiptext = "Hides any testing frames that are visible"
	clear:SetScript("OnClick", function(s) sArena:HideArenaEnemyFrames() end)

	local test5 = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", clear, "TOPLEFT", -25, 0)
	test5:SetSize(56, 22)
	test5:SetText("Test 5")
	test5.tiptext = "Displays 5 test frames"
	test5:SetScript("OnClick", function(s) sArena:Test(5) end)

	local test3 = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", test5, "TOPLEFT", -5, 0)
	test3:SetSize(56, 22)
	test3:SetText("Test 3")
	test3.tiptext = "Displays 3 test frames"
	test3:SetScript("OnClick", function(s) sArena:Test(3) end)

	local test2 = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", test3, "TOPLEFT", -5, 0)
	test2:SetSize(56, 22)
	test2:SetText("Test 2")
	test2.tiptext = "Displays 2 test frames"
	test2:SetScript("OnClick", function(s) sArena:Test(2) end)

	local lock = LibStub("tekKonfig-Button").new_small(self, "TOPRIGHT", test2, "TOPLEFT", -25, 0)
	lock:SetSize(56, 22)
	lock:SetText(sArenaDB.lock and "Unlock" or "Lock")
	lock.tiptext = "Hides title bar and prevents dragging"
	lock:SetScript("OnClick", function(s)
		if sArena:CombatLockdown() then return end

		sArenaDB.lock = not sArenaDB.lock
		lock:SetText(sArenaDB.lock and "Unlock" or "Lock")
		
		if sArenaDB.lock then
			sArena:Hide()
		else
			sArena:Show()
		end
	end)

	local scale = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	scale:SetText("Frame Scale: ")
	scale:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, 0)

	local backdrop = {
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground", insets = {left = 0, right = 0, top = 0, bottom = 0},
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 8
	}

	local scaleEditBox = CreateFrame("EditBox", nil, self)
	scaleEditBox:SetPoint("TOPLEFT", scale, "TOPRIGHT", 4, 2)
	scaleEditBox:SetSize(35, 20)
	scaleEditBox:SetFontObject(GameFontHighlight)
	scaleEditBox:SetTextInsets(4,4,2,2)
	scaleEditBox:SetBackdrop(backdrop)
	scaleEditBox:SetBackdropColor(.1,.1,.1,.5)
	scaleEditBox:SetAutoFocus(false)
	scaleEditBox:SetText(sArenaDB.scale)
	scaleEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			scaleEditBox:SetText(sArenaDB.scale)
			return
		end
		
		if type(tonumber(scaleEditBox:GetText())) == "number" and tonumber(scaleEditBox:GetText()) > 0 then
			sArenaDB.scale = scaleEditBox:GetText()
			sArena.Frame:SetScale(sArenaDB.scale)
		else
			scaleEditBox:SetText(sArenaDB.scale)
		end
	end)
	scaleEditBox:SetScript("OnEscapePressed", scaleEditBox.ClearFocus)
	scaleEditBox:SetScript("OnEnterPressed", scaleEditBox.ClearFocus)
	scaleEditBox.tiptext = "Sets the scale of the arena frames. Numbers between 0.5 and 2 recommended."
	scaleEditBox:SetScript("OnEnter", clear:GetScript("OnEnter"))
	scaleEditBox:SetScript("OnLeave", clear:GetScript("OnLeave"))
	
	local trinketSize = self:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	trinketSize:SetText("Trinket Size: ")
	trinketSize:SetPoint("TOPLEFT", scale, "BOTTOMLEFT", 0, -16)
	
	local trinketSizeEditBox = CreateFrame("EditBox", nil, self)
	trinketSizeEditBox:SetPoint("TOPLEFT", scaleEditBox, "BOTTOMLEFT", 0, -7)
	trinketSizeEditBox:SetSize(35, 20)
	trinketSizeEditBox:SetFontObject(GameFontHighlight)
	trinketSizeEditBox:SetTextInsets(4,4,2,2)
	trinketSizeEditBox:SetBackdrop(backdrop)
	trinketSizeEditBox:SetBackdropColor(.1,.1,.1,.5)
	trinketSizeEditBox:SetAutoFocus(false)
	trinketSizeEditBox:SetText(sArenaDB.Trinkets.size)
	trinketSizeEditBox:SetScript("OnEditFocusLost", function() 
		if sArena:CombatLockdown() then
			trinketSizeEditBox:SetText(sArenaDB.Trinkets.size)
			return
		end
		
		if type(tonumber(trinketSizeEditBox:GetText())) == "number" and tonumber(trinketSizeEditBox:GetText()) > 0 then
			sArenaDB.Trinkets.size = trinketSizeEditBox:GetText()
			sArena.Trinkets:Resize(sArenaDB.Trinkets.size)
		else
			trinketSizeEditBox:SetText(sArenaDB.Trinkets.size)
		end
	end)
	trinketSizeEditBox:SetScript("OnEscapePressed", trinketSizeEditBox.ClearFocus)
	trinketSizeEditBox:SetScript("OnEnterPressed", trinketSizeEditBox.ClearFocus)
	trinketSizeEditBox.tiptext = "Sets the size of the trinket icons."
	trinketSizeEditBox:SetScript("OnEnter", clear:GetScript("OnEnter"))
	trinketSizeEditBox:SetScript("OnLeave", clear:GetScript("OnLeave"))
end

InterfaceOptions_AddCategory(sArena.OptionsPanel)
SLASH_sArena1 = "/sarena"
SlashCmdList[sArena.addonName] = function() InterfaceOptionsFrame_OpenToCategory(sArena.OptionsPanel) end