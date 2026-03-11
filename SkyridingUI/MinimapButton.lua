-- MinimapButton module - uses LibDataBroker/LibDBIcon when available
local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local MinimapModule = SkyridingUI:NewModule("MinimapModule")
local aceDialog = LibStub("AceConfigDialog-3.0")


--------------------------------------------------
-- Initialization
--------------------------------------------------
function MinimapModule:OnInitialize()
    -- Prepare compartment entry data
    self.compartmentData = {
        text = "SkyridingUI",
        icon = "Interface\\Icons\\ability_dragonriding_dragonridinggliding01",
        notCheckable = true,
        registerForAnyClick = true,
        func = function(_, menuInputData)
            -- Open the full AceConfig options panel on click
            aceDialog:Open("Skyriding UI Full")
        end,
        funcOnEnter = function()
            GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
            GameTooltip:AddLine("SkyridingUI")
            GameTooltip:AddLine("Left-click: Open Options", 1, 1, 1)
            GameTooltip:Show()
        end,
        funcOnLeave = function()
            GameTooltip:Hide()
        end,
    }

    -- Apply initial visibility from settings (register with AddonCompartmentFrame if enabled)
    self:Refresh()
end

--------------------------------------------------
-- Refresh (show/hide based on options)
--------------------------------------------------
function MinimapModule:Refresh()
    local show = SkyridingUI.db.profile.enableMinimap

    if show then
        -- Register if not already registered
        if not self._compartmentRegistered then
            AddonCompartmentFrame:RegisterAddon(self.compartmentData)
            self._compartmentRegistered = true
        end
    else
        -- Remove entry if registered
        if self._compartmentRegistered then
            -- Find and remove our entry from AddonCompartmentFrame.registeredAddons
            for i = 1, #AddonCompartmentFrame.registeredAddons do
                if AddonCompartmentFrame.registeredAddons[i] == self.compartmentData then
                    table.remove(AddonCompartmentFrame.registeredAddons, i)
                    AddonCompartmentFrame:UpdateDisplay()
                    break
                end
            end
            self._compartmentRegistered = nil
        end
    end
end


