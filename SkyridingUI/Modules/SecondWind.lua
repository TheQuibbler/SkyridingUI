-- Get the main addon object from AceAddon-3.0
local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local SecondWindModule = SkyridingUI:NewModule("SecondWindModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")
local PulseAnimationModule = SkyridingUI:GetModule("PulseAnimationModule")

local SPELL_ID = 425782 -- Second Wind spell ID

-- flipbook texture coordinates for 4 frames horizontal, 5 frames vertical
-- Assume frame 1 (top-left of flipbook, 4x5)
local frameLeft = 0
local frameRight = 0.25
local frameTop = 0
local frameBottom = 0.2

--------------------------------------------------
-- Initialization
--------------------------------------------------
function SecondWindModule:OnInitialize()
    -- Create the main frame for the SecondWind display
    self.secondWindFrame = CreateFrame("Frame", "SkyridingUISecondWindFrame", UIParent)
    self.secondWindFrame:SetFrameStrata("MEDIUM")
    
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:SetScript("OnEvent", function()
        self:UpdateState()
    end)

    self:BuildUI()
end

--------------------------------------------------
-- Build UI
--------------------------------------------------
function SecondWindModule:BuildUI()
    -- Store previous charges to detect changes for pulse animation
    self.previousFullCharges = {}

    -- Get current information for SecondWind
    local chargeInfo = C_Spell.GetSpellCharges(SPELL_ID)
    local maxCharges = 3 
    if chargeInfo then 
        maxCharges = chargeInfo.maxCharges
    end

    -- Initialize previousFullCharges based on current charges to avoid triggering pulses on first login
    for i = 1, maxCharges do
        self.previousFullCharges[i] = true
    end

    --------------------------------------------------
    -- SecondWind Background Textures
    --------------------------------------------------
    -- Center the frame based on the number of charges and spacing
    local slotSpacing = 40
    local totalWidth = maxCharges * slotSpacing
    self.secondWindFrame:SetSize(totalWidth, 64)
    
    self.backgrounds = {}
    for i = 1, maxCharges do
        -- Create background texture for each SecondWind slot
        local background = self.secondWindFrame:CreateTexture(nil, "BACKGROUND")
        background:SetAtlas("dragonriding_sgvigor_background")
        background:SetSize(34.5, 49.5)
    
        -- Centered offset calculation
        local offset = (i - 1) * slotSpacing - (totalWidth / 2) + (slotSpacing / 2)
        background:SetPoint("CENTER", self.secondWindFrame, "CENTER", offset, 0)
        table.insert(self.backgrounds, background)
    end
    
    --------------------------------------------------
    -- SecondWind Fullfill Textures (Filled)
    --------------------------------------------------
    self.fullfills = {}
    for i = 1, maxCharges do
        -- Create fill texture for each SecondWind slot
        local fullfill = self.secondWindFrame:CreateTexture(nil, "BACKGROUND") 
        fullfill:SetAtlas("dragonriding_sgvigor_fillfull")
        fullfill:SetSize(32, 50)
        fullfill:SetPoint("BOTTOM", self.backgrounds[i], "BOTTOM")
        fullfill:SetAlpha(0)
        table.insert(self.fullfills, fullfill)
    end

    --------------------------------------------------
    -- SecondWind Fill Textures (Charging Progress)
    --------------------------------------------------
    self.fills = {}
    for i = 1, maxCharges do
        -- Create fill texture for each SecondWind slot
        local fill = self.secondWindFrame:CreateTexture(nil, "BACKGROUND")  
        fill:SetAtlas("dragonriding_sgvigor_fill_flipbook")
        fill:SetSize(32, 50)
        fill:SetPoint("BOTTOM", self.backgrounds[i], "BOTTOM")
        fill:SetAlpha(0)
        fill:SetTexCoord(frameLeft, frameRight, frameTop, frameBottom)
        fill.fullWidth, fill.fullHeight = fill:GetSize() 
        table.insert(self.fills, fill)
    end

    --------------------------------------------------
    -- SecondWind Border Textures
    --------------------------------------------------
    self.borders = {}
    for i = 1, maxCharges do
        -- Create border/frame for each SecondWind slot
        local border = self.secondWindFrame:CreateTexture(nil, "OVERLAY")
        border:SetSize(34.5, 52.5)
        border:SetPoint("CENTER", self.backgrounds[i], "CENTER")
        table.insert(self.borders, border)
    end

    --------------------------------------------------
    -- Pulse Textures (for when a vigor charge is gained)
    --------------------------------------------------
    self.pulses = {}
    for i = 1, maxCharges do
        -- Create the pulse frame
        local pulseFrame = CreateFrame("Frame", nil, self.secondWindFrame)
        pulseFrame:SetSize(42, 60)  
        pulseFrame:SetPoint("CENTER", self.backgrounds[i], "CENTER", -0.5, 0)
        table.insert(self.pulses, pulseFrame)

        -- Create the pulse texture as a child of the frame
        local pulseTexture = pulseFrame:CreateTexture(nil, "OVERLAY")
        pulseTexture:SetAtlas("dragonriding_sgvigor_flash")  
        pulseTexture:SetSize(42, 60)  
        pulseTexture:SetPoint("CENTER", pulseFrame, "CENTER", -0.5, 0)

        pulseFrame:Hide()
    end

    --------------------------------------------------
    -- Finalize UI
    --------------------------------------------------
    self.secondWindFrame:Hide() -- Hide by default
    self:Refresh() -- Apply initial settings
