local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

-------------------------------------------------
-- Global UI Settings
--------------------------------------------------
function SkyridingUI:GlobalUISettings()
    return {
        type = "group",
        name = "Global UI Settings",
        inline = true,
        order = 1,
        args = {
            -- Only Vigor UI toggle (disable all other modules)
            onlyVigorUI = {
                type = "toggle",
                name = "Only Vigor UI",
                desc = "Disable all addon modules except the Vigor UI (keeps vigor and vigor decor visible if enabled).",
                order = 1,
                width = 0.9,
                get = function()
                    return SkyridingUI.db.profile.onlyVigorUI
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.onlyVigorUI = value
                    SkyridingUI:UpdateModules()
                end,
            },
            -- Preview All toggle
            previewAll = {
                type = "toggle",
                name = "Preview All Modules",
                desc = "Toggle preview mode for every module at once.",
                order = 2,
                width = 1,
                get = function()
                    return SkyridingUI.db.profile.modules.optional.preview 
                        and SkyridingUI.db.profile.modules.optional.previewProgressBars
                        and SkyridingUI.db.profile.modules.optional.previewSpeedBar
                        and SkyridingUI.db.profile.modules.optional.previewWhirlingSurge
                        and SkyridingUI.db.profile.modules.optional.previewSkywardAscent
                        and SkyridingUI.db.profile.modules.optional.previewThrillOfTheSkies
                        and SkyridingUI.db.profile.modules.optional.previewGroundSkimming
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.modules.optional.preview = value
                    SkyridingUI.db.profile.modules.optional.previewProgressBars = value
                    SkyridingUI.db.profile.modules.optional.previewSpeedBar = value
                    SkyridingUI.db.profile.modules.optional.previewWhirlingSurge = value
                    SkyridingUI.db.profile.modules.optional.previewSkywardAscent = value
                    SkyridingUI.db.profile.modules.optional.previewThrillOfTheSkies = value
                    SkyridingUI.db.profile.modules.optional.previewGroundSkimming = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space1 = {
                type = "description",
                name = "",
                order = 2.5,
                width = 0.2,
            },
            -- Draggable toggle
            draggable = {
                type = "toggle",
                name = "Drag to Move",
                desc = "Enable dragging the UI instead of only using the position sliders.",
                order = 3,
                width = 1,
                get = function()
                    return SkyridingUI.db.profile.draggable
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.draggable = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space2 = {
                type = "description",
                name = "",
                order = 3.5,
                width = "full",
            },
            -- Scale slider for UI
            scale = {
                type = "range",
                name = "Scale",
                desc = "Adjust the overall scale of the UI",
                order = 4,
                width = 1, 
                min = 0.5,
                max = 2,
                step = 0.05,
                get = function()
                    -- Get current scale from profile
                    return SkyridingUI.db.profile.scale
                end,
                set = function(_, value)
                    -- Set new scale and refresh all modules
                    SkyridingUI.db.profile.scale = value
                    SkyridingUI:UpdateModules()
                end,
            },
            -- X position slider for UI
            posX = {
                type = "range",
                name = "Position X",
                desc = "Adjust the horizontal position of the UI",
                order = 5,
                width = 1,
                min = -1000,
                max = 1000,
                step = 1,
                get = function()
                    -- Get current X position from profile
                    return SkyridingUI.db.profile.posX
                end,
                set = function(_, value)
                    -- Set new X position and refresh all modules
                    SkyridingUI.db.profile.posX = value
                    SkyridingUI:UpdateModules()
                end,
            },
            -- Y position slider for UI
            posY = {
                type = "range",
                name = "Position Y",
                desc = "Adjust the vertical position of the UI",
                order = 6,
                width = 1,
                min = -1000,
                max = 1000,
                step = 1,
                get = function()
                    -- Get current Y position from profile
                    return SkyridingUI.db.profile.posY
                end,
                set = function(_, value)
                    -- Set new Y position and refresh all modules
                    SkyridingUI.db.profile.posY = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space3 = {
                type = "description",
                name = "",
                order = 6.5,
                width = "full",
            },
            updateRate = {
                type = "range",
                name = "Updates per Second",
                desc = "Select how many times per second the animations update.",
                order = 7,
                width = 1,
                min = 5,
                max = math.max(60, tonumber(GetCVar("targetFPS")) or 60), -- cap at player's refresh rate
                step = 1,
                get = function()
                    return SkyridingUI.db.profile.updatesPerSecond
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.updatesPerSecond = value
                end,
            },
            space4 = {
                type = "description",
                name = "",
                order = 7.5,
                width = 0.2,
            },
            hideWhenGrounded = {
                type = "toggle",
                name = "Hide When Not Gliding",
                desc = "Automatically hide all UI elements when not gliding (e.g. on the ground or in combat).",
                order = 8,
                width = 1,
                get = function()
                    return SkyridingUI.db.profile.hideWhenGrounded
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.hideWhenGrounded = value
                    SkyridingUI:UpdateModules()
                end,
            },
            space5 = {
                type = "description",
                name = "",
                order = 8.5,
                width = 0.2,
            },
            minimapButton = {
                type = "toggle",
                name = "Show Minimap Button",
                desc = "Show the SkyridingUI button in the addon compartment.",
                order = 9,
                width = 1,
                get = function()
                    return SkyridingUI.db.profile.enableMinimap
                end,
                set = function(_, value)
                    SkyridingUI.db.profile.enableMinimap = value
                    SkyridingUI:UpdateModules()
                end,
            },
        },
    }
end