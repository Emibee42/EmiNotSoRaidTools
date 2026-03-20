local POWER_INFUSION_SPELLS = {
    [10060]  = 10, -- Power Infusion
    [45257]  = 10, -- Power Infusion (alternate)
}

local powerInfusionActive = false
local powerInfusionEndTime = 0

-- Power Infusion Icon Frame
local powerInfusionIcon = CreateFrame("Frame", "EmiPowerInfusionIcon", UIParent, "BackdropTemplate")
powerInfusionIcon:SetSize(80, 80)
powerInfusionIcon:SetPoint("CENTER", 0, 300)
powerInfusionIcon:SetMovable(true)
powerInfusionIcon:SetClampedToScreen(true)
powerInfusionIcon:EnableMouse(true)
powerInfusionIcon:RegisterForDrag("LeftButton")
powerInfusionIcon:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
powerInfusionIcon:SetBackdropColor(0, 0, 0, 0)

powerInfusionIcon:SetScript("OnDragStart", powerInfusionIcon.StartMoving)
powerInfusionIcon:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    if EmiNotSoRaidToolsDB then
        EmiNotSoRaidToolsDB.powerInfusionPosition = { point = point, x = x, y = y }
    end
end)

-- Icon texture
local powerInfusionTexture = powerInfusionIcon:CreateTexture(nil, "BACKGROUND")
powerInfusionTexture:SetAllPoints()
powerInfusionTexture:SetTexture(135924) -- Power Infusion icon (spell icon ID)

-- Timer text
local powerInfusionText = powerInfusionIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
powerInfusionText:SetPoint("CENTER")
powerInfusionText:SetTextColor(1, 1, 1)

powerInfusionIcon:Hide()

function Emi_UpdatePowerInfusionIconSize(size)
    if powerInfusionIcon then
        powerInfusionIcon:SetSize(size, size)
    end
end

function Emi_UpdatePowerInfusionLockState()
    local db = EmiNotSoRaidToolsDB
    if not db then return end

    if db.PowerInfusionEnabled then
        if not db.locked then
            powerInfusionIcon:EnableMouse(true)
            powerInfusionIcon:SetBackdropColor(0, 0, 0, 0.5)
            powerInfusionIcon:Show()
        else
            powerInfusionIcon:EnableMouse(false)
            powerInfusionIcon:SetBackdropColor(0, 0, 0, 0)
            if not powerInfusionActive then powerInfusionIcon:Hide() end
        end
    else
        powerInfusionIcon:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "PLAYER_ENTERING_WORLD" then
        Emi_UpdatePowerInfusionLockState()
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" and spellID then
        if unit ~= "player" then return end

        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.PowerInfusionEnabled and POWER_INFUSION_SPELLS[spellID] then
            powerInfusionActive = true
            powerInfusionEndTime = GetTime() + POWER_INFUSION_SPELLS[spellID]
            powerInfusionIcon:Show()
        end
    end
end)

powerInfusionIcon:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.PowerInfusionEnabled then
        self:Hide()
        return
    end

    if powerInfusionActive then
        local remaining = powerInfusionEndTime - GetTime()
        if remaining > 0 then
            powerInfusionText:SetFormattedText("%.1f", remaining)
        else
            powerInfusionActive = false
            if db.locked then self:Hide() end
        end
    elseif not db.locked then
        powerInfusionText:SetText("TEST")
    end
end)
