local function getLayoutTable()
    local t = {};

    for k, _ in pairs(sArenaMixin.layouts) do
        t[k] = sArenaMixin.layouts[k].name and sArenaMixin.layouts[k].name or k;
    end

    return t;
end

local function validateCombat()
    if ( InCombatLockdown() ) then
        return "Must leave combat first.";
    end

    return true;
end

local growthValues = { "Down", "Up", "Right", "Left" };
local drCategories = {
    ["Stun"] = "Stuns",
    ["Incapacitate"] = "Incapacitates",
    ["Disorient"] = "Disorients",
    ["Silence"] = "Silences",
    ["Root"] = "Roots",
};

function sArenaMixin:GetLayoutOptionsTable(layoutName)
    local optionsTable = {
        arenaFrames = {
            order = 1,
            name = "Arena Frames",
            type = "group",
            get = function(info) return info.handler.db.profile.layoutSettings[layoutName][info[#info]] end,
            set = function(info, val) self:UpdateFrameSettings(info.handler.db.profile.layoutSettings[layoutName], info, val) end,
            args = {
                positioning = {
                    order = 1,
                    name = "Positioning",
                    type = "group",
                    inline = true,
                    args = {
                        posX = {
                            order = 1,
                            name = "Horizontal",
                            type = "range",
                            min = -1000,
                            max = 1000,
                            step = 0.1,
                            bigStep = 1,
                        },
                        posY = {
                            order = 2,
                            name = "Vertical",
                            type = "range",
                            min = -1000,
                            max = 1000,
                            step = 0.1,
                            bigStep = 1,
                        },
                        spacing = {
                            order = 3,
                            name = "Spacing",
                            desc = "Spacing between each arena frame",
                            type = "range",
                            min = 0,
                            max = 100,
                            step = 1,
                        },
                        growthDirection = {
                            order = 4,
                            name = "Growth Direction",
                            type = "select",
                            style = "dropdown",
                            values = growthValues,
                        },
                    },
                },
                sizing = {
                    order = 2,
                    name = "Sizing",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 1,
                            name = "Scale",
                            type = "range",
                            min = 0.1,
                            max = 5.0,
                            softMin = 0.5,
                            softMax = 3.0,
                            step = 0.01,
                            bigStep = 0.1,
                            isPercent = true,
                        },
                    },
                },
                trinket = {
                    order = 4,
                    name = "Trinkets",
                    type = "group",
                    inline = true,
                    args = {
                        trinketFontSize = {
                            order = 3,
                            name = "Font Size",
                            desc = "Only works with Blizzard cooldown count (not OmniCC)",
                            type = "range",
                            min = 2,
                            max = 48,
                            softMin = 4,
                            softMax = 32,
                            step = 1,
                        },
                    },
                },
            },
        },
        castBar = {
            order = 2,
            name = "Cast Bars",
            type = "group",
            get = function(info) return info.handler.db.profile.layoutSettings[layoutName].castBar[info[#info]] end,
            set = function(info, val) self:UpdateCastBarSettings(info.handler.db.profile.layoutSettings[layoutName].castBar, info, val) end,
            args = {
                positioning = {
                    order = 1,
                    name = "Positioning",
                    type = "group",
                    inline = true,
                    args = {
                        posX = {
                            order = 1,
                            name = "Horizontal",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                        posY = {
                            order = 2,
                            name = "Vertical",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                    },
                },
                sizing = {
                    order = 2,
                    name = "Sizing",
                    type = "group",
                    inline = true,
                    args = {
                        scale = {
                            order = 1,
                            name = "Scale",
                            type = "range",
                            min = 0.1,
                            max = 5.0,
                            softMin = 0.5,
                            softMax = 3.0,
                            step = 0.01,
                            bigStep = 0.1,
                            isPercent = true,
                        },
                        width = {
                            order = 2,
                            name = "Width",
                            type = "range",
                            min = 10,
                            max = 400,
                            step = 1,
                        },
                    },
                },
            },
        },
        dr = {
            order = 3,
            name = "Diminishing Returns",
            type = "group",
            get = function(info) return info.handler.db.profile.layoutSettings[layoutName].dr[info[#info]] end,
            set = function(info, val) self:UpdateDRSettings(info.handler.db.profile.layoutSettings[layoutName].dr, info, val) end,
            args = {
                positioning = {
                    order = 1,
                    name = "Positioning",
                    type = "group",
                    inline = true,
                    args = {
                        posX = {
                            order = 1,
                            name = "Horizontal",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                        posY = {
                            order = 2,
                            name = "Vertical",
                            type = "range",
                            min = -500,
                            max = 500,
                            softMin = -200,
                            softMax = 200,
                            step = 0.1,
                            bigStep = 1,
                        },
                        spacing = {
                            order = 3,
                            name = "Spacing",
                            type = "range",
                            min = 0,
                            max = 32,
                            softMin = 0,
                            softMax = 32,
                            step = 1,
                        },
                        growthDirection = {
                            order = 4,
                            name = "Growth Direction",
                            type = "select",
                            style = "dropdown",
                            values = growthValues,
                        },
                    },
                },
                sizing = {
                    order = 2,
                    name = "Sizing",
                    type = "group",
                    inline = true,
                    args = {
                        size = {
                            order = 1,
                            name = "Size",
                            type = "range",
                            min = 2,
                            max = 128,
                            softMin = 8,
                            softMax = 64,
                            step = 1,
                        },
                        borderSize = {
                            order = 2,
                            name = "Border Size",
                            type = "range",
                            min = 0,
                            max = 24,
                            softMin = 1,
                            softMax = 16,
                            step = 0.1,
                            bigStep = 1,
                        },
                        fontSize = {
                            order = 3,
                            name = "Font Size",
                            desc = "Only works with Blizzard cooldown count (not OmniCC)",
                            type = "range",
                            min = 2,
                            max = 48,
                            softMin = 4,
                            softMax = 32,
                            step = 1,
                        },
                    },
                },
            },
        },
    };

    return optionsTable;
end

function sArenaMixin:UpdateFrameSettings(db, info, val)
    if ( val ) then
        db[info[#info]] = val;
    end

    self:ClearAllPoints();
    self:SetPoint("CENTER", UIParent, "CENTER", db.posX, db.posY);
    self:SetScale(db.scale);
    
    local growthDirection = db.growthDirection;
    local spacing = db.spacing;

    for i = 2, 3 do
        local frame = self["arena"..i];
        local prevFrame = self["arena"..i-1];

        frame:ClearAllPoints();
        if ( growthDirection == 1 ) then frame:SetPoint("TOP", prevFrame, "BOTTOM", 0, -spacing);
        elseif ( growthDirection == 2 ) then frame:SetPoint("BOTTOM", prevFrame, "TOP", 0, spacing);
        elseif ( growthDirection == 3 ) then frame:SetPoint("LEFT", prevFrame, "RIGHT", spacing, 0);
        elseif ( growthDirection == 4 ) then frame:SetPoint("RIGHT", prevFrame, "LEFT", -spacing, 0);
        end
    end

    for i = 1, 3 do
        local text = self["arena"..i].TrinketCooldown.Text;
        text:SetFont(text.fontFile, db.trinketFontSize, "OUTLINE");
    end
end

function sArenaMixin:UpdateCastBarSettings(db, info, val)
    if ( val ) then
        db[info[#info]] = val;
    end

    for i = 1, 3 do
        local frame = self["arena"..i];

        frame.CastBar:ClearAllPoints();
        frame.CastBar:SetPoint("CENTER", frame, "CENTER", db.posX, db.posY);
        frame.CastBar:SetScale(db.scale);
        frame.CastBar:SetWidth(db.width);
    end
end

function sArenaMixin:UpdateDRSettings(db, info, val)
    local drCategories = {
        "Stun",
        "Incapacitate",
        "Disorient",
        "Silence",
        "Root",
    };

    if ( val ) then
        db[info[#info]] = val;
    end

    for i = 1, 3 do
        local frame = self["arena"..i];
        frame:UpdateDRPositions();

        for n = 1, #drCategories do
            local dr = frame[drCategories[n]];

            dr:SetSize(db.size, db.size);
            dr.Border:SetPoint("TOPLEFT", dr, "TOPLEFT", -db.borderSize, db.borderSize);
            dr.Border:SetPoint("BOTTOMRIGHT", dr, "BOTTOMRIGHT", db.borderSize, -db.borderSize);

            local text = dr.Cooldown.Text;
            text:SetFont(text.fontFile, db.fontSize, "OUTLINE");
        end
    end
end

sArenaMixin.optionsTable = {
    type = "group",
    childGroups = "tab",
    validate = validateCombat,
    args = {
        setLayout = {
            order = 1,
            name = "Layout",
            type = "select",
            style = "dropdown",
            get = function(info) return info.handler.db.profile.currentLayout end,
            set = "SetLayout",
            values = getLayoutTable,
        },
        test = {
            order = 2,
            name = "Test",
            type = "execute",
            func = "Test",
            width = "half",
        },
        hide = {
            order = 3,
            name = "Hide",
            type = "execute",
            func = function(info) for i = 1, 3 do info.handler["arena"..i]:OnEvent("PLAYER_ENTERING_WORLD"); end end,
            width = "half",
        },
        dragNotice = {
            order = 4,
            name = "|cffffd100Ctrl+shift+click & drag things to move them|r",
            type = "description",
            fontSize = "medium",
            width = 1.5,
        },
        globalSettingsGroup = {
            order = 5,
            name = "Global Settings",
            desc = "These settings will apply to all layouts",
            type = "group",
            childGroups = "tree",
            args = {
                framesGroup = {
                    order = 1,
                    name = "Arena Frames",
                    type = "group",
                    args = {
                        statusText = {
                            order = 5,
                            name = "Status Text",
                            type = "group",
                            inline = true,
                            args = {
                                alwaysShow = {
                                    order = 1,
                                    name = "Always Show",
                                    desc = "If disabled, text only shows on mouseover",
                                    type = "toggle",
                                    get = function(info) return info.handler.db.profile.statusText.alwaysShow end,
                                    set = function(info, val) info.handler.db.profile.statusText.alwaysShow = val; for i = 1, 3 do info.handler["arena"..i]:UpdateStatusTextVisible(); end end,
                                },
                                usePercentage = {
                                    order = 2,
                                    name = "Use Percentage",
                                    type = "toggle",
                                    get = function(info) return info.handler.db.profile.statusText.usePercentage end,
                                    set =   function(info, val)
                                                info.handler.db.profile.statusText.usePercentage = val;

                                                local _, instanceType = IsInInstance();
                                                if ( instanceType ~= "arena" and info.handler.arena1:IsShown() ) then
                                                    info.handler:Test();
                                                end
                                            end,
                                },
                            },
                        },
                        misc = {
                            order = 6,
                            name = "Miscellaneous",
                            type = "group",
                            inline = true,
                            args = {
                                classColors = {
                                    order = 1,
                                    name = "Use Class Colors",
                                    desc = "When disabled, health bars will be green",
                                    type = "toggle",
                                    get = function(info) return info.handler.db.profile.classColors end,
                                    set = function(info, val) info.handler.db.profile.classColors = val; end,
                                },
                                showNames = {
                                    order = 2,
                                    name = "Show Names",
                                    type = "toggle",
                                    get = function(info) return info.handler.db.profile.showNames end,
                                    set = function(info, val) info.handler.db.profile.showNames = val; for i = 1, 3 do info.handler["arena"..i].Name:SetShown(val); end end,
                                },
                            },
                        },
                    },
                },
                drGroup = {
                    order = 2,
                    name = "Diminishing Returns",
                    type = "group",
                    args = {
                        categories = {
                            order = 1,
                            name = "Categories",
                            type = "multiselect",
                            get = function(info, key) return info.handler.db.profile.drCategories[key]; end,
                            set = function(info, key, val) info.handler.db.profile.drCategories[key] = val; end,
                            values = drCategories,
                        },
                    },
                },
            },
        },
        layoutSettingsGroup = {
            order = 6,
            name = "Layout Settings",
            desc = "These settings will apply only to the selected layout",
            type = "group",
            args = {},
        },
    },
};
