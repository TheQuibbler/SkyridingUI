local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

--------------------------------------------------
-- Skyward Ascent Settings
--------------------------------------------------
function SkyridingUI:SkywardAscentSettings()
    return {
        type = "group",
        name = "Skyward Ascent Bar",
        inline = true,
        order = 4,
        args = {
            enableSkywardAscent = {
                type = "toggle",
                name = "Enable",
                desc = "Enable or disable the Skyward Ascent progress bar",
                order = 1,
                width = 0.65,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.enableSkywardAscent = value
                    SkyridingUI:UpdateModules()
                end,
            },
            widthSkywardAscent = {
                type = "range",
                name = "Width",
                desc = "Skyward Ascent bar width in pixels",
                order = 2,
                width = 1,
                min = 100,
                max = 300,
                step = 1,
                hidden = function()
                    return SkyridingUI.db.profile.modules.optional.useSharedSizeProgressBar
                        or not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.widthSkywardAscent
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.widthSkywardAscent = value
                    SkyridingUI:UpdateModules()
                end,
            },
            heightSkywardAscent = {
                type = "range",
                name = "Height",
                desc = "Skyward Ascent bar height in pixels",
                order = 3,
                width = 1,
                min = 15,
                max = 50,
                step = 1,
                hidden = function()
                    return SkyridingUI.db.profile.modules.optional.useSharedSizeProgressBar
                        or not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.heightSkywardAscent
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.heightSkywardAscent = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space1 = {
                type = "description",
                name = "",
                order = 3.5,
                width = 0.25,
            },
            colorSkywardAscent = {
                type = "color",
                name = "Bar Color",
                desc = "Color of the Skyward Ascent progress bar",
                order = 4,
                width = 0.8,
                hasAlpha = true,
                hidden = function()
                    return not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    local c = SkyridingUI.db.profile.modules.optional.colorSkywardAscent
                    return c.r, c.g, c.b, c.a
                end,
                set = function(_, r, g, b, a)
                    SkyridingUI.db.profile.modules.optional.colorSkywardAscent = { r = r, g = g, b = b, a = a }
                    SkyridingUI:UpdateModules()
                end,
            },
            colorBorderSkywardAscent = {
                type = "color",
                name = "Border Color",
                desc = "Color of the border of the Skyward Ascent bar",
                order = 5,
                width = 1,
                hasAlpha = true,
                hidden = function()
                    return SkyridingUI.db.profile.modules.optional.useSharedBorderColorProgressBar
                        or not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    local c = SkyridingUI.db.profile.modules.optional.colorBorderSkywardAscent
                    return c.r, c.g, c.b, c.a
                end,
                set = function(_, r, g, b, a)
                    SkyridingUI.db.profile.modules.optional.colorBorderSkywardAscent = { r = r, g = g, b = b, a = a }
                    SkyridingUI:UpdateModules()
                end,
            },
            space2 = {
                type = "description",
                name = "",
                order = 5.5,
                width = "full",
            },
            thrillOfTheSkiesSkywardAscent = {
                type = "toggle",
                name = "Thrill of the Skies",
                desc = "Show only when Thrill of the Skies is active",
                order = 6,
                hidden = function()
                    return not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.thrillOfTheSkiesSkywardAscent
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.thrillOfTheSkiesSkywardAscent = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space3 = {
                type = "description",
                name = "",
                order = 6.5,
                width = "full",
            },
            previewSkywardAscent = {
                type = "toggle",
                name = "Preview Animation",
                desc = "Preview the Skyward Ascent progress bar without needing the spell to be used",
                order = 7,
                hidden = function()
                    return not SkyridingUI.db.profile.modules.optional.enableSkywardAscent
                end,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.previewSkywardAscent
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.previewSkywardAscent = value
                    SkyridingUI:UpdateModules()
                end,
            },
        },
    }
end