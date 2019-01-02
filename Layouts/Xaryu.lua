local layoutName = "Xaryu";
local layout = {};

function layout:Initialize(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];
    frame.parent.portraitSpecIcon = false;

    frame:SetSize(settings.width, settings.height);

    local f = frame.SpecIcon;
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    f:SetSize(settings.height, settings.height);
    f:Show();

    f = frame.TrinketIcon;
    f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
    f:SetSize(settings.height, settings.height);

    f = frame.Name;
    f:SetJustifyH("LEFT");
    f:SetJustifyV("BOTTOM");
    f:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2);
    f:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 2);
    f:SetHeight(12);
    f:Show();

    f = frame.HealthBar;
    f:SetPoint("TOPLEFT", frame.SpecIcon, "TOPRIGHT", 2, 0);
    f:SetPoint("TOPRIGHT", frame.TrinketIcon, "TOPLEFT", -2, 0);
    f:SetPoint("BOTTOM", frame.PowerBar, "TOP");
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.PowerBar;
    f:SetPoint("BOTTOMLEFT", frame.SpecIcon, "BOTTOMRIGHT", 2, 0);
    f:SetPoint("BOTTOMRIGHT", frame.TrinketIcon, "BOTTOMLEFT", -2, 0);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    f:SetHeight(settings.powerBarHeight);

    f = frame.CastBar;
    f:SetSize(90, 16);
    f:SetPoint("RIGHT", frame, "LEFT", -4, 0);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.SpecIcon);

    local underlay = frame.TexturePool:Acquire();
    underlay:SetDrawLayer("BACKGROUND", 1);
    underlay:SetColorTexture(0, 0, 0, 0.75);
    underlay:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT");
    underlay:SetPoint("BOTTOMRIGHT", frame.PowerBar, "BOTTOMRIGHT");
    underlay:Show();
end

local function setFrameHeight(frame, val)
    frame:SetHeight(val);

    frame.SpecIcon:SetSize(val, val);
    frame.TrinketIcon:SetSize(val, val);
end

layout.defaultSettings = {
    width = 160,
    height = 32,
    powerBarHeight = 10,
};

layout.optionsTable = {
    width = {
        order = 1,
        name = "Width",
        type = "range",
        min = 40,
        max = 400,
        step = 1,
        get = function(info) return info.handler.db.profile.layoutSettings[layoutName].width; end,
        set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].width = val; for i = 1, 3 do info.handler["arena"..i]:SetWidth(val); end end,
    },
    height = {
        order = 2,
        name = "Height",
        type = "range",
        min = 2,
        max = 100,
        step = 1,
        get = function(info) return info.handler.db.profile.layoutSettings[layoutName].height; end,
        set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].height = val; for i = 1, 3 do setFrameHeight(info.handler["arena"..i], val); end end,
    },
    powerBarHeight = {
        order = 2,
        name = "Power Bar Height",
        type = "range",
        min = 1,
        max = 50,
        step = 1,
        get = function(info) return info.handler.db.profile.layoutSettings[layoutName].powerBarHeight; end,
        set = function(info, val) info.handler.db.profile.layoutSettings[layoutName].powerBarHeight = val; for i = 1, 3 do info.handler["arena"..i].PowerBar:SetHeight(val); end end,
    },
};

sArenaMixin.layouts[layoutName] = layout;
sArenaMixin.defaultSettings.profile.layoutSettings[layoutName] = layout.defaultSettings;
