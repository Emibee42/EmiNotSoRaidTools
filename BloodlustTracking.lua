local ADDON_NAME = "EmiNotSoRaidTools"

local LUST_SPELLS = {
    [2825]   = 40, -- Bloodlust
    [32182]  = 40, -- Heroism
    [80353]  = 40, -- Time Warp
    [264667] = 40, -- Primal Rage
    [178207] = 40, -- Drums of Fury
    [230935] = 40, -- Drums of the Mountain
    [390386] = 40, -- Fury of the Aspects
    [444257] = 40, -- Interdimensional Power Bank
}

local lustActive = false
local lustEndTime = 0

-- Normal Bloodlust Icon Frame
local normalLustIcon = CreateFrame("Frame", "EmiNormalLustIcon", UIParent, "BackdropTemplate")
normalLustIcon:SetSize(80, 80)
normalLustIcon:SetPoint("CENTER", 0, 200)
normalLustIcon:SetMovable(true)
normalLustIcon:SetClampedToScreen(true)
normalLustIcon:EnableMouse(true)
normalLustIcon:RegisterForDrag("LeftButton")

normalLustIcon:SetScript("OnDragStart", normalLustIcon.StartMoving)
normalLustIcon:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, _, x, y = self:GetPoint()
    if EmiNotSoRaidToolsDB then
        EmiNotSoRaidToolsDB.lustPosition = { point = point, x = x, y = y }
    end
end)

-- Icon texture
local lustIconTexture = normalLustIcon:CreateTexture(nil, "BACKGROUND")
lustIconTexture:SetAllPoints()
lustIconTexture:SetTexture(136012) -- Bloodlust icon (spell icon ID)

-- Timer text (CENTERED)
local lustIconText = normalLustIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
lustIconText:SetPoint("CENTER")
lustIconText:SetTextColor(1, 1, 1)

normalLustIcon:Hide()

function Emi_UpdateLustIconSize(size)
    if normalLustIcon then
        normalLustIcon:SetSize(size, size)
    end
end

function Emi_TestLust()
    lustActive = true
    lustEndTime = GetTime() + 10
    normalLustIcon:Show()
    
    if not EmiNotSoRaidToolsDB or not EmiNotSoRaidToolsDB.LustPedroEnabled then
        ResetPedroAnimation()
        pedroLustGifFrame:Show()
    end
end

function Emi_UpdateLustLockState()
    local db = EmiNotSoRaidToolsDB
    if not db then return end

    -- ======================
    -- PEDRO HANDLING
    -- ======================
    if db.LustPedroEnabled then
        if not db.locked and pedroLustGifFrame then
            pedroLustGifFrame:EnableMouse(true)
            pedroLustGifFrame:SetBackdropColor(0, 0, 0, 0.5)
            ResetPedroAnimation()
            pedroLustGifFrame:Show()
        else
            pedroLustGifFrame:EnableMouse(false)
            pedroLustGifFrame:SetBackdropColor(0, 0, 0, 0)
            if not lustActive then pedroLustGifFrame:Hide() end
        end
    else
        pedroLustGifFrame:Hide()
    end

    -- ======================
    -- NORMAL ICON HANDLING
    -- ======================
    if db.LustIconEnabled then
        if not db.locked then
            normalLustIcon:EnableMouse(true)
            normalLustIcon:SetBackdropColor(0, 0, 0, 0.5)
            normalLustIcon:Show()
        else
            normalLustIcon:EnableMouse(false)
            normalLustIcon:SetBackdropColor(0, 0, 0, 0)
            if not lustActive then normalLustIcon:Hide() end
        end
    else
        normalLustIcon:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "PLAYER_ENTERING_WORLD" then
        Emi_UpdateLustLockState()
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" and spellID then
        if unit ~= "player" then return end

        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.LustIconEnabled then
            if LUST_SPELLS[spellID] then
                lustActive = true
                lustEndTime = GetTime() + LUST_SPELLS[spellID]

                -- PEDRO
                if EmiNotSoRaidToolsDB.LustPedroEnabled then
                    ResetPedroAnimation()
                    pedroLustGifFrame:Show()
                end

                -- NORMAL ICON
                if EmiNotSoRaidToolsDB.LustIconEnabled then
                    normalLustIcon:Show()
                end
            end
        end
    end
end)

normalLustIcon:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.LustIconEnabled then
        self:Hide()
        return
    end

    if lustActive then
        local remaining = lustEndTime - GetTime()
        if remaining > 0 then
            lustIconText:SetFormattedText("%.1f", remaining)
        else
            lustActive = false
            if db.locked then self:Hide() end
        end
    elseif not db.locked then
        lustIconText:SetText("TEST")
    end
end)