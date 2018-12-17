local layout = {};
layout.name = "BlizzTourney";

function layout:Initialize(frame)
    frame:SetSize(126, 66);
    
    local hp = frame.HealthBar;
    hp:SetSize(87, 23);
    hp:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -30);
    hp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    
    local pp = frame.PowerBar;
    pp:SetSize(87, 12);
    pp:SetPoint("TOPLEFT", frame, "TOPLEFT", 3, -53);
    pp:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Resource-Fill");
    
    local t = frame.FrameUnderlay;
    t:SetColorTexture(0, 0, 0, 0.75);
    t:SetPoint("TOPLEFT", hp, "TOPLEFT");
    t:SetPoint("BOTTOMRIGHT", pp, "BOTTOMRIGHT");
    t:Show();
    
    t = frame.FrameTexture;
    t:SetSize(160, 80);
    t:SetPoint("TOPLEFT", frame, "TOPLEFT", -26, 6);
    t:SetAtlas("UnitFrame");
    t:SetTexCoord(1, 0, 0, 1);
    t:Show();
    
    t = frame.SpecIcon;
    t:SetPoint("TOPRIGHT", -2, -2);
    t:SetSize(34, 34);
    t:Show();
    
    t = frame.Name;
    t:SetJustifyH("RIGHT");
    t:SetFontObject("GameFontNormalSmall");
    t:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -42, -14);
    t:SetSize(77, 12);
    
    t = frame.CastBar;
    t:SetSize(80, 14);
    t:SetPoint("RIGHT", frame, "LEFT", -15, -5);
    t:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");
    
    t = frame.TrinketIcon;
    t:SetSize(25, 25);
    t:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 4);
end

tinsert(sArenaMixin.layouts, layout);