local layout = {};
layout.name = "|cff00b4ffBlizz|r Arena"

function layout:Initialize(frame)
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
    f:Show();

    f = frame.CastBar;
    f:SetSize(80, 14);
    f:SetPoint("RIGHT", frame, "LEFT", -10, -1);
    f:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

    f = frame.TrinketIcon;
    f:SetSize(20, 20);
    f:SetPoint("LEFT", frame, "RIGHT", 4, -1);

    frame.AuraText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE");
    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.SpecIcon);

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

sArenaMixin.layouts["BlizzArena"] = layout;
