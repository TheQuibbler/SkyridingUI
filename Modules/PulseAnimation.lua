local addonName, _ = ...
local SkyridingUI = LibStub("AceAddon-3.0"):GetAddon(addonName)

local PulseAnimationModule = SkyridingUI:NewModule("PulseAnimationModule")
local OnUpdateHandler = SkyridingUI:GetModule("OnUpdateHandlerModule")

--------------------------------------------------
-- Central pulse runner (infinite only)
--------------------------------------------------
function PulseAnimationModule:StartPulse(frame, onUpdate)
    -- Ensure only one pulse is running per frame
    self:StopPulse(frame)

    frame:Show()
    frame.pulseElapsed = 0

    -- Drive pulses via the centralized OnUpdateHandler so cadence respects updatesPerSecond
    OnUpdateHandler:OnUpdateHandler(frame, function(_, deltaTime)
        frame.pulseElapsed = (frame.pulseElapsed or 0) + deltaTime
        onUpdate(frame, frame.pulseElapsed)
    end)
end

--------------------------------------------------
-- Pulse frame movement (horizontal/vertical)
--------------------------------------------------
function PulseAnimationModule:PulseMovement(frame, leftTexture, rightTexture, amplitude, speed, leftBaseX, leftBaseY, leftBaseAnchor, rightBaseX, rightBaseY, rightBaseAnchor)
    self:StartPulse(frame, function(_, elapsed)
        local offset = amplitude * math.sin(elapsed * speed)

        leftTexture:SetPoint("CENTER", leftBaseAnchor, "LEFT", leftBaseX - offset, leftBaseY)
        rightTexture:SetPoint("CENTER", rightBaseAnchor, "RIGHT", rightBaseX + offset, rightBaseY)
    end)
end

--------------------------------------------------
-- Pulse frame scale
--------------------------------------------------
function PulseAnimationModule:PulseScale(frame, minScale, maxScale, speed)
    self:StartPulse(frame, function(_, elapsed)
        local scale = minScale + (maxScale - minScale) * (0.5 * (1 + math.sin(elapsed * speed)))

        frame:SetScale(scale)
    end)
end

--------------------------------------------------
-- One-shot alpha pulse (1 → 0)
--------------------------------------------------
function PulseAnimationModule:PulseAlphaOnce(frame, duration)
    self:StartPulse(frame, function(_, elapsed)
        local progress = elapsed / duration
        frame:SetAlpha(1 - progress)

        if elapsed >= duration then
            self:StopPulse(frame)
        end
    end)
end

--------------------------------------------------
-- Pulse frame alpha (infinite)
--------------------------------------------------
function PulseAnimationModule:PulseAlpha(frame, minAlpha, maxAlpha, speed)
    self:StartPulse(frame, function(_, elapsed)
        local alpha = minAlpha + (maxAlpha - minAlpha) * (0.5 * (1 + math.sin(elapsed * speed)))
        frame:SetAlpha(alpha)
    end)
end

--------------------------------------------------
-- Stop pulsing
--------------------------------------------------
function PulseAnimationModule:StopPulse(frame)
    frame:SetScript("OnUpdate", nil)
    frame.pulseElapsed = nil
    frame.elapsed = nil
    frame:Hide()
end
