local layoutName = "Xaryu";
local layout = {};

local function updateCastBarPositioning(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];

    frame.CastBar:ClearAllPoints();
    frame.CastBar:SetPoint("CENTER", frame, "CENTER", settings.castBarPosX, settings.castBarPosY);
end

local function getSetting(info)
    return info.handler.db.profile.layoutSettings[layoutName][info[#info]];
end

local function setSetting(info, val)
    local db = info.handler.db.profile.layoutSettings[layoutName];
    local setting = info[#info];

    db[setting] = val;
    for i = 1,3 do
        local frame = info.handler["arena"..i];
        frame:SetSize(db.width, db.height);
        frame.ClassIcon:SetSize(db.height, db.height);
        frame.TrinketIcon:SetSize(db.height, db.height);
        frame.DeathIcon:SetSize(db.height * 0.8, db.height * 0.8);
        frame.SpecIcon:SetSize(db.specIconSize, db.specIconSize);
        frame.PowerBar:SetHeight(db.powerBarHeight);
    end
end

function layout:Initialize(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];
    frame.parent.portraitClassIcon = false;
    frame.parent.portraitSpecIcon = false;

    frame:SetSize(settings.width, settings.height);

    local f = frame.ClassIcon;
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    f:SetSize(settings.height, settings.height);
    f:Show();

    f = frame.TrinketIcon;
    f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
    f:SetSize(settings.height, settings.height);

    local f = frame.SpecIcon;
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "BOTTOMLEFT");
    f:SetSize(settings.specIconSize, settings.specIconSize);
    f:Show();

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetJustifyV("BOTTOM");
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2);
    f:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 2);
    f:SetHeight(12);

    f = frame.HealthBar;
    f:SetPoint("TOPLEFT", frame.ClassIcon, "TOPRIGHT", 2, 0);
    f:SetPoint("TOPRIGHT", frame.TrinketIcon, "TOPLEFT", -2, 0);
    f:SetPoint("BOTTOM", frame.PowerBar, "TOP");
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.PowerBar;
    f:SetPoint("BOTTOMLEFT", frame.ClassIcon, "BOTTOMRIGHT", 2, 0);
    f:SetPoint("BOTTOMRIGHT", frame.TrinketIcon, "BOTTOMLEFT", -2, 0);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    f:SetHeight(settings.powerBarHeight);

    f = frame.CastBar;
    f:SetWidth(settings.castBarWidth);
    f:SetScale(settings.castBarScale);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    updateCastBarPositioning(frame);

    f = frame.DeathIcon;
    f:ClearAllPoints();
    f:SetPoint("CENTER", frame, "CENTER");
    f:SetSize(settings.height * 0.8, settings.height * 0.8);

    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.ClassIcon);

    frame.HealthText:SetPoint("CENTER", frame.HealthBar);
    frame.HealthText:SetShadowOffset(0, 0);

    frame.PowerText:SetPoint("CENTER", frame.PowerBar);
    frame.PowerText:SetShadowOffset(0, 0);

    local underlay = frame.TexturePool:Acquire();
    underlay:SetDrawLayer("BACKGROUND", 1);
    underlay:SetColorTexture(0, 0, 0, 0.75);
    underlay:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT");
    underlay:SetPoint("BOTTOMRIGHT", frame.PowerBar, "BOTTOMRIGHT");
    underlay:Show();
end

local function setFrameHeight(frame, val)
    frame:SetHeight(val);

    frame.ClassIcon:SetSize(val, val);
    frame.TrinketIcon:SetSize(val, val);
end

layout.defaultSettings = {
    width = 160,
    height = 32,
    powerBarHeight = 8,
    castBarPosX = -4,
    castBarPosY = -24,
    castBarWidth = 84;
    castBarScale = 1.2;
    specIconSize = 12;
};

layout.optionsTable = {
    arenaFrames = {
        order = 1,
        name = "Arena Frames",
        type = "group",
        get = getSetting,
        set = setSetting,
        args = {
            width = {
                order = 1,
                name = "Width",
                type = "range",
                min = 40,
                max = 400,
                step = 1,
            },
            height = {
                order = 2,
                name = "Height",
                type = "range",
                min = 2,
                max = 100,
                step = 1,
            },
            powerBarHeight = {
                order = 2,
                name = "Power Bar Height",
                type = "range",
                min = 1,
                max = 50,
                step = 1,
            },
            specIconSize = {
                order = 2,
                name = "Spec Icon Size",
                type = "range",
                min = 2,
                max = 64,
                step = 0.1,
                bigStep = 1,
            },
        },
    },
    castBar = {
        order = 2,
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
