local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local GroundSkimmingModule = SkyridingUI:NewModule("GroundSkimmingModule")
local PulseAnimationModule = SkyridingUI:GetModule("PulseAnimationModule")

local GROUND_SPELL_ID = 404184 -- Ground Skimming
local THRILL_SPELL_ID = 377234 -- Thrill of the Skies

--------------------------------------------------
-- Initialization
--------------------------------------------------
function GroundSkimmingModule:OnInitialize()
    self.groundSkimmingFrame = CreateFrame("Frame", "SkyridingUIGroundSkimmingFrame", UIParent)
    self.groundSkimmingFrame:SetFrameStrata("MEDIUM")
    self.groundSkimmingFrame:Hide()

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function()
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function GroundSkimmingModule:BuildUI()
    --------------------------------------------------
    -- Ground Skimming textures
    --------------------------------------------------
    --- Left texture
    self.left = self.groundSkimmingFrame:CreateTexture(nil, "OVERLAY")
    self.left:SetTexture(1028136)
    self.left:SetSize(200, 200)    

    --- Right texture (flipped)
    self.right = self.groundSkimmingFrame:CreateTexture(nil, "OVERLAY")
    self.right:SetTexture(1028136)
    self.right:SetSize(200, 200)
    self.right:SetTexCoord(1, 0, 0, 1)

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.groundSkimmingFrame:Hide()
    self:Refresh() -- Apply initial settings
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function GroundSkimmingModule:Refresh()
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

    -- Apply scale and position
    self.baseScale = profile.scale or 1
    self.groundSkimmingFrame:SetScale(self.baseScale)

    -- Apply color
    local color = profile.modules.optional.colorGroundSkimming or {r=1, g=0.85, b=0, a=1}
    self.left:SetVertexColor(color.r, color.g, color.b, color.a)
    self.right:SetVertexColor(color.r, color.g, color.b, color.a)
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function GroundSkimmingModule:SetActive(active)
    -- Show or hide the GroundSkimming frame based on 'active' and module enable setting
    local show = active and SkyridingUI.db.profile.modules.optional.enableGroundSkimming

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
-- Update Ground Skimming Buff
--------------------------------------------------
function GroundSkimmingModule:UpdateState()
    local enabled = SkyridingUI.db.profile.modules.optional.enableGroundSkimming
    if not enabled then return end

    local groundBuff = C_UnitAuras.GetPlayerAuraBySpellID(GROUND_SPELL_ID)
    local thrillBuff = C_UnitAuras.GetPlayerAuraBySpellID(THRILL_SPELL_ID)

    if (groundBuff and not thrillBuff) or SkyridingUI.db.profile.modules.optional.previewGroundSkimming then
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
function GroundSkimmingModule:StartPulse()
    if self.pulsing then return end
    self.pulsing = true
    
    local settings = SkyridingUI.db.profile.modules.optional
    local pulseSpeed = settings.pulseSpeed
    local pulseType = settings.pulseType

    if pulseType == "movement" then
        PulseAnimationModule:PulseMovement(self.groundSkimmingFrame, self.left, self.right, settings.movementAmplitude, pulseSpeed, self.leftBaseX, self.leftBaseY, self.leftBaseAnchor, self.rightBaseX, self.rightBaseY, self.rightBaseAnchor)
    elseif pulseType == "scale" then
        PulseAnimationModule:PulseScale(self.groundSkimmingFrame, self.baseScale, settings.scaleMultiplier * self.baseScale, pulseSpeed)
    elseif pulseType == "alpha" then
        PulseAnimationModule:PulseAlpha(self.groundSkimmingFrame, settings.alphaReduction, 1, pulseSpeed)
    else
        -- No pulse
        self.groundSkimmingFrame:SetAlpha(1)
        self.groundSkimmingFrame:Show()
    end
end

--------------------------------------------------
-- Stop Pulse Animation
--------------------------------------------------
function GroundSkimmingModule:StopPulse()
    if not self.pulsing then return end
    self.pulsing = false

    -- Stop all pulsing using PulseAnimationModule
    PulseAnimationModule:StopPulse(self.groundSkimmingFrame)

    -- Reset scale
    self.groundSkimmingFrame:SetScale(self.baseScale or 1)
end 