local addonName, SkyridingUI = ...

--------------------------------------------------
-- Initialize Addon with AceAddon
--------------------------------------------------
-- Create the main addon object using AceAddon-3.0 and AceConsole-3.0
SkyridingUI = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0")

--------------------------------------------------
-- Initialization
--------------------------------------------------
function SkyridingUI:OnInitialize()
    -- Set up saved variables with default profile values
    self.db = LibStub("AceDB-3.0"):New("SkyridingUI_DB", {
        profile = {
            onlyVigorUI = false,
            posX = 0,
            posY = 0,
            scale = 1,
            updatesPerSecond = 30,
            hideWhenGrounded = false,
            debug = false,
            modules = {
                vigor = {
                   enableVigor = true,
                   showVigorDecor = true,
                },
                optional = {
                    -- Second Wind settings
                    enableSecondWind = true,

                    -- Speed Bar settings
                    enableSpeedBar = true,
                    widthSpeedBar = 220,
                    heightSpeedBar = 20,
                    colorSpeedBar = {r = 0, g = 1, b = 0, a = 1},
                    previewSpeedBar = false,
                    enableTextSpeedBar = true,
                    enableUnitSpeedBar = true,
                    textLocationSpeedBar = "center",  -- Options: "center", "left", "right"
                    unitSpeedBar = "percent",  -- Options: "percent", "yds", "ms" 
                    textColorSpeedBar = {r = 1, g = 1, b = 1, a = 1},
                    thrillMarkerSpeedBar = false,
                    thrillMarkerColorSpeedBar = {r = 1, g = 0.82, b = 0, a = 1},

                    -- Whirling Surge progress bar
                    enableWhirlingSurge = true,
                    widthWhirlingSurge = 220,
                    heightWhirlingSurge = 15,
                    colorWhirlingSurge = {r = 0, g = 0.6, b = 1, a = 1},
                    previewWhirlingSurge = false,

                    -- Skyward Ascent progress bar
                    enableSkywardAscent = true,
                    widthSkywardAscent = 220,
                    heightSkywardAscent = 15,
                    colorSkywardAscent = {r = 1, g = 0, b = 0, a = 1},
                    previewSkywardAscent = false,

                    -- Common Thrill of the Skies and Ground Skimming settings
                    pulseType = "alpha", -- Options: "none", "movement", "scale", "alpha"
                    pulseSpeed = 6,
                    preview = false,
                    movementAmplitude = 3,
                    scaleMultiplier = 1.2,
                    alphaReduction = 0.5,

                    -- Thrill of the Skies settings
                    enableThrillOfTheSkies = true,
                    colorThrillOfTheSkies = {r=1, g=1, b=1, a=1},
                    previewThrillOfTheSkies = false,

                    -- Ground Skimming settings
                    enableGroundSkimming = true,
                    colorGroundSkimming = {r=1, g=0.85, b=0, a=1},
                    previewGroundSkimming = false,
                },
            }
        }
    })

    -- Register slash command /skyui to open config
    self:RegisterChatCommand("skyui", "OpenConfig")
    self:RegisterChatCommand("SkyridingUI", "OpenConfig")

    -- Create a frame to manually handle events
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    self.eventFrame:RegisterUnitEvent("UNIT_AURA", "player")

    -- Set event handler to update module visibility on relevant events
    self.eventFrame:SetScript("OnEvent", function(_, event, unit)
        C_Timer.After(0.05, function()
            self:UpdateModuleVisibility()
        end)
    end)
end

--------------------------------------------------
-- Debug System
--------------------------------------------------
-- Print debug messages if debug mode is enabled
function SkyridingUI:Debug(message)
    if self.db.profile.debug then
        print("|cffff0000[SkyridingUI Debug]:|r " .. message)
    end
end

--------------------------------------------------
-- Skyriding Detection
--------------------------------------------------
function SkyridingUI:IsPlayerSkyriding()
    local isGliding, canGlide, _ = C_PlayerInfo.GetGlidingInfo()

    if SkyridingUI.db.profile.hideWhenGrounded then
        return isGliding and canGlide
    else
        return canGlide

    end
end

--------------------------------------------------
-- Update Modules (e.g. after events or config changes)
--------------------------------------------------
-- Update visibility of all modules based on skyriding status and module settings
function SkyridingUI:UpdateModuleVisibility()
    local isSkyriding = self:IsPlayerSkyriding()

    -- Update each module's visibility based on skyriding status and individual module settings
    -- If 'onlyVigorUI' is enabled, only show the VigorModule when skyriding, hide all others
    for name, module in pairs(self.modules) do
        if module.SetActive then
            if self.db.profile.onlyVigorUI then
                if name == "VigorModule" then
                    module:SetActive(isSkyriding)
                else
                    module:SetActive(false)
                end
            else
                module:SetActive(isSkyriding)
            end
        end
    end
end

--- Refresh module settings (e.g. after changing pulse type/speed)
function SkyridingUI:RefreshModules()
    for _, module in pairs(self.modules) do
        if module.Refresh then
            module:Refresh()
        end
    end
end

-- Restart pulse animations to apply new settings
function SkyridingUI:RestartPulses()
    for _, module in pairs(self.modules) do
        if module.StopPulse and module.UpdateState then
            module:StopPulse()
            module:UpdateState()
        end
    end
end

-- Combined update function to refresh modules, restart pulses, and update visibility
function SkyridingUI:UpdateModules()
    SkyridingUI:RefreshModules()
    SkyridingUI:RestartPulses()
    SkyridingUI:UpdateModuleVisibility()    
end

--------------------------------------------------
-- Slash Command
--------------------------------------------------
-- Open the configuration dialog when /skyui is used
function SkyridingUI:OpenConfig()
    local aceDialog = LibStub("AceConfigDialog-3.0")
    local status = aceDialog:GetStatusTable("Skyriding UI Full")
    status.width = status.width or 1000
    status.height = status.height or 600
    aceDialog:Open("Skyriding UI Full")
end