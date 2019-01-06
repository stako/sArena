local layoutName = "BlizzArena";
local layout = {};
layout.name = "|cff00b4ffBlizz|r Arena"

layout.defaultSettings = {
    trinketPosX = 64,
    trinketPosY = 0,
    castBar = {
        posX = -100,
        posY = 0,
        scale = 1,
        width = 84,
    },
    dr = {
        posX = -74,
        posY = 24,
        size = 22,
        borderSize = 2,
        fontSize = 12,
        spacing = 6,
        growthDirection = 4;
    },
};

local function updateTrinketPositioning(frame)
    frame.TrinketIcon:ClearAllPoints();
    frame.TrinketIcon:SetPoint("CENTER", frame, "CENTER", layout.db.trinketPosX, layout.db.trinketPosY);
end

local function setupOptionsTable(self)
    layout.optionsTable = {
        arenaFrames = {
            order = 1,
            name = "Arena Frames",
            type = "group",
            args = {
                trinketPositioning = {
                    order = 1,
                    name = "Trinket Positioning",
                    type = "group",
                    inline = true,
                    get = function(info) return layout.db[info[#info]]; end,
                    set = function(info, val) layout.db[info[#info]] = val; for i = 1, 3 do updateTrinketPositioning(self["arena"..i]); end end,
                    args = {
                        trinketPosX = {
                            order = 1,
                            name = "Horizontal",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                        trinketPosY = {
                            order = 2,
                            name = "Vertical",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                    },
                },
            },
        },
        castBar = self:OptionsTable_GetCastBar(layoutName, 2),
        dr = self:OptionsTable_GetDR(layoutName, 3),
    };
end

function layout:Initialize(frame)
    self.db = frame.parent.db.profile.layoutSettings[layoutName];

    if ( not self.optionsTable ) then
        setupOptionsTable(frame.parent);
    end

    frame.parent.portraitClassIcon = true;
    frame.parent.portraitSpecIcon = true;

    frame:SetSize(102, 32);

    local healthBar = frame.HealthBar;
    healthBar:SetSize(69, 7);
    healthBar:SetPoint("TOPLEFT", 3, -9);
    healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

    local powerBar = frame.PowerBar;
    powerBar:SetSize(69, 7);
    powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1);
    powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill");

    local f = frame.ClassIcon;
    f:SetPoint("TOPRIGHT", -2, -2);
    f:SetSize(26, 26);
    f:Show();

    f = frame.SpecIcon;
    f:SetPoint("CENTER", frame, "CENTER", 22, -13);
    f:SetSize(14, 14);
    f:Show();

    local specBorder = frame.TexturePool:Acquire();
    specBorder:SetDrawLayer("ARTWORK", 3);
    specBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
    specBorder:SetSize(38, 38);
    specBorder:SetPoint("CENTER", f, "CENTER", 7.5, -8);
    specBorder:Show();

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 4);
    f:SetSize(66, 12);

    f = frame.CastBar;
    f:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    frame.parent:UpdateCastBarSettings(frame, self.db.castBar);

    frame.parent:UpdateDRSettings(frame, self.db.dr);

    f = frame.TrinketIcon;
    f:SetSize(20, 20);
    updateTrinketPositioning(frame);

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", frame.HealthBar, "CENTER");
    f:SetSize(26, 26);

    frame.AuraText:SetFontObject("SystemFont_Shadow_Med1_Outline");
    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.ClassIcon);

    frame.HealthText:SetPoint("CENTER", frame.HealthBar);
    frame.HealthText:SetShadowOffset(0, 0);

    frame.PowerText:SetPoint("CENTER", frame.PowerBar);
    frame.PowerText:SetShadowOffset(0, 0);

    local underlay = frame.TexturePool:Acquire();
    underlay:SetDrawLayer("BACKGROUND", 1);
    underlay:SetColorTexture(0, 0, 0, 0.5);
    underlay:SetPoint("TOPLEFT", healthBar);
    underlay:SetPoint("BOTTOMRIGHT", powerBar);
    underlay:Show();

    local frameTexture = frame.TexturePool:Acquire();
    frameTexture:SetDrawLayer("ARTWORK", 1);
    frameTexture:SetAllPoints(frame);
    frameTexture:SetTexture("Interface\\ArenaEnemyFrame\\UI-ArenaTargetingFrame");
    frameTexture:SetTexCoord(0, 0.796, 0, 0.5);
    frameTexture:Show();
end

sArenaMixin.layouts[layoutName] = layout;
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings;
