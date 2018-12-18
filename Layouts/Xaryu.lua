local layout = {};
layout.name = "Xaryu";

function layout:Initialize(frame)
    sArena.portraitSpecIcon = false;

    frame:SetSize(180, 40);

    local t = frame.SpecIcon;
    t:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2);
    t:SetSize(36, 36);
    t:Show();

    t = frame.TrinketIcon;
    t:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2);
    t:SetSize(36, 36);

    t = frame.Name;
    t:SetJustifyH("LEFT");
    t:SetFontObject("GameFontNormalSmall");
    t:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2);
    t:SetSize(166, 12);

    t = frame.HealthBar;
    t:SetPoint("TOPLEFT", frame.SpecIcon, "TOPRIGHT", 2, 0);
    t:SetPoint("TOPRIGHT", frame.TrinketIcon, "TOPLEFT", -2, 0);
    t:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    t:SetHeight(28);

    t = frame.PowerBar;
    t:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, 0);
    t:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, 0);
    t:SetPoint("BOTTOM", frame, "BOTTOM", 0, 2);
    t:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    t = frame.FrameUnderlay;
    t:SetColorTexture(0, 0, 0, 0.75);
    t:SetPoint("TOPLEFT", frame.HealthBar, "TOPLEFT");
    t:SetPoint("BOTTOMRIGHT", frame.PowerBar, "BOTTOMRIGHT");
    t:Show();

    t = frame.CastBar;
    t:SetSize(80, 14);
    t:SetPoint("RIGHT", frame, "LEFT", -4, 0);
    t:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
end

tinsert(sArenaMixin.layouts, layout);
