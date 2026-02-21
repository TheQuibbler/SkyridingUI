-- Get the main addon object from AceAddon-3.0
local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local VigorModule = SkyridingUI:NewModule("VigorModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")
local PulseAnimationModule = SkyridingUI:GetModule("PulseAnimationModule")

local SPELL_ID = 372608 -- Surge Forward spell ID

--------------------------------------------------
-- Initialization
--------------------------------------------------
function VigorModule:OnInitialize()
    -- Create the main frame for the vigor display
    self.vigorFrame = CreateFrame("Frame", "SkyridingUIVigorFrame", UIParent)
    self.vigorFrame:SetFrameStrata("MEDIUM")

    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function()
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function VigorModule:BuildUI()
    -- Store previous charges to detect changes for pulse animation
    self.previousFullCharges = {}

    -- Get current information for Surge Forward
    local chargeInfo = C_Spell.GetSpellCharges(SPELL_ID)
    local maxCharges = 6 
    if chargeInfo then 
        maxCharges = chargeInfo.maxCharges
    end

    -- Initialize previousFullCharges based on current charges to avoid triggering pulses on first login
    for i = 1, maxCharges do
        self.previousFullCharges[i] = true
    end

    --------------------------------------------------
    -- Vigor Background Textures
    --------------------------------------------------    
    -- Center the frame based on the number of charges and spacing
    local slotSpacing = 40
    local totalWidth = maxCharges * slotSpacing
    self.vigorFrame:SetSize(totalWidth, 64)

    self.backgrounds = {}
    for i = 1, maxCharges do
        -- Create background texture for each vigor slot
        local background = self.vigorFrame:CreateTexture(nil, "BACKGROUND")
        background:SetAtlas("dragonriding_vigor_background")
        background:SetSize(30.5, 35.5) 
        
        -- Centered offset calculation
        local offset = (i - 1) * slotSpacing - (totalWidth / 2) + (slotSpacing / 2)
        background:SetPoint("CENTER", self.vigorFrame, "CENTER", offset, 0)
        table.insert(self.backgrounds, background)
    end
    
    --------------------------------------------------
    -- Vigor Fullfill Textures (Filled)
    --------------------------------------------------
    self.fullfills = {}
    for i = 1, maxCharges do
        -- Create fill texture for each vigor slot
        local fullfill = self.vigorFrame:CreateTexture(nil, "OVERLAY")
        fullfill:SetAtlas("dragonriding_vigor_fillfull")
        fullfill:SetSize(36, 36) 
        fullfill:SetPoint("CENTER", self.backgrounds[i], "CENTER")
        fullfill:SetAlpha(0)  
        table.insert(self.fullfills, fullfill)
    end

    --------------------------------------------------
    -- Vigor Fill Textures (Charging Progress)
    --------------------------------------------------
    self.fills = {}
    for i = 1, maxCharges do
        -- Create fill texture for each vigor slot
        local fill = self.vigorFrame:CreateTexture(nil, "BACKGROUND")
        fill:SetAtlas("dragonriding_vigor_fill")
        fill:SetSize(36, 36) 
        fill:SetPoint("BOTTOM", self.fullfills[i], "BOTTOM")
        fill:SetAlpha(0) 
        fill.fullWidth, fill.fullHeight = fill:GetSize()  
        table.insert(self.fills, fill)
    end

    
    --------------------------------------------------
    -- Vigor Frame Textures (Borders)
    --------------------------------------------------
    self.frames = {}
    for i = 1, maxCharges do
        -- Create border/frame for each vigor slot
        local frame = self.vigorFrame:CreateTexture(nil, "OVERLAY")
        frame:SetAtlas("dragonriding_vigor_frame")
        frame:SetSize(60, 65) 
        frame:SetPoint("CENTER", self.backgrounds[i], "CENTER")
        table.insert(self.frames, frame)
    end

    --------------------------------------------------
    -- Pulse Textures and frames (for when a vigor charge is gained)
    --------------------------------------------------
    self.pulses = {}
    for i = 1, maxCharges do
        -- Create the pulse frame
        local pulseFrame = CreateFrame("Frame", nil, self.vigorFrame)
        pulseFrame:SetSize(60, 65)
        pulseFrame:SetPoint("CENTER", self.backgrounds[i], "CENTER", -0.5, 0)
        table.insert(self.pulses, pulseFrame)

        -- Create the pulse texture as a child of the frame
        local pulseTexture = pulseFrame:CreateTexture(nil, "OVERLAY")
        pulseTexture:SetAtlas("dragonriding_vigor_flash")
        pulseTexture:SetSize(60, 65)
        pulseTexture:SetPoint("CENTER", pulseFrame, "CENTER", -0.5, 0)

        pulseFrame:Hide()
    end

    --------------------------------------------------
    -- Decor Textures
    --------------------------------------------------
    -- Left side Decor (Flipped)
    self.leftDecor = self.vigorFrame:CreateTexture(nil, "OVERLAY")
    self.leftDecor:SetAtlas("dragonriding_vigor_decor")
    self.leftDecor:SetSize(46.5, 58.5)  
    self.leftDecor:SetPoint("CENTER", self.backgrounds[1], "LEFT", -10, -12)
    self.leftDecor:SetTexCoord(1, 0, 0, 1) 

    -- Right side Decor
    self.rightDecor = self.vigorFrame:CreateTexture(nil, "OVERLAY")
    self.rightDecor:SetAtlas("dragonriding_vigor_decor")
    self.rightDecor:SetSize(46.5, 58.5) 
    self.rightDecor:SetPoint("CENTER", self.backgrounds[#self.backgrounds], "RIGHT", 10, -12)


    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.vigorFrame:Hide()
    self:Refresh() -- Apply initial settings
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function VigorModule:Refresh()
    local db = SkyridingUI.db.profile

    -- Apply scale and position from saved settings
    self.baseScale = db.scale or 1
    self.vigorFrame:SetScale(self.baseScale)
    self.vigorFrame:ClearAllPoints()
    self.vigorFrame:SetPoint("CENTER", UIParent, "CENTER", db.posX, db.posY)
    
    -- Show or hide rightDecor based on settings
    if self.rightDecor then self.rightDecor:SetShown(db.modules.vigor.showVigorDecor) end
    if self.leftDecor then self.leftDecor:SetShown(db.modules.vigor.showVigorDecor) end
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function VigorModule:SetActive(active)
    -- Show or hide the vigor frame based on 'active' and module enable setting
    local show = active and SkyridingUI.db.profile.modules.vigor.enableVigor
    self.vigorFrame:SetShown(show)

    if show then
        self.eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self:UpdateState()
    else
        self.eventFrame:UnregisterAllEvents()
        self.vigorFrame:SetScript("OnUpdate", nil)
    end
end

--------------------------------------------------
-- Update Vigor Charges
--------------------------------------------------
function VigorModule:UpdateState()
    -- Get current information for Surge Forward
    local chargeInfo = C_Spell.GetSpellCharges(SPELL_ID) 

    -- If we can't get charge info or the module is disabled, don't run the update
    local runUpdate = chargeInfo and SkyridingUI.db.profile.modules.vigor.enableVigor
    if not runUpdate then return end

    local currentCharges = chargeInfo.currentCharges
    local maxCharges = chargeInfo.maxCharges
    local start = chargeInfo.cooldownStartTime
    local duration = chargeInfo.cooldownDuration
    local now = GetTime()

    local needsOnUpdate = false

    -- Update each vigor slot based on current charges and cooldown progress
    for i = 1, maxCharges do
        local fullfill = self.fullfills[i]
        local fill = self.fills[i]
        
        if i <= currentCharges then
            -- This slot is fully charged
            fullfill:SetAlpha(1)
            fill:SetAlpha(0)
                
            -- Check if this slot was previously not full → trigger pulse
            if not self.previousFullCharges[i] then
                PulseAnimationModule:PulseAlphaOnce(self.pulses[i], 1)
            end
            
            self.previousFullCharges[i] = true
                
        elseif i == currentCharges + 1 and duration and duration > 0 then
            -- This slot is currently recharging
            local progress = (now - start) / duration
            progress = math.min(progress, 1)

            fullfill:SetAlpha(0.25)
            fill:SetAlpha(1)

            -- Fill from bottom to top based on recharge progress
            fill:SetTexCoord(0, 1, 1 - progress, 1)
            fill:SetSize(fill.fullWidth, fill.fullHeight * progress)

            needsOnUpdate = true
            self.previousFullCharges[i] = false

        else
            -- This slot is empty (not charged, not recharging)
            fill:SetAlpha(0)
            fullfill:SetAlpha(0)
            self.previousFullCharges[i] = false

        end
    end
    
    -- If any slot is currently recharging, we need to keep the OnUpdate script running to update the progress. 
    -- Otherwise, we can stop it to save resources.
    if needsOnUpdate then
        OnUpdateHandler:OnUpdateHandler(self.vigorFrame, function()
            self:UpdateState()
        end)
    else
        self.vigorFrame:SetScript("OnUpdate", nil)
    end
end

