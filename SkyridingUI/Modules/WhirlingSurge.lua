local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local WhirlingSurgeModule = SkyridingUI:NewModule("WhirlingSurgeModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")

local WHIRLING_SPELL_ID = 361584 -- Whirling Surge spell ID


--------------------------------------------------
-- Initialization
--------------------------------------------------
function WhirlingSurgeModule:OnInitialize()
    self.whirlingSurgeFrame = CreateFrame("Frame", "SkyridingUIWhirlingSurgeFrame", UIParent)
    self.whirlingSurgeFrame:SetFrameStrata("MEDIUM")
    self.whirlingSurgeFrame:Hide()

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function()
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function WhirlingSurgeModule:BuildUI()
    --------------------------------------------------
    -- Status Bar
    --------------------------------------------------
    self.statusBar = CreateFrame("StatusBar", nil, self.whirlingSurgeFrame)
    self.statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    self.statusBar:SetPoint("TOPLEFT", self.whirlingSurgeFrame, "TOPLEFT", 3.5, -3.5)
    self.statusBar:SetPoint("BOTTOMRIGHT", self.whirlingSurgeFrame, "BOTTOMRIGHT", -3.5, 3.5)
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
    self.border = CreateFrame("Frame", nil, self.whirlingSurgeFrame, "BackdropTemplate")
    self.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12})
    self.border:SetBackdropBorderColor(1, 0.82, 0, 1)
    self.border:SetBackdropColor(0,0,0,0)
    self.border:SetFrameLevel(7)

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.whirlingSurgeFrame:Hide()
    self:Refresh()
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function WhirlingSurgeModule:Refresh()
    local profile = SkyridingUI.db.profile

    -- Position the frame relative to SpeedBar if enabled, otherwise relative to Vigor
    if SkyridingUI.db.profile.modules.optional.enableSpeedBar then
        self.whirlingSurgeFrame:SetPoint("BOTTOM", SkyridingUI.modules["SpeedBarModule"].speedBarFrame, "TOP", 0, 0)
        self.border:SetPoint("BOTTOM", SkyridingUI.modules["SpeedBarModule"].speedBarFrame, "TOP", 0, 0)
    else
        self.whirlingSurgeFrame:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)
        self.border:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)
    end

    -- Apply size settings
    self.whirlingSurgeFrame:SetSize(profile.modules.optional.widthWhirlingSurge, profile.modules.optional.heightWhirlingSurge)
    self.border:SetSize(profile.modules.optional.widthWhirlingSurge, profile.modules.optional.heightWhirlingSurge)

    -- Apply scale
    self.baseScale = profile.scale or 1
    self.whirlingSurgeFrame:SetScale(self.baseScale)

    -- Apply color
    local color = profile.modules.optional.colorWhirlingSurge or {r=0, g=0.6, b=1, a=1}
    self.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function WhirlingSurgeModule:SetActive(active)
    local show = active and SkyridingUI.db.profile.modules.optional.enableWhirlingSurge

    if show then
        self.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self:UpdateState()
    else
        self.eventFrame:UnregisterAllEvents()
        self.whirlingSurgeFrame:SetScript("OnUpdate", nil)
        self.whirlingSurgeFrame:Hide()
    end
end

--------------------------------------------------
-- Update Whirling Surge Cooldown
--------------------------------------------------
function WhirlingSurgeModule:UpdateState()
    -- Preview mode: simulate a 10s cycling cooldown
    if SkyridingUI.db.profile.modules.optional.previewWhirlingSurge then
        local duration = 10
        local elapsed = math.fmod(GetTime(), duration)
        local remaining = duration - elapsed
        self.statusBar:SetMinMaxValues(0, duration)
        self.statusBar:SetValue(remaining)
        self.whirlingSurgeFrame:Show()
        OnUpdateHandler:OnUpdateHandler(self.whirlingSurgeFrame, function()
            self:UpdateState()
        end)
        return
    end

    -- Real cooldown check by spell name
    local spellInfo = C_Spell.GetSpellCooldown(WHIRLING_SPELL_ID)
    if spellInfo and spellInfo["duration"] > 0 then
        local now = GetTime()
        local remaining = math.max(0, spellInfo["duration"] - (now - spellInfo["startTime"]))
        self.statusBar:SetMinMaxValues(0, spellInfo["duration"])
        self.statusBar:SetValue(remaining)
        self.whirlingSurgeFrame:Show()
        OnUpdateHandler:OnUpdateHandler(self.whirlingSurgeFrame, function()
            self:UpdateState()
        end)
    else
        self.whirlingSurgeFrame:SetScript("OnUpdate", nil)
        self.whirlingSurgeFrame:Hide()
    end
end
