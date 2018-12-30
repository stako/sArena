local layout = {};
layout.name = "Xaryu";

function layout:Initialize(frame)
    frame.parent.portraitSpecIcon = false;

    local height = 32;

    frame:SetSize(160, height);

    local f = frame.SpecIcon;
    f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    f:SetSize(height, height);
    f:Show();

    f = frame.TrinketIcon;
    f:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
    f:SetSize(height, height);

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
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    f:SetHeight(25);

    f = frame.PowerBar;
    f:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, 0);
    f:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, 0);
    f:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

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

tinsert(sArenaMixin.layouts, layout);
