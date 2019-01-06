local layoutName = "BlizzTourney";
local layout = {};
layout.name = "|cff00b4ffBlizz|r Tourney"

layout.defaultSettings = {
    posX = 300,
    posY = 100,
    scale = 1,
    spacing = 20;
    growthDirection = 1,
    trinketFontSize = 12,
    castBar = {
        posX = -110,
        posY = -10,
        scale = 1,
        width = 90,
    },
    dr = {
        posX = -79,
        posY = 13,
        size = 22,
        borderSize = 2,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4;
    },
};

local function setupOptionsTable(self)
    layout.optionsTable = self:GetLayoutOptionsTable(layoutName);
end

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName];

    if ( not self.optionsTable ) then
        setupOptionsTable(frame.parent);
    end

    frame.parent.portraitClassIcon = true;
    frame.parent.portraitSpecIcon = true;

    if ( frame:GetID() == 3 ) then
        frame.parent:UpdateCastBarSettings(self.db.castBar);
        frame.parent:UpdateDRSettings(self.db.dr);
        frame.parent:UpdateFrameSettings(self.db);
    end

    frame:SetSize(126, 66);

    local hp = frame.HealthBar;
    hp:SetSize(87, 23);
    hp:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -30);
    hp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    local pp = frame.PowerBar;
    pp:SetSize(87, 12);
    pp:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -53);
    pp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill");

    local f = frame.ClassIcon;
    f:SetPoint("TOPRIGHT", -2, -2);
    f:SetSize(34, 34);
    f:Show();

    f = frame.SpecIcon;
    f:SetPoint("CENTER", frame, "CENTER", 27, 27);
    f:SetSize(14, 14);
    f:Show();

    local specBorder = frame.TexturePool:Acquire();
    specBorder:SetDrawLayer("ARTWORK", 3);
    specBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
    specBorder:SetDesaturated(1);
    specBorder:SetVertexColor(0.9, 0.9, 0.9, 1);
    specBorder:SetSize(38, 38);
    specBorder:SetPoint("CENTER", f, "CENTER", 7.5, -8);
    specBorder:Show();

    f = frame.Name;
    f:SetJustifyH("RIGHT");
    f:SetPoint("BOTTOMRIGHT", hp, "TOPRIGHT", -4, 4);
    f:SetSize(77, 14);

    f = frame.CastBar;
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.TrinketIcon;
    f:SetSize(25, 25);
    f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 4);

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", frame.HealthBar, "CENTER");
    f:SetSize(32, 32);

    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.ClassIcon);

    frame.HealthText:SetPoint("CENTER", frame.HealthBar);
    frame.HealthText:SetShadowOffset(0, 0);

    frame.PowerText:SetPoint("CENTER", frame.PowerBar);
    frame.PowerText:SetShadowOffset(0, 0);

    local underlay = frame.TexturePool:Acquire();
    underlay:SetDrawLayer("BACKGROUND", 1);
    underlay:SetColorTexture(0, 0, 0, 0.75);
    underlay:SetPoint("TOPLEFT", hp, "TOPLEFT");
    underlay:SetPoint("BOTTOMRIGHT", pp, "BOTTOMRIGHT");
    underlay:Show();

    local frameTexture = frame.TexturePool:Acquire();
    frameTexture:SetDrawLayer("ARTWORK", 1);
    frameTexture:SetSize(160, 80);
    frameTexture:SetPoint("TOPLEFT", frame, "TOPLEFT", -26, 6);
    frameTexture:SetAtlas("UnitFrame");
    frameTexture:SetTexCoord(1, 0, 0, 1);
    frameTexture:Show();
end

sArenaMixin.layouts[layoutName] = layout;
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings;
