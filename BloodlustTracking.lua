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
local normalLustIcon

local function SaveLustIconState()
    if not EmiNotSoRaidToolsDB then
        return
    end

    local point, _, _, x, y = normalLustIcon:GetPoint()
    EmiNotSoRaidToolsDB.lustPosition = { point = point, x = x, y = y }
    EmiNotSoRaidToolsDB.lustSize = math.floor(normalLustIcon:GetWidth() + 0.5)
end

local function SetLustState(active, endTime)
    lustActive = active
    lustEndTime = endTime or 0
    if Emi_SetPedroLustState then
        Emi_SetPedroLustState(lustActive, lustEndTime)
    end
end

function Emi_GetLustState()
    return lustActive, lustEndTime
end

-- Normal Bloodlust Icon Frame
normalLustIcon = CreateFrame("Frame", "EmiNormalLustIcon", UIParent, "BackdropTemplate")
normalLustIcon:SetSize(80, 80)
normalLustIcon:SetPoint("CENTER", 0, 200)
normalLustIcon:SetMovable(true)
normalLustIcon:SetResizable(true)
if normalLustIcon.SetResizeBounds then
    normalLustIcon:SetResizeBounds(40, 40, 400, 400)
end
normalLustIcon:SetClampedToScreen(true)
normalLustIcon:EnableMouse(true)
normalLustIcon:RegisterForDrag("LeftButton")
normalLustIcon:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
normalLustIcon:SetBackdropColor(0, 0, 0, 0)

normalLustIcon:SetScript("OnDragStart", normalLustIcon.StartMoving)
normalLustIcon:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveLustIconState()
end)

local lustResizeHandles = {}

local function CreateLustResizeHandle(point)
    local handle = CreateFrame("Button", nil, normalLustIcon, "BackdropTemplate")
    handle:SetSize(10, 10)
    handle:SetPoint(point, normalLustIcon, point, 0, 0)
    handle:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
    handle:SetBackdropColor(1, 1, 1, 0.9)
    handle:Hide()
    handle:SetFrameStrata("TOOLTIP")
    handle:SetScript("OnMouseDown", function()
        if EmiNotSoRaidToolsDB and not EmiNotSoRaidToolsDB.locked then
            normalLustIcon:StartSizing(point)
        end
    end)
    handle:SetScript("OnMouseUp", function()
        normalLustIcon:StopMovingOrSizing()
        SaveLustIconState()
    end)
    lustResizeHandles[#lustResizeHandles + 1] = handle
end

local function SetLustResizeHandlesVisible(visible)
    for _, handle in ipairs(lustResizeHandles) do
        handle:SetShown(visible)
    end
end

CreateLustResizeHandle("TOPLEFT")
CreateLustResizeHandle("TOPRIGHT")
CreateLustResizeHandle("BOTTOMLEFT")
CreateLustResizeHandle("BOTTOMRIGHT")

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
        SaveLustIconState()
    end
end

function Emi_TestLust()
    SetLustState(true, GetTime() + 10)

    if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.lustIconEnabled then
        normalLustIcon:Show()
    end

    if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.lustPedroEnabled and pedroLustGifFrame then
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
    if db.lustPedroEnabled and pedroLustGifFrame then
        if not db.locked and pedroLustGifFrame then
            pedroLustGifFrame:EnableMouse(true)
            pedroLustGifFrame:SetBackdropColor(0, 0, 0, 0.5)
            if Emi_SetPedroResizeHandlesVisible then Emi_SetPedroResizeHandlesVisible(true) end
            ResetPedroAnimation()
            pedroLustGifFrame:Show()
        else
            pedroLustGifFrame:EnableMouse(false)
            pedroLustGifFrame:SetBackdropColor(0, 0, 0, 0)
            if Emi_SetPedroResizeHandlesVisible then Emi_SetPedroResizeHandlesVisible(false) end
            if not lustActive then pedroLustGifFrame:Hide() end
        end
    elseif pedroLustGifFrame then
        if Emi_SetPedroResizeHandlesVisible then Emi_SetPedroResizeHandlesVisible(false) end
        pedroLustGifFrame:Hide()
    end

    -- ======================
    -- NORMAL ICON HANDLING
    -- ======================
    if db.lustIconEnabled then
        if not db.locked then
            normalLustIcon:EnableMouse(true)
            normalLustIcon:SetBackdropColor(0, 0, 0, 0.5)
            SetLustResizeHandlesVisible(true)
            normalLustIcon:Show()
        else
            normalLustIcon:EnableMouse(false)
            normalLustIcon:SetBackdropColor(0, 0, 0, 0)
            SetLustResizeHandlesVisible(false)
            if not lustActive then normalLustIcon:Hide() end
        end
    else
        SetLustResizeHandlesVisible(false)
        normalLustIcon:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, unit, castGUID, spellID)
    if event == "PLAYER_ENTERING_WORLD" then
        if EmiNotSoRaidToolsDB then
            local p = EmiNotSoRaidToolsDB.lustPosition or { point = "CENTER", x = 0, y = 200 }
            normalLustIcon:ClearAllPoints()
            normalLustIcon:SetPoint(p.point, p.x, p.y)

            local size = EmiNotSoRaidToolsDB.lustSize or 80
            normalLustIcon:SetSize(size, size)
        end
        Emi_UpdateLustLockState()
    end

    if event == "UNIT_SPELLCAST_SUCCEEDED" and spellID then
        if unit ~= "player" then return end

        if EmiNotSoRaidToolsDB and LUST_SPELLS[spellID] then
            if EmiNotSoRaidToolsDB.lustIconEnabled or EmiNotSoRaidToolsDB.lustPedroEnabled then
                SetLustState(true, GetTime() + LUST_SPELLS[spellID])

                -- PEDRO
                if EmiNotSoRaidToolsDB.lustPedroEnabled and pedroLustGifFrame then
                    ResetPedroAnimation()
                    pedroLustGifFrame:Show()
                end

                -- NORMAL ICON
                if EmiNotSoRaidToolsDB.lustIconEnabled then
                    normalLustIcon:Show()
                end
            end
        end
    end
end)

normalLustIcon:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.lustIconEnabled then
        self:Hide()
        return
    end

    if lustActive then
        local remaining = lustEndTime - GetTime()
        if remaining > 0 then
            lustIconText:SetFormattedText("%.1f", remaining)
        else
            SetLustState(false, 0)
            if db.locked then self:Hide() end
        end
    elseif not db.locked then
        lustIconText:SetText("TEST")
    end
end)