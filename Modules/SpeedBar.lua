local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local SpeedBarModule = SkyridingUI:NewModule("SpeedBarModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")

local LOW_ZONE_SPEED = 85
local HIGH_ZONE_SPEED = 100



--------------------------------------------------
-- Initialization
--------------------------------------------------
function SpeedBarModule:OnInitialize()
    -- Container frame (kept mainly for grouping; the visible element is the status bar)
    self.speedBarFrame = CreateFrame("Frame", "SkyridingUISpeedBarFrame", UIParent)
    self.speedBarFrame:SetFrameStrata("MEDIUM")
    self.speedBarFrame:Hide()

    self:BuildUI()

    -- register zone change events on the frame so we can reset observed max
    -- only listen for major zone changes; subzone changes fire ZONE_CHANGED and are noisy
    self.speedBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.speedBarFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self.speedBarFrame:SetScript("OnEvent", function()
        SpeedBarModule:OnZoneChanged()
    end)
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function SpeedBarModule:BuildUI()
    --------------------------------------------------
    -- Status Bar
    --------------------------------------------------
    self.statusBar = CreateFrame("StatusBar", nil, self.speedBarFrame)
    self.statusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    self.statusBar:SetPoint("TOPLEFT", self.speedBarFrame, "TOPLEFT", 3.5, -3.5)
    self.statusBar:SetPoint("BOTTOMRIGHT", self.speedBarFrame, "BOTTOMRIGHT", -3.5, 3.5)
    self.statusBar:SetMinMaxValues(0, LOW_ZONE_SPEED)
    self.statusBar:SetValue(0)
    self.statusBarMaxValue = LOW_ZONE_SPEED

    --------------------------------------------------
    -- Background
    --------------------------------------------------
    local background = self.statusBar:CreateTexture(nil, "BACKGROUND")
    background:SetAllPoints(self.statusBar)
    background:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    background:SetVertexColor(0, 0, 0, 0.4)

    --------------------------------------------------
    -- Border (overlay)
    --------------------------------------------------
    self.border = CreateFrame("Frame", nil, self.speedBarFrame,  "BackdropTemplate")
    self.border:SetBackdrop({edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3}})
    self.border:SetBackdropBorderColor(1, 0.82, 0, 1)
    self.border:SetBackdropColor(0, 0, 0, 0)
    self.border:SetFrameLevel(7)

    --------------------------------------------------
    -- Thrill Threshold Marker
    --------------------------------------------------
    self.thrillOfTheSkiesMarker = self.statusBar:CreateTexture(nil, "OVERLAY")
    self.thrillOfTheSkiesMarker:SetWidth(2)
    self.thrillOfTheSkiesMarker:SetColorTexture(1, 0.2, 0.2, 0.9)

    --------------------------------------------------
    -- Speed Text (centered)
    --------------------------------------------------
    self.statusText = self.statusBar:CreateFontString(nil, "OVERLAY")
    self.statusText:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    self.statusText:SetJustifyH("CENTER")
    self.statusText:SetText("0.0")

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.speedBarFrame:Hide()
    self:Refresh() -- Apply initial settings
end


--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function SpeedBarModule:Refresh()
    local profile = SkyridingUI.db.profile

    -- Position the frame relative to Whirling Surge bar (if enabled) or Vigor frame
    self.speedBarFrame:ClearAllPoints()
    self.border:ClearAllPoints()

    self.speedBarFrame:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)
    self.border:SetPoint("BOTTOM", SkyridingUI.modules["VigorModule"].vigorFrame, "TOP", 0, -5)

    -- Apply size settings
    self.speedBarFrame:SetSize(profile.modules.optional.widthSpeedBar, profile.modules.optional.heightSpeedBar)
    self.border:SetSize(profile.modules.optional.widthSpeedBar, profile.modules.optional.heightSpeedBar)
    self.thrillOfTheSkiesMarker:SetPoint("TOPLEFT", self.statusBar, "TOPLEFT", 0.6 * profile.modules.optional.widthSpeedBar , 0)
    self.thrillOfTheSkiesMarker:SetPoint("BOTTOMLEFT", self.statusBar, "BOTTOMLEFT", 0.6 * profile.modules.optional.widthSpeedBar, 0)

    -- Apply scale
    self.baseScale = profile.scale or 1
    self.speedBarFrame:SetScale(self.baseScale)

    -- Apply bar color
    local color = profile.modules.optional.colorSpeedBar
    self.statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)

    -- Apply text color
    local color = profile.modules.optional.textColorSpeedBar
    self.statusText:SetVertexColor(color.r, color.g, color.b, color.a)

    -- Apply thrill of the skies marker color
    local color = profile.modules.optional.thrillMarkerColorSpeedBar
    self.thrillOfTheSkiesMarker:SetColorTexture(color.r, color.g, color.b, color.a)

    -- Apply position of speed text
    local textPosition = profile.modules.optional.textLocationSpeedBar
    self.statusText:ClearAllPoints()
    if textPosition == "left" then
        self.statusText:SetPoint("LEFT", self.statusBar, "LEFT", 5, 0)
    elseif textPosition == "right" then
        self.statusText:SetPoint("RIGHT", self.statusBar, "RIGHT", -5, 0)
    else
        self.statusText:SetPoint("CENTER", self.statusBar, "CENTER", 0, 0)
    end

    -- Show/hide thrill of the skies marker based on options
    local showMarker = profile.modules.optional.thrillMarkerSpeedBar
    self.thrillOfTheSkiesMarker:SetShown(showMarker)
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function SpeedBarModule:SetActive(active)
    -- Show or hide the speed bar frame based on 'active' and module enable setting
    local show = active and SkyridingUI.db.profile.modules.optional.enableSpeedBar

    if show then
        self.speedBarFrame:Show()
        OnUpdateHandler:OnUpdateHandler(self.speedBarFrame, function()
            self:UpdateState()
        end)
    else
        self.speedBarFrame:SetScript("OnUpdate", nil)
        self.speedBarFrame:Hide()
    end
end

---------------------------------------------------
--- Zone Change Handling
---------------------------------------------------
function SpeedBarModule:OnZoneChanged()
    -- Reset observed max when changing zones/instances
    self.statusBar:SetMinMaxValues(0, LOW_ZONE_SPEED)
    self.statusBarMaxValue = LOW_ZONE_SPEED
    self:Refresh()
end

--------------------------------------------------
-- Update Speed
--------------------------------------------------
function SpeedBarModule:UpdateState() 
    -- Read forwardSpeed
    local _, _, speed = C_PlayerInfo.GetGlidingInfo()

    -- If speed is nil, it means we're not gliding, so hide the bar
    if not speed then return end

    -- if preview enabled, override speed with oscillating value to show off the bar and text
    if SkyridingUI.db.profile.modules.optional.previewSpeedBar then
        -- produce a preview oscillating between 0 and 100
        speed = 50 + 50 * math.sin(GetTime())
    end

    -- Exponential smoothing per-frame
    local now = GetTime()
    local deltaTime = now - (self.lastTime or now)
    self.lastTime = now

    -- Calculate smoothing factor based on deltaTime and SMOOTH_RATE = 8
    local alpha = 1 - math.exp(-8 * deltaTime)
    self.smoothSpeed = (self.smoothSpeed and (self.smoothSpeed + (speed - self.smoothSpeed) * alpha)) or speed

    -- Update max if we exceed it (e.g. entering a high-speed zone)
    if self.smoothSpeed > self.statusBarMaxValue then
        self.statusBar:SetMinMaxValues(0, HIGH_ZONE_SPEED)
        self.statusBarMaxValue = HIGH_ZONE_SPEED
        -- status bar max changed; update visual placement via Refresh()
        self:Refresh()
    end

    -- Update the status bar value
    self.smoothSpeed = math.max(0, self.smoothSpeed)
    self.statusBar:SetValue(self.smoothSpeed)

    -- Show/hide text when speed is zero or when text is disabled in profile
    if speed == 0 or not SkyridingUI.db.profile.modules.optional.enableTextSpeedBar then
        self.statusText:Hide()
        return
    else
        self.statusText:Show()
    end

    -- Throttle text updates to improve readability
    local now = GetTime()
    if not self.lastTextUpdate or (now - (self.lastTextUpdate)) >= 0.1 then
        local enableUnit = SkyridingUI.db.profile.modules.optional.enableUnitSpeedBar
        -- Calculate display value based on user preference, showing unit suffix only if enabled
        if SkyridingUI.db.profile.modules.optional.unitSpeedBar == "yds" then
            if enableUnit then
                self.statusText:SetText(string.format("%.1f yd/s", self.smoothSpeed))
            else
                self.statusText:SetText(string.format("%.1f", self.smoothSpeed))
            end
        elseif SkyridingUI.db.profile.modules.optional.unitSpeedBar == "ms" then
            local mps = self.smoothSpeed * 0.9144 -- convert yd/s to m/s
            if enableUnit then
                self.statusText:SetText(string.format("%.1f m/s", mps))
            else
                self.statusText:SetText(string.format("%.1f", mps))
            end
        else
            local pct = self.smoothSpeed * (100 / 7)
            if enableUnit then
                self.statusText:SetText(string.format("%.0f%%", pct))
            else
                self.statusText:SetText(string.format("%.0f", pct))
            end
        end

        self.lastTextUpdate = now
    end
end
