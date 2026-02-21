-- Get the main addon object from AceAddon-3.0
local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

--------------------------------------------------
-- Options Table
--------------------------------------------------
-- Define the options table for AceConfig
local OptionsTable = {
    type = "group",
    name = "Skyriding UI",
    args = {
        --------------------------------------------------
        -- UI Placement
        --------------------------------------------------
        general = {
            type = "group",
            name = "UI Placement",
            inline = true,
            order = 1,
            args = {

                -- Only Vigor UI toggle (disable all other modules)
                onlyVigorUI = {
                    type = "toggle",
                    name = "Only Vigor UI",
                    desc = "Disable all addon modules except the Vigor UI (keeps vigor and vigor decor visible if enabled).",
                    order = 0,
                    width = "full",
                    get = function()
                        return SkyridingUI.db.profile.onlyVigorUI
                    end,
                    set = function(_, value)
                        SkyridingUI.db.profile.onlyVigorUI = value
                        SkyridingUI:UpdateModules()
                    end,
                },
                space1 = {
                    type = "description",
                    name = "",
                    order = 0.5,
                    width = "full",
                },

                -- Scale slider for UI
                scale = {
                    type = "range",
                    name = "Scale",
                    desc = "Adjust the overall scale of the UI",
                    order = 1,
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
                    order = 2,
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
                    order = 3,
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
                space2 = {
                    type = "description",
                    name = "",
                    order = 3.5,
                    width = "full",
                },
                updateRate = {
                    type = "range",
                    name = "Updates per Second",
                    desc = "Select how many times per second the animations update.",
                    order = 4,
                    width = 1,
                    min = 1,
                    max = math.max(60, tonumber(GetCVar("targetFPS")) or 60), -- cap at player's refresh rate
                    step = 1,
                    get = function()
                        return SkyridingUI.db.profile.updatesPerSecond
                    end,
                    set = function(_, value)
                        SkyridingUI.db.profile.updatesPerSecond = value
                    end,
                },
                space3 = {
                    type = "description",
                    name = "",
                    order = 4.5,
                    width = 0.2,
                },
                hideWhenGrounded = {
                    type = "toggle",
                    name = "Hide When Not Gliding",
                    desc = "Automatically hide all UI elements when not gliding (e.g. on the ground or in combat).",
                    order = 5,
                    width = 1,
                    get = function()
                        return SkyridingUI.db.profile.hideWhenGrounded
                    end,
                    set = function(_, value)
                        SkyridingUI.db.profile.hideWhenGrounded = value
                        SkyridingUI:UpdateModules()
                    end,
                },
            },
        },
        
        --------------------------------------------------
        -- Vigor & Second Wind grouped
        --------------------------------------------------
        vigorAndSecondWindGroup = {
            type = "group",
            name = "Vigor & Second Wind",
            inline = false,
            order = 2,
            args = {
                vigorGroup = {
                    type = "group",
                    name = "Vigor",
                    inline = true,
                    order = 1,
                    args = {
                        vigor = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Vigor module",
                            order = 1,
                            width = 0.6,
                            get = function()
                                return SkyridingUI.db.profile.modules.vigor.enableVigor
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.vigor.enableVigor = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        showDecor = {
                            type = "toggle",
                            name = "Show Decor",
                            desc = "Show or hide the left and right decor textures",
                            order = 2,
                            width = 0.6,
                            get = function()
                                return SkyridingUI.db.profile.modules.vigor.showVigorDecor
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.vigor.showVigorDecor = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },
                secondWindGroup = {
                    type = "group",
                    name = "Second Wind",
                    inline = true,
                    order = 2,
                    args = {
                        enableSecondWind = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Second Wind module",
                            width = 0.6,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableSecondWind
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableSecondWind = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },
            },
        },

        --------------------------------------------------
        -- Progress Bars
        --------------------------------------------------
        progressBarsGroup = {
            type = "group",
            name = "Speed Bar, Skyward Ascent & Whirling Surge",
            inline = false,
            order = 3,
            args = {
                speedBarGroup = {
                    type = "group",
                    name = "Speed Bar",
                    inline = true,
                    order = 1,
                    args = {
                        enableSpeedBar = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Speed Bar module",
                            order = 1,
                            width = 0.65,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        widthSpeedBar = {
                            type = "range",
                            name = "Width",
                            desc = "Speed bar width in pixels",
                            order = 2,
                            width = 1,
                            min = 100,
                            max = 280,
                            step = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.widthSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.widthSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        heightSpeedBar = {
                            type = "range",
                            name = "Height",
                            desc = "Speed bar height in pixels",
                            order = 3,
                            width = 1,
                            min = 20,
                            max = 50,
                            step = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.heightSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.heightSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space1 = {
                            type = "description",
                            name = "",
                            order = 3.5,
                            width = 0.25,
                        },
                        colorSpeedBar = {
                            type = "color",
                            name = "Bar Color",
                            desc = "Color of the filled portion of the speed bar",
                            order = 4,
                            width = 1,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.colorSpeedBar
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.colorSpeedBar = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space2 = {
                            type = "description",
                            name = "",
                            order = 4.5,
                            width = "full",
                        },
                        previewSpeedBar = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the speed bar with sample data to see how your settings look",
                            order = 5,
                            width = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.previewSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.previewSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space3 = {
                            type = "description",
                            name = "",
                            order = 5.5,
                            width = "full",
                        },
                        enableTextSpeedBar = {
                            type = "toggle",
                            name = "Show Text",
                            desc = "Show numeric speed on the bar",
                            order = 6,
                            width = 0.8, 
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableTextSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableTextSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        textLocationSpeedBar = {
                            type = "select",
                            name = "Text Location",
                            desc = "Choose the location of the speed text on the bar",
                            order = 7,
                            width = 0.8,
                            values = {
                                left = "Left",
                                center = "Center",
                                right = "Right",
                            },
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.textLocationSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.textLocationSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space4 = {
                            type = "description",
                            name = "",
                            order = 7.5,
                            width = 0.3,
                        },
                        textColorSpeedBar = {
                            type = "color",
                            name = "Text Color",
                            desc = "Color of the speed text on the bar",
                            order = 8,
                            width = 1,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.textColorSpeedBar
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.textColorSpeedBar = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space6 = {
                            type = "description",
                            name = "",
                            order = 8.5,
                            width = "full",
                        },
                        enableUnitSpeedBar = {
                            type = "toggle",
                            name = "Show Unit",
                            desc = "Show unit (%, yd/s, or m/s) with the speed text on the bar",
                            order = 9,
                            width = 0.8, 
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableUnitSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableUnitSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        unitSpeedBar = {
                            type = "select",
                            name = "Display Units",
                            desc = "Choose units to display on the speed text",
                            order = 10,
                            width = 0.8,
                            values = {
                                percent = "Percent",
                                yds = "yd/s",
                                ms = "m/s",
                            },
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.unitSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.unitSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space7 = {
                            type = "description",
                            name = "",
                            order = 10.5,
                            width = "full",
                        },
                        thrillMarkerSpeedBar = {
                            type = "toggle",
                            name = "Show Thrill Marker",
                            desc = "Show marker on bar when Thrill of the Skies is active",
                            order = 11,
                            width = 1.02,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.thrillMarkerSpeedBar
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.thrillMarkerSpeedBar = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        thrillMarkerColorSpeedBar = {
                            type = "color",
                            name = "Thrill Marker Color",
                            desc = "Color of the thrill of the skies speed marker on the speed bar",
                            order = 12,
                            width = 1,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.thrillMarkerColorSpeedBar
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.thrillMarkerColorSpeedBar = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        
                    },
                },
                whirlingSurgeGroup = {
                    type = "group",
                    name = "Whirling Surge",
                    inline = true,
                    order = 2,
                    args = {
                        enableWhirlingSurge = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Whirling Surge progress bar",
                            order = 1,
                            width = 0.65,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableWhirlingSurge
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableWhirlingSurge = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        widthWhirlingSurge = {
                            type = "range",
                            name = "Width",
                            desc = "Whirling Surge bar width in pixels",
                            order = 2,
                            width = 1,
                            min = 100,
                            max = 280,
                            step = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.widthWhirlingSurge
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.widthWhirlingSurge = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        heightWhirlingSurge = {
                            type = "range",
                            name = "Height",
                            desc = "Whirling Surge bar height in pixels",
                            order = 3,
                            width = 1,
                            min = 15,
                            max = 50,
                            step = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.heightWhirlingSurge
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.heightWhirlingSurge = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space1 = {                  
                            type = "description",
                            name = "",
                            order = 3.5,
                            width = 0.25,
                        },  
                        colorWhirlingSurge = {
                            type = "color",
                            name = "Bar Color",
                            desc = "Color of the Whirling Surge progress bar",
                            order = 4,
                            width = 1,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.colorWhirlingSurge
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.colorWhirlingSurge = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space2 = {
                            type = "description",
                            name = "",
                            order = 4.5,
                            width = "full",
                        },
                        previewWhirlingSurge = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the Whirling Surge progress bar without needing the spell to be used",
                            order = 5,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.previewWhirlingSurge
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.previewWhirlingSurge = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },
                skywardAscentGroup = {
                    type = "group",
                    name = "Skyward Ascent",
                    inline = true,
                    order = 6,
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
                            max = 280,
                            step = 1,
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
                            width = 1,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.colorSkywardAscent
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.colorSkywardAscent = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space2 = {
                            type = "description",
                            name = "",
                            order = 4.5,
                            width = "full",
                        },
                        previewSkywardAscent = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the Skyward Ascent progress bar without needing the spell to be used",
                            order = 5,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.previewSkywardAscent
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.previewSkywardAscent = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },
            },
        },

        --------------------------------------------------
        -- Thrill & Ground Skimming Combined Group
        --------------------------------------------------
        thrillAndSkimmingGroup = {
            type = "group",
            name = "Thrill of the Skies & Ground Skimming",
            inline = false,
            order = 4,
            args = {
                --------------------------------------------------
                -- Common Settings
                --------------------------------------------------
                commonSettings = {
                    type = "group",
                    name = "Common Settings",
                    inline = true,
                    order = 1,
                    args = {
                        pulseType = {
                            type = "select",
                            name = "Pulse Type",
                            desc = "Choose the animation type for Thrill of the Skies: Movement, Scale, or Alpha.",
                            order = 1,
                            width = 0.8,
                            values = {
                                none   = "None",
                                movement = "Movement",
                                scale    = "Scale",
                                alpha    = "Alpha",
                            },
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.pulseType
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.pulseType = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space1 = {
                            type = "description",
                            name = "",
                            order = 1.5,
                            width = 0.2,
                        },
                        pulseSpeed = {
                            type = "range",
                            name = "Pulse Speed",
                            desc = "Adjust the pulse speed for both modules",
                            order = 2,
                            min = 0,
                            max = 10,
                            step = 0.1,
                            get = function()
                                -- You can default to ThrillOfTheSkies value or store a separate common value
                                return SkyridingUI.db.profile.modules.optional.pulseSpeed or 6
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.pulseSpeed = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        movementAmplitude = {
                            type = "range",
                            name = "Movement Amplitude",
                            desc = "How far the frame moves during the pulse animation (0 = no movement, 5 = maximum movement).",
                            order = 3,
                            min = 0,
                            max = 5,
                            step = 1,
                            hidden = function()
                                return SkyridingUI.db.profile.modules.optional.pulseType ~= "movement"
                            end,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.movementAmplitude
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.movementAmplitude = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        scaleMultiplier = {
                            type = "range",
                            name = "Scale Increase",
                            desc = "How much larger the frame becomes during the pulse animation (1 = no change, 1.5 = 50% larger).",
                            order = 4,
                            min = 1.0,
                            max = 1.5,
                            step = 0.05,
                            hidden = function()
                                return SkyridingUI.db.profile.modules.optional.pulseType ~= "scale"
                            end,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.scaleMultiplier
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.scaleMultiplier = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        alphaReduction = {
                            type = "range",
                            name = "Alpha Reduction",
                            desc = "How much the frame fades during the pulse animation (0 = fully transparent, 1 = no fade).",
                            order = 5,
                            min = 0,
                            max = 1,
                            step = 0.05,
                            hidden = function()
                                return SkyridingUI.db.profile.modules.optional.pulseType ~= "alpha"
                            end,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.alphaReduction
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.alphaReduction = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space2 = {
                            type = "description",
                            name = "",
                            order = 5.5,
                            width = "full",
                        },
                        preview = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the pulse animation on both modules without needing the buffs",
                            order = 6,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.preview
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.preview = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },

                --------------------------------------------------
                -- Thrill of the Skies Subgroup
                --------------------------------------------------
                thrillGroup = {
                    type = "group",
                    name = "Thrill of the Skies",
                    inline = true,
                    order = 2,
                    args = {
                        enableThrillOfTheSkies = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Thrill of the Skies module",
                            order = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableThrillOfTheSkies
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableThrillOfTheSkies = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        colorThrillOfTheSkies = {
                            type = "color",
                            name = "Texture Color",
                            desc = "Change the color of the Thrill of the Skies textures",
                            order = 2,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.colorThrillOfTheSkies
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.colorThrillOfTheSkies = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space1 = {
                            type = "description",
                            name = "",
                            order = 2.5,
                            width = "full",
                        },
                        previewThrillOfTheSkies = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the Thrill of the Skies textures and animation without needing the buff",
                            order = 3,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.previewThrillOfTheSkies
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.previewThrillOfTheSkies = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },

                --------------------------------------------------
                -- Ground Skimming Subgroup
                --------------------------------------------------
                groundSkimmingGroup = {
                    type = "group",
                    name = "Ground Skimming",
                    inline = true,
                    order = 3,
                    args = {
                        enableGroundSkimming = {
                            type = "toggle",
                            name = "Enable",
                            desc = "Enable or disable the Ground Skimming module",
                            order = 1,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.enableGroundSkimming
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.enableGroundSkimming = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        colorGroundSkimming = {
                            type = "color",
                            name = "Texture Color",
                            desc = "Change the color of the Ground Skimming textures",
                            order = 2,
                            hasAlpha = true,
                            get = function()
                                local c = SkyridingUI.db.profile.modules.optional.colorGroundSkimming
                                return c.r, c.g, c.b, c.a
                            end,
                            set = function(_, r, g, b, a)
                                SkyridingUI.db.profile.modules.optional.colorGroundSkimming = { r = r, g = g, b = b, a = a }
                                SkyridingUI:UpdateModules()
                            end,
                        },
                        space1 = {
                            type = "description",
                            name = "",
                            order = 2.5,
                            width = "full",
                        },
                        previewGroundSkimming = {
                            type = "toggle",
                            name = "Preview Animation",
                            desc = "Preview the Ground Skimming textures and animation without needing the buff",
                            order = 3,
                            get = function()
                                return SkyridingUI.db.profile.modules.optional.previewGroundSkimming
                            end,
                            set = function(_, value)
                                SkyridingUI.db.profile.modules.optional.previewGroundSkimming = value
                                SkyridingUI:UpdateModules()
                            end,
                        },
                    },
                },
            },
        },

        --------------------------------------------------
        -- Debug
        --------------------------------------------------
        -- debug = {
        --     type = "toggle",
        --     name = "Enable Debug",
        --     order = 99,
        --     get = function()
        --         -- Get current debug state from profile
        --         return SkyridingUI.db.profile.debug
        --     end,
        --     set = function(_, value)
        --         -- Set debug state and print status
        --         SkyridingUI.db.profile.debug = value
        --         print("SkyridingUI Debug: " .. (value and "Enabled" or "Disabled"))
        --     end,
        -- },
    },
}

--------------------------------------------------
-- Register Options
--------------------------------------------------
-- Register the options table with AceConfig and add it to the Blizzard options UI
LibStub("AceConfig-3.0"):RegisterOptionsTable("Skyriding UI Full", OptionsTable)