end

--------------------------------------------------
-- Apply UI Settings
--------------------------------------------------
function SecondWindModule:Refresh()
    local profile = SkyridingUI.db.profile

    -- Position the frame relative to vigorFrame
    self.secondWindFrame:SetPoint("TOP", SkyridingUI.modules["VigorModule"].vigorFrame, "BOTTOM", 0, 20)
    
    -- Apply texture based on setting
    for _, border in pairs(self.borders) do
        if profile.modules.optional.frameStyleSecondWind == "gold" then
            border:SetAtlas("dragonriding_sgvigor_frame_gold")
        elseif profile.modules.optional.frameStyleSecondWind == "silver" then
            border:SetAtlas("dragonriding_sgvigor_frame_silver")
        elseif profile.modules.optional.frameStyleSecondWind == "bronze" then
            border:SetAtlas("dragonriding_sgvigor_frame_bronze")
        else
            border:SetAtlas("dragonriding_sgvigor_frame_dark")
        end
    end

    -- Apply scale
    self.baseScale = profile.scale
    self.secondWindFrame:SetScale(self.baseScale)

    -- Apply color tint settings
    local secondWindColor = profile.modules.optional.colorSecondWind
    for _, fill in ipairs(self.fills) do
        fill:SetVertexColor(secondWindColor.r, secondWindColor.g, secondWindColor.b, secondWindColor.a)
    end
    for _, fullfill in ipairs(self.fullfills) do
        fullfill:SetVertexColor(secondWindColor.r, secondWindColor.g, secondWindColor.b, secondWindColor.a)
    end
    for _, pulse in ipairs(self.pulses) do
        local pulseTexture = pulse:GetRegions()
        if pulseTexture then
            pulseTexture:SetVertexColor(secondWindColor.r, secondWindColor.g, secondWindColor.b, secondWindColor.a)
        end
    end

    -- Apply border color tint settings
    local borderColor = profile.modules.optional.colorBorderSecondWind
    for _, border in ipairs(self.borders) do
        border:SetVertexColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end
end

--------------------------------------------------
-- Visibility
--------------------------------------------------
function SecondWindModule:SetActive(active)
    -- Show or hide the SecondWind frame based on 'active' and module enable setting
    local show = active and SkyridingUI.db.profile.modules.optional.enableSecondWind
    self.secondWindFrame:SetShown(show)

    if show then
        self.eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
        self.eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        self:UpdateState()
    else
        self.eventFrame:UnregisterAllEvents()
        self.secondWindFrame:SetScript("OnUpdate", nil)
    end
end

--------------------------------------------------
-- Update SecondWind Charges
--------------------------------------------------
function SecondWindModule:UpdateState()
    -- Get current information for SecondWind
    local chargeInfo = C_Spell.GetSpellCharges(SPELL_ID)

    -- If we can't get charge info or the module is disabled, don't run the update
    local runUpdate = chargeInfo and SkyridingUI.db.profile.modules.optional.enableSecondWind
    if not runUpdate then return end

    local currentCharges = chargeInfo.currentCharges
    local maxCharges = chargeInfo.maxCharges
    local start = chargeInfo.cooldownStartTime
    local duration = chargeInfo.cooldownDuration
    local now = GetTime()

    local needsOnUpdate = false
    
    
    --
    for i = 1, maxCharges do
        local fill = self.fills[i]
        local fullfill = self.fullfills[i]

        if i <= currentCharges then
            -- This slot is fully charged
            fullfill:SetAlpha(1)
            fill:SetAlpha(0)
                
            -- Check if this slot was previously not full → trigger pulse
            if not self.previousFullCharges[i] then
                PulseAnimationModule:PulseAlphaOnce(self.pulses[i], 0.75)
            end
            
            self.previousFullCharges[i] = true
        
        elseif i == currentCharges + 1 and duration and duration > 0 then
            -- This slot is currently recharging
            local progress = (now - start) / duration
            progress = math.min(progress, 1)

            fullfill:SetAlpha(0)
            fill:SetAlpha(1)

            -- Crop from bottom to top for progress
            local texTop = frameBottom - progress * (frameBottom - frameTop) -- top coordinate moves down as progress increases
            local texBottom = frameBottom -- bottom stays at bottom of frame

            fill:SetTexCoord(frameLeft, frameRight, texTop, texBottom)
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
        OnUpdateHandler:OnUpdateHandler(self.secondWindFrame, function()
            self:UpdateState()
        end)
    else
        self.secondWindFrame:SetScript("OnUpdate", nil)
    end
end

