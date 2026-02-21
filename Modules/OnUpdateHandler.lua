local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local OnUpdateHandlerModule = SkyridingUI:NewModule("OnUpdateHandlerModule")

--------------------------------------------------
--- OnUpdate handler for modules that require frequent updates (e.g. Vigor)
--- This centralizes the update logic and ensures consistent timing across modules.
--------------------------------------------------
function OnUpdateHandlerModule:OnUpdateHandler(frame, onUpdate)
    frame:SetScript("OnUpdate", function(_, deltaTime)
            -- Accumulate elapsed time per-frame
            frame.elapsed = (frame.elapsed or 0) + deltaTime

            local updatesPerSecond = SkyridingUI.db.profile.updatesPerSecond or 30
            local interval = 1 / updatesPerSecond
            
            if frame.elapsed >= interval then
                -- Keep remainder to avoid drift; provide stable tick delta to callback
                frame.elapsed = frame.elapsed % interval
                onUpdate(frame, interval)
        end
    end)    
end
