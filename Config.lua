local function getLayoutTable()
    local t = {};

    for k, v in pairs(sArenaMixin.layouts) do
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
            func = function(info) info.handler:Test() end,
            width = "half",
        },
        globalSettingsGroup = {
            name = "Global Settings",
            type = "group",
            childGroups = "tree",
            args = {
                framesGroup = {
                    order = 1,
                    name = "Arena Frames",
                    type = "group",
                    args = {
                        framePositioning = {
                            order = 1,
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
                        scale = {
                            name = "Scale",
                            type = "range",
                            order = 2,
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
                        frameSpacing = {
                            name = "Spacing",
                            desc = "Spacing between each arena frame",
                            type = "range",
                            order = 3,
                            min = 0,
                            max = 100,
                            step = 1,
                            get = function(info) return info.handler.db.profile.frameSpacing end,
                            set = function(info, val) info.handler.db.profile.frameSpacing = val; info.handler:UpdatePositioning() end,
                        },
                    },
                },
                drGroup = {
                    order = 2,
                    name = "Diminishing Returns",
                    type = "group",
                    args = {
                        drPositioning = {
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
                        size = {
                            order = 2,
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
                            order = 3,
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
                        spacing = {
                            order = 4,
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
        layoutSettingsGroup = {
            name = "Layout Settings",
            type = "group",
            args = {},
        },
    },
};