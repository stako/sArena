local layout = {};

function layout:Initialize(frame)
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

    local f = frame.SpecIcon;
    f:SetPoint("TOPRIGHT", -2, -2);
    f:SetSize(34, 34);
    f:Show();

    f = frame.Name;
    f:SetJustifyH("RIGHT");
    f:SetPoint("BOTTOMRIGHT", hp, "TOPRIGHT", -4, 4);
    f:SetSize(77, 14);
    f:Show();

    f = frame.CastBar;
    f:SetSize(100, 16);
    f:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", -4, -3);
    f:SetStatusBarTexture("Interface\\RaidFrame\\Raid-Bar-Hp-Fill");

    f = frame.TrinketIcon;
    f:SetSize(25, 25);
    f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 4);

    frame.AuraText:Show();
    frame.AuraText:SetPoint("CENTER", frame.SpecIcon);

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

sArenaMixin.layouts["BlizzTourney"] = layout;
