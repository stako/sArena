local layout = {};
layout.name = "BlizzArena";

function layout:Initialize(frame)
        frame:SetSize(102, 32);

        local healthBar = frame.HealthBar;
        healthBar:SetSize(69, 7);
        healthBar:SetPoint("TOPLEFT", 3, -9);
        healthBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

        local powerBar = frame.PowerBar;
        powerBar:SetSize(69, 7);
        powerBar:SetPoint("TOPLEFT", healthBar, "BOTTOMLEFT", 0, -1);
        powerBar:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill");

        local t = frame.FrameUnderlay;
        t:SetColorTexture(0, 0, 0, 0.5);
        t:SetPoint("TOPLEFT", healthBar);
        t:SetPoint("BOTTOMRIGHT", powerBar);
        t:Show();

        t = frame.FrameTexture;
        t:SetAllPoints(frame);
        t:SetTexture("Interface\\ArenaEnemyFrame\\UI-ArenaTargetingFrame");
        t:SetTexCoord(0, 0.796, 0, 0.5);
        t:Show();

        t = frame.SpecIcon;
        t:SetPoint("TOPRIGHT", -2, -2);
        t:SetSize(26, 26);
        t:Show();

        t = frame.Name;
        t:SetJustifyH("LEFT");
        t:SetFontObject("GameFontNormalSmall");
        t:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 4);
        t:SetSize(66, 12);

        t = frame.CastBar;
        t:SetSize(80, 14);
        t:SetPoint("RIGHT", frame, "LEFT", -15, -1);
        t:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");

        t = frame.TrinketIcon;
        t:SetSize(20, 20);
        t:SetPoint("LEFT", frame, "RIGHT", 4, -1);
end

tinsert(sArenaMixin.layouts, layout);