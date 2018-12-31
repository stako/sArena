function sArenaMixin:GetLayout()
    return self.db.profile.currentLayout;
end

local function getLayoutTable()
    local t = {};

    for k, v in pairs(sArenaMixin.layouts) do
        t[k] = k;
    end

    return t;
end

local function setLayout(var)
    print(var);
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
            get = "GetLayout",
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
                    get = function(info) return info.handler.db.profile.scale end,
                    set = function(info, val) info.handler.db.profile.scale = val; info.handler:SetScale(val); end,
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