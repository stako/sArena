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

local growthOptions = { "Down", "Up", "Right", "Left" };
local drCategories = {
    ["Stun"] = "Stuns",
    ["Incapacitate"] = "Incapacitates",
    ["Disorient"] = "Disorients",
    ["Silence"] = "Silences",
    ["Root"] = "Roots",
};

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
        globalSettingsGroup = {
            order = 4,
            name = "Global Settings",
            type = "group",
            childGroups = "tree",
            args = {
                framesGroup = {
                    order = 1,
                    name = "Arena Frames",
                    type = "group",
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
                            get = function(info) return info.handler.db.profile.scale end,
                            set = function(info, val) info.handler.db.profile.scale = val; info.handler:SetScale(val); end,
                        },
                        framePositioning = {
                            order = 2,
                            name = "Positioning",
                            type = "group",
                            inline = true,
                            args = {
                                horizontal = {
                                    order = 1,
                                    name = "Horizontal",
                                    type = "range",
                                    min = -1000,
                                    max = 1000,
                                    step = 0.1,
                                    bigStep = 1,
                                    get = function(info) return info.handler.db.profile.posX; end,
                                    set = function(info, val) info.handler.db.profile.posX = val; info.handler:UpdatePositioning(); end,
                                },
                                vertical = {
                                    order = 1,
                                    name = "Vertical",
                                    type = "range",
                                    min = -1000,
                                    max = 1000,
                                    step = 0.1,
                                    bigStep = 1,
                                    get = function(info) return info.handler.db.profile.posY; end,
                                    set = function(info, val) info.handler.db.profile.posY = val; info.handler:UpdatePositioning(); end,
                                },
                            },
                        },
                        frameGrowth = {
                            order = 3,
                            name = "Growth",
                            type = "group",
                            inline = true,
                            args = {
                                growthDirection = {
                                    order = 1,
                                    name = "Direction",
                                    type = "select",
                                    style = "dropdown",
                                    get = function(info) return info.handler.db.profile.frameGrowthDirection end,
                                    set = function(info, val) info.handler.db.profile.frameGrowthDirection = val; info.handler:UpdatePositioning(); end,
                                    values = growthOptions,
                                },
                                frameSpacing = {
                                    order = 2,
                                    name = "Spacing",
                                    desc = "Spacing between each arena frame",
                                    type = "range",
                                    min = 0,
                                    max = 100,
                                    step = 1,
                                    get = function(info) return info.handler.db.profile.frameSpacing end,
                                    set = function(info, val) info.handler.db.profile.frameSpacing = val; info.handler:UpdatePositioning(); end,
                                },
                            },
                        },
                        classColors = {
                            order = 4,
                            name = "Use Class Colors",
                            desc = "When disabled, health bars will be green",
                            type = "toggle",
                            get = function(info) return info.handler.db.profile.classColors end,
                            set = function(info, val) info.handler.db.profile.classColors = val; end,
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
                            get = function(info, key) return info.handler.db.profile.dr.categories[key]; end,
                            set = function(info, key, val) info.handler.db.profile.dr.categories[key] = val; end,
                            values = drCategories,
                        },
                        size = {
                            order = 2,
                            name = "Size",
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
                                    get = function(info) return info.handler.db.profile.dr.size; end,
                                    set = function(info, val) for i = 1, 3 do info.handler["arena"..i]:SetDRSize(val); end end,
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
                                    get = function(info) return info.handler.db.profile.dr.borderSize; end,
                                    set = function(info, val) for i = 1, 3 do info.handler["arena"..i]:SetDRBorderSize(val); end end,
                                },
                            },
                        },
                        positioning = {
                            order = 3,
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
                                    get = function(info) return info.handler.db.profile.dr.posX; end,
                                    set = function(info, val) info.handler.db.profile.dr.posX = val; for i = 1, 3 do info.handler["arena"..i]:UpdateDRPositions(); end end,
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
                                    get = function(info) return info.handler.db.profile.dr.posY; end,
                                    set = function(info, val) info.handler.db.profile.dr.posY = val; for i = 1, 3 do info.handler["arena"..i]:UpdateDRPositions(); end end,
                                },
                            },
                        },
                        growth = {
                            order = 4,
                            name = "Growth",
                            type = "group",
                            inline = true,
                            args = {
                                growthDirection = {
                                    order = 1,
                                    name = "Direction",
                                    type = "select",
                                    style = "dropdown",
                                    get = function(info) return info.handler.db.profile.dr.growthDirection end,
                                    set = function(info, val)
                                            info.handler.db.profile.dr.growthDirection = val;
                                            for i = 1, 3 do
                                              info.handler["arena"..i]:UpdateDRPositions();
                                            end
                                          end,
                                    values = growthOptions,
                                },
                                spacing = {
                                    order = 2,
                                    name = "Spacing",
                                    type = "range",
                                    min = 0,
                                    max = 32,
                                    softMin = 0,
                                    softMax = 32,
                                    step = 1,
                                    get = function(info) return info.handler.db.profile.dr.spacing; end,
                                    set = function(info, val) info.handler.db.profile.dr.spacing = val; for i = 1, 3 do info.handler["arena"..i]:UpdateDRPositions(); end end,
                                },
                            },
                        },
                    },
                },
            },
        },
        layoutSettingsGroup = {
            order = 5,
            name = "Layout Settings",
            type = "group",
            args = {},
        },
    },
};
