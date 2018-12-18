local layout = {};
layout.name = "Xaryu";

function layout:Initialize(frame)
    sArena.portraitSpecIcon = false;

    local height = 36;

    frame:SetSize(170, height);

    local t = frame.SpecIcon;
    t:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0);
    t:SetSize(height, height);
    t:Show();

    t = frame.TrinketIcon;
    t:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0);
    t:SetSize(height, height);

    t = frame.Name;
    t:SetJustifyH("LEFT");
    t:SetFontObject("GameFontNormalSmall");
    t:SetPoint("BOTTOMLEFT", frame.HealthBar, "TOPLEFT", 0, 2);
    t:SetPoint("BOTTOMRIGHT", frame.HealthBar, "TOPRIGHT", 0, 2);
    t:SetHeight(12);

    t = frame.HealthBar;
    t:SetPoint("TOPLEFT", frame.SpecIcon, "TOPRIGHT", 2, 0);
    t:SetPoint("TOPRIGHT", frame.TrinketIcon, "TOPLEFT", -2, 0);
    t:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    t:SetHeight(28);

    t = frame.PowerBar;
    t:SetPoint("TOPLEFT", frame.HealthBar, "BOTTOMLEFT", 0, 0);
    t:SetPoint("TOPRIGHT", frame.HealthBar, "BOTTOMRIGHT", 0, 0);
    t:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0);
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

    t = frame.CCIcon;
    t:SetSize(32, 32);
    t:SetPoint("CENTER", frame, "CENTER", 0, 0);

    t = frame.CCIconGlow;
    t:SetSize(66, 66);
    t:SetPoint("TOPLEFT", frame.CCIcon, "TOPLEFT", -6, 6);

    t = frame.CCText;
    t:SetPoint("CENTER", frame.CCIcon, "CENTER");
end

tinsert(sArenaMixin.layouts, layout);
