local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local ThrillOfTheSkiesModule = SkyridingUI:NewModule("ThrillOfTheSkiesModule")
local PulseAnimationModule = SkyridingUI:GetModule("PulseAnimationModule")

local THRILL_SPELL_ID = 377234 -- Thrill of the Skies

--------------------------------------------------
-- Initialization
--------------------------------------------------
function ThrillOfTheSkiesModule:OnInitialize()
    self.thrillOfTheSkiesFrame = CreateFrame("Frame", "SkyridingUIThrillFrame", UIParent)
    self.thrillOfTheSkiesFrame:SetFrameStrata("MEDIUM")
    self.thrillOfTheSkiesFrame:Hide()

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function()
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function ThrillOfTheSkiesModule:BuildUI()
    --------------------------------------------------
    -- Thrill of the skies textures
    --------------------------------------------------
    --- Left texture
    self.left = self.thrillOfTheSkiesFrame:CreateTexture(nil, "OVERLAY")
    self.left:SetTexture(1028136)
    self.left:SetSize(200, 200)

    --- Right texture (flipped)
    self.right = self.thrillOfTheSkiesFrame:CreateTexture(nil, "OVERLAY")
    self.right:SetTexture(1028136)
    self.right:SetSize(200, 200)
    self.right:SetTexCoord(1, 0, 0, 1)
    

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.thrillOfTheSkiesFrame:Hide()
    self:Refresh() -- Apply initial settings
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function ThrillOfTheSkiesModule:Refresh()
    local profile = SkyridingUI.db.profile

    -- Adjust position based on Vigor Decor
    local enabledDecor = profile.modules.vigor.showVigorDecor
    local offset = 28
    if enabledDecor then 
        offset = 10
    end

    self.left:SetPoint("CENTER", SkyridingUI.modules["VigorModule"].leftDecor, "LEFT", offset, 38)
    self.right:SetPoint("CENTER", SkyridingUI.modules["VigorModule"].rightDecor, "RIGHT", -offset, 38)

    -- Store base coordinates for pulse
    self.leftBaseX, self.leftBaseY = offset, 38
    self.rightBaseX, self.rightBaseY = -offset, 38
    self.leftBaseAnchor  = SkyridingUI.modules["VigorModule"].leftDecor
    self.rightBaseAnchor = SkyridingUI.modules["VigorModule"].rightDecor

    -- Apply scale and color
    self.baseScale = profile.scale or 1
    self.thrillOfTheSkiesFrame:SetScale(self.baseScale)

    local color = profile.modules.optional.colorThrillOfTheSkies or {r=1, g=1, b=1, a=1}
    self.left:SetVertexColor(color.r, color.g, color.b, color.a)
    self.right:SetVertexColor(color.r, color.g, color.b, color.a)
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function ThrillOfTheSkiesModule:SetActive(active)
    -- Show or hide the thrilloftheskies frame based on 'active' and module enable setting
    local show = active and SkyridingUI.db.profile.modules.optional.enableThrillOfTheSkies

    if show then
        self.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")    
        self.eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
        self:UpdateState()
    else
        self.eventFrame:UnregisterAllEvents()
        self:StopPulse()
    end
end

--------------------------------------------------
-- Update Thrill Of The Skies Buff
--------------------------------------------------
function ThrillOfTheSkiesModule:UpdateState()
    local enabled = SkyridingUI.db.profile.modules.optional.enableThrillOfTheSkies
    if not enabled then return end

    local hasBuff = C_UnitAuras.GetPlayerAuraBySpellID(THRILL_SPELL_ID)

    if hasBuff or SkyridingUI.db.profile.modules.optional.previewThrillOfTheSkies or SkyridingUI.db.profile.modules.optional.preview then
        if not self.pulsing then
            self:StartPulse()
        end
    else
        self:StopPulse()
    end
end

--------------------------------------------------
-- Start Pulse Animation
--------------------------------------------------
function ThrillOfTheSkiesModule:StartPulse()
    if self.pulsing then return end
    self.pulsing = true
    
    local settings = SkyridingUI.db.profile.modules.optional
    local pulseSpeed = settings.pulseSpeed
    local pulseType = settings.pulseType

    if pulseType == "movement" then
        PulseAnimationModule:PulseMovement(self.thrillOfTheSkiesFrame, self.left, self.right, settings.movementAmplitude, pulseSpeed, self.leftBaseX, self.leftBaseY, self.leftBaseAnchor, self.rightBaseX, self.rightBaseY, self.rightBaseAnchor)
    elseif pulseType == "scale" then
        PulseAnimationModule:PulseScale(self.thrillOfTheSkiesFrame, self.baseScale, settings.scaleMultiplier * self.baseScale, pulseSpeed)
    elseif pulseType == "alpha" then
        PulseAnimationModule:PulseAlpha(self.thrillOfTheSkiesFrame, settings.alphaReduction, 1, pulseSpeed)
    else
        -- No pulse
        self.thrillOfTheSkiesFrame:SetAlpha(1)
        self.thrillOfTheSkiesFrame:Show()
    end
end


--------------------------------------------------
-- Stop Pulse Animation
--------------------------------------------------
function ThrillOfTheSkiesModule:StopPulse()
    if not self.pulsing then return end
    self.pulsing = false

    -- Stop all pulsing using PulseAnimationModule
    PulseAnimationModule:StopPulse(self.thrillOfTheSkiesFrame)

    -- Reset scale
    self.thrillOfTheSkiesFrame:SetScale(self.baseScale or 1)
end