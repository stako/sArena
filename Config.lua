local function getLayoutTable()
    local t = {};

    for k, v in pairs(sArenaMixin.layouts) do
        t[k] = k;
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
            args = {
                scale = {
                    name = "Scale",
                    type = "range",
                    order = 1,
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
                drGroup = {
                    name = "Diminishing Returns",
                    type = "group",
                    inline = true,
                    order = 2,
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
                        spacing = {
                            order = 3,
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
            args = {
            },
        },
    },
};