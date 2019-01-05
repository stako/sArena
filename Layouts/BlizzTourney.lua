local layoutName = "BlizzTourney";
local layout = {};
layout.name = "|cff00b4ffBlizz|r Tourney"

local function updateCastBarPositioning(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];

    frame.CastBar:ClearAllPoints();
    frame.CastBar:SetPoint("CENTER", frame, "CENTER", settings.castBarPosX, settings.castBarPosY);
end

function layout:Initialize(frame)
    local settings = frame.parent.db.profile.layoutSettings[layoutName];
    frame.parent.portraitClassIcon = true;
    frame.parent.portraitSpecIcon = true;

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
    specBorder:SetVertexColor(0.8, 0.8, 0.8, 1);
    specBorder:SetSize(38, 38);
    specBorder:SetPoint("CENTER", f, "CENTER", 7.5, -8);
    specBorder:Show();

    f = frame.Name;
    f:SetJustifyH("RIGHT");
    f:SetPoint("BOTTOMRIGHT", hp, "TOPRIGHT", -4, 4);
    f:SetSize(77, 14);

    f = frame.CastBar;
    f:SetWidth(settings.castBarWidth);
    f:SetScale(settings.castBarScale);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    updateCastBarPositioning(frame);

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

layout.defaultSettings = {
    castBarPosX = -110,
    castBarPosY = -10,
    castBarWidth = 90;
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
