
local lib, oldminor = LibStub:NewLibrary("tekKonfig-TopTab", 1)
if not lib then return end
oldminor = oldminor or 0


function lib:activatetab()
	self.left:ClearAllPoints()
	self.left:SetPoint("TOPLEFT")
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self:Disable()
end

function lib:deactivatetab()
	self.left:ClearAllPoints()
	self.left:SetPoint("BOTTOMLEFT", 0, 2)
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self:Enable()
end

function lib:SetTextHelper(...) self:SetWidth(40 + self:GetFontString():GetStringWidth()); return ... end
function lib:NewSetText(...) return lib.SetTextHelper(self, self.OrigSetText(self, ...)) end

function lib.new(parent, text, ...)
	local tab = CreateFrame("Button", nil, parent)
	tab:SetHeight(24)
	tab:SetPoint(...)
	tab:SetFrameLevel(tab:GetFrameLevel() + 4)

	tab.left = tab:CreateTexture(nil, "BORDER")
	tab.left:SetWidth(20) tab.left:SetHeight(24)
	tab.left:SetTexCoord(0, 0.15625, 0, 1)

	tab.right = tab:CreateTexture(nil, "BORDER")
	tab.right:SetWidth(20) tab.right:SetHeight(24)
	tab.right:SetPoint("TOP", tab.left)
	tab.right:SetPoint("RIGHT", tab)
	tab.right:SetTexCoord(0.84375, 1, 0, 1)

	tab.middle = tab:CreateTexture(nil, "BORDER")
	tab.middle:SetHeight(24)
	tab.middle:SetPoint("LEFT", tab.left, "RIGHT")
	tab.middle:SetPoint("RIGHT", tab.right, "Left")
	tab.middle:SetTexCoord(0.15625, 0.84375, 0, 1)

	tab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
	local hilite = tab:GetHighlightTexture()
	hilite:ClearAllPoints()
	hilite:SetPoint("LEFT", 10, -4)
	hilite:SetPoint("RIGHT", -10, -4)

	tab:SetDisabledFontObject(GameFontHighlightSmall)
	tab:SetHighlightFontObject(GameFontHighlightSmall)
	tab:SetNormalFontObject(GameFontNormalSmall)
	tab.OrigSetText = tab.SetText
	tab.SetText = lib.NewSetText
	tab:SetText(text)

	tab.Activate, tab.Deactivate = lib.activatetab, lib.deactivatetab
	tab:Activate()

	return tab
end

