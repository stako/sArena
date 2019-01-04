local layoutName = "BlizzArena";
local layout = {};
layout.name = "|cff00b4ffBlizz|r Arena"

local function updateCastBarPositioning(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];

    frame.CastBar:ClearAllPoints();
    frame.CastBar:SetPoint("CENTER", frame, "CENTER", settings.castBarPosX, settings.castBarPosY);
end

function layout:Initialize(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];
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

    local f = frame.SpecIcon;
    f:SetPoint("TOPRIGHT", -2, -2);
    f:SetSize(26, 26);
    f:Show();

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 4);
    f:SetSize(66, 12);

    f = frame.CastBar;
    f:SetWidth(settings.castBarWidth);
    f:SetScale(settings.castBarScale);
    f:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    updateCastBarPositioning(frame);

    f = frame.TrinketIcon;
    f:SetSize(20, 20);
    f:SetPoint("LEFT", frame, "RIGHT", 4, -1);

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", frame.HealthBar, "CENTER");
    f:SetSize(26, 26);

    frame.AuraText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.SpecIcon);

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

layout.defaultSettings = {
    castBarPosX = -100,
    castBarPosY = 0,
    castBarWidth = 84;
    castBarScale = 1;
};

layout.optionsTable = {
    castBar = {
        order = 1,
        name = "Cast Bars",
        type = "group",
        args = {
            positioning = {
                order = 1,
                name = "Positioning",
                type = "group",
                inline = true,
                args = {
                    horizontal = {
                        order = 1,
                        name = "Horizontal",
                        type = "range",
                        min = -500,
                        max = 500,
                        softMin = -200,
                        softMax = 200,
                        step = 0.1,
                        bigStep = 1,
                        get = function(info) return info.handler.db.profile.layoutSettings[layoutName].castBarPosX; end,
                        set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].castBarPosX = val; for i = 1, 3 do updateCastBarPositioning(info.handler["arena"..i]); end end,
                    },
                    vertical = {
                        order = 2,
                        name = "Vertical",
                        type = "range",
                        min = -500,
                        max = 500,
                        softMin = -200,
                        softMax = 200,
                        step = 0.1,
                        bigStep = 1,
                        get = function(info) return info.handler.db.profile.layoutSettings[layoutName].castBarPosY; end,
                        set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].castBarPosY = val; for i = 1, 3 do updateCastBarPositioning(info.handler["arena"..i]); end end,
                    },
                },
            },
            scale = {
                order = 2,
                name = "Scale",
                type = "range",
                min = 0.1,
                max = 5.0,
                softMin = 0.5,
                softMax = 3.0,
                step = 0.01,
                bigStep = 0.1,
                isPercent = true,
                get = function(info) return info.handler.db.profile.layoutSettings[layoutName].castBarScale; end,
                set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].castBarScale = val; for i = 1, 3 do info.handler["arena"..i].CastBar:SetScale(val); end end,
            },
            width = {
                order = 3,
                name = "Width",
                type = "range",
                min = 10,
                max = 400,
                step = 1,
                get = function(info) return info.handler.db.profile.layoutSettings[layoutName].castBarWidth; end,
                set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].castBarWidth = val; for i = 1, 3 do info.handler["arena"..i].CastBar:SetWidth(val); end end,
            },
        },
    },
};

sArenaMixin.layouts[layoutName] = layout;
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings;
