local _, SkyridingUI_namespace = ...

-- Default profile values shared across the addon
SkyridingUI_namespace.DefaultProfile = {
    profile = {
        onlyVigorUI = false,
        posX = 0,
        posY = 0,
        scale = 1,
        draggable = false,
        updatesPerSecond = 30,
        hideWhenGrounded = false,
        debug = false,
        modules = {
            vigor = {
                enableVigor = true,
                colorVigor = { r = 1, g = 1, b = 1, a = 1 },
                colorBorderVigor = { r = 1, g = 1, b = 1, a = 1 },
                showVigorDecor = true,
                colorVigorDecor = { r = 1, g = 1, b = 1, a = 1 },
            },
            optional = {
                -- Second Wind settings
                enableSecondWind = true,
                colorSecondWind = { r = 1, g = 1, b = 1, a = 1 },
                colorBorderSecondWind = { r = 1, g = 1, b = 1, a = 1 },
                frameStyleSecondWind = "dark", -- Options: "gold", "dark", "silver", "bronze"

                -- Shared progress bar settings
                useSharedSizeProgressBar = false,
                sharedWidthProgressBar = 240,
                sharedHeightProgressBar = 20,
                useSharedBorderColorProgressBar = false,
                sharedBorderColorProgressBar = { r = 1, g = 0.82, b = 0, a = 1 },

                -- Speed Bar settings
                enableSpeedBar = true,
                widthSpeedBar = 240,
                heightSpeedBar = 20,
                colorSpeedBar = { r = 0, g = 1, b = 0, a = 1 },
                colorBorderSpeedBar = { r = 1, g = 0.82, b = 0, a = 1 },
                previewSpeedBar = false,
                enableTextSpeedBar = true,
                enableUnitSpeedBar = true,
                textLocationSpeedBar = "center", -- Options: "center", "left", "right"
                unitSpeedBar = "percent", -- Options: "percent", "yds", "ms"
                textColorSpeedBar = { r = 1, g = 1, b = 1, a = 1 },
                thrillMarkerSpeedBar = false,
                thrillMarkerColorSpeedBar = { r = 1, g = 0.82, b = 0, a = 1 },

                -- Whirling Surge progress bar
                enableWhirlingSurge = true,
                widthWhirlingSurge = 240,
                heightWhirlingSurge = 15,
                colorWhirlingSurge = { r = 0, g = 0.6, b = 1, a = 1 },
                colorBorderWhirlingSurge = { r = 1, g = 0.82, b = 0, a = 1 },
                previewWhirlingSurge = false,

                -- Skyward Ascent progress bar
                enableSkywardAscent = true,
                widthSkywardAscent = 240,
                heightSkywardAscent = 15,
                colorSkywardAscent = { r = 1, g = 0, b = 0, a = 1 },
                colorBorderSkywardAscent = { r = 1, g = 0.82, b = 0, a = 1 },
                thrillOfTheSkiesSkywardAscent = false,
                previewSkywardAscent = false,

                -- Shared Thrill of the Skies and Ground Skimming settings
                pulseType = "alpha", -- Options: "none", "movement", "scale", "alpha"
                pulseSpeed = 6,
                preview = false,
                movementAmplitude = 3,
                scaleMultiplier = 1.2,
                alphaReduction = 0.5,

                -- Thrill of the Skies settings
                enableThrillOfTheSkies = true,
                colorThrillOfTheSkies = { r = 1, g = 1, b = 1, a = 1 },
                previewThrillOfTheSkies = false,

                -- Ground Skimming settings
                enableGroundSkimming = true,
                colorGroundSkimming = { r = 1, g = 0.85, b = 0, a = 1 },
                previewGroundSkimming = false,
            },
        },
    },
}
