local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local SkywardAscentModule = SkyridingUI:NewModule("SkywardAscentModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")

local SKYWARD_SPELL_ID = 372610 -- Skyward Ascent spell ID
local SKYWARD_DURATION = 2.5


--------------------------------------------------
-- Initialization
--------------------------------------------------
function SkywardAscentModule:OnInitialize()
    self.skywardAscentFrame = CreateFrame("Frame", "SkyridingUIskywardAscentFrame", UIParent)
    self.skywardAscentFrame:SetFrameStrata("MEDIUM")
    self.skywardAscentFrame:Hide()

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function(_, _, unit, _, spellId)
        if unit == "player" and spellId == SKYWARD_SPELL_ID then
            self.endTime = GetTime() + SKYWARD_DURATION
        end
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function SkywardAscentModule:BuildUI()
    --------------------------------------------------
    -- Status Bar
    --------------------------------------------------
    self.statusBar = CreateFrame("StatusBar", nil, self.skywardAscentFrame)
    self.statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    self.statusBar:SetPoint("TOPLEFT", self.skywardAscentFrame, "TOPLEFT", 3.5, -3.5)
    self.statusBar:SetPoint("BOTTOMRIGHT", self.skywardAscentFrame, "BOTTOMRIGHT", -3.5, 3.5)
    self.statusBar:SetMinMaxValues(0, 1)
    self.statusBar:SetValue(0)

    --------------------------------------------------
    -- Background
    --------------------------------------------------
    local bg = self.statusBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(self.statusBar)
    bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    bg:SetVertexColor(0, 0, 0, 0.4)

    --------------------------------------------------
    -- Border (overlay)
    --------------------------------------------------
    self.border = CreateFrame("Frame", nil, self.skywardAscentFrame, "BackdropTemplate")
    self.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})
    self.border:SetBackdropBorderColor(1, 0.82, 0, 1)
    self.border:SetBackdropColor(0,0,0,0)
    self.border:SetFrameLevel(7)

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.skywardAscentFrame:Hide()
    self:Refresh()
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function SkywardAscentModule:Refresh()
    local profile = SkyridingUI.db.profile

    -- Position the frame relative to SpeedBar if enabled, otherwise relative to Vigor
    self.anchorTarget = nil
    self:UpdateAnchor()

    -- Apply size settings
    self.skywardAscentFrame:SetSize(profile.modules.optional.widthSkywardAscent, profile.modules.optional.heightSkywardAscent)
    self.border:SetSize(profile.modules.optional.widthSkywardAscent, profile.modules.optional.heightSkywardAscent)

    -- Apply scale
    self.baseScale = profile.scale or 1
    self.skywardAscentFrame:SetScale(self.baseScale)

    -- Apply color
    local color = profile.modules.optional.colorSkywardAscent or {r=0, g=0.6, b=1, a=1}
    self.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)

     -- Reset end time to ensure bar is hidden until next cast
    self.endTime = 0
end

--------------------------------------------------
-- Re-anchor Skyward Ascent frame based on enabled modules
--------------------------------------------------
function SkywardAscentModule:UpdateAnchor()
    -- Only re-anchor when the target changes to avoid doing layout work every OnUpdate tick
    if SkyridingUI.modules["WhirlingSurgeModule"].whirlingSurgeFrame:IsShown() then
        self.anchorTarget = "Whirling"
    elseif SkyridingUI.db.profile.modules.optional.enableSpeedBar then
        self.anchorTarget = "Speed"
    else
        self.anchorTarget = "Vigor"
    end

    if self.anchorTarget ~= self.currentAnchorTarget then
        self.currentAnchorTarget = self.anchorTarget

        self.skywardAscentFrame:ClearAllPoints()
        self.border:ClearAllPoints()

        if self.anchorTarget == "Whirling" then
            self.skywardAscentFrame:SetPoint("BOTTOM", SkyridingUI.modules["WhirlingSurgeModule"].whirlingSurgeFrame, "TOP", 0, 0)
            self.border:SetPoint("BOTTOM", SkyridingUI.modules["WhirlingSurgeModule"].whirlingSurgeFrame, "TOP", 0, 0)
        elseif self.anchorTarget == "Speed" then
            self.skywardAscentFrame:SetPoint("BOTTOM", SkyridingUI.modules["SpeedBarModule"].speedBarFrame, "TOP", 0, 0)
            self.border:SetPoint("BOTTOM", SkyridingUI.modules["SpeedBarModule"].speedBarFrame, "TOP", 0, 0)
        else
            self.skywardAscentFrame:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)
            self.border:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)
        end
    end
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function SkywardAscentModule:SetActive(active)
    local show = active and SkyridingUI.db.profile.modules.optional.enableSkywardAscent

    if show then
        self.eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
        self:UpdateState()
    else
        self.eventFrame:UnregisterAllEvents()
        self.skywardAscentFrame:SetScript("OnUpdate", nil)
        self.skywardAscentFrame:Hide()
    end
end

--------------------------------------------------
-- Update Skyward Ascent bar
--------------------------------------------------
function SkywardAscentModule:UpdateState()
    -- Update anchor in case relevant modules were enabled/disabled since last cast
    self:UpdateAnchor()
    
    -- Preview mode: simulate a 10s cycling cooldown
    if SkyridingUI.db.profile.modules.optional.previewSkywardAscent then
        local duration = SKYWARD_DURATION
        local elapsed = math.fmod(GetTime(), duration)
        local remaining = duration - elapsed
        self.statusBar:SetMinMaxValues(0, duration)
        self.statusBar:SetValue(remaining)
        self.skywardAscentFrame:Show()
        OnUpdateHandler:OnUpdateHandler(self.skywardAscentFrame, function()
            self:UpdateState()
        end)
        return
    end

    -- If a cast started the timer, self.endTime will be set. Update remaining time accordingly.
    local now = GetTime()
    local remaining = math.max(0, self.endTime - now)
    if remaining > 0 then
        self.statusBar:SetMinMaxValues(0, SKYWARD_DURATION)
        self.statusBar:SetValue(remaining)
        self.skywardAscentFrame:Show()
        OnUpdateHandler:OnUpdateHandler(self.skywardAscentFrame, function()
            self:UpdateState()
        end)
        return
    else
        self.skywardAscentFrame:SetScript("OnUpdate", nil)
        self.skywardAscentFrame:Hide()
    end
end

