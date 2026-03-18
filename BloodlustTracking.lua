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

local lustGifFrame = CreateFrame("Frame", "EmiLustGifFrame", UIParent, "BackdropTemplate")
lustGifFrame:SetSize(200, 200)
lustGifFrame:SetMovable(true)
lustGifFrame:SetClampedToScreen(true)
lustGifFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
lustGifFrame:SetBackdropColor(0, 0, 0, 0)
lustGifFrame:Hide()

local lustGifTexture = lustGifFrame:CreateTexture(nil, "OVERLAY")
lustGifTexture:SetAllPoints()
lustGifTexture:SetTexture("Interface\\AddOns\\EmiNotSoRaidTools\\media\\pedro.tga")

-- NEW: Timer Text
local lustTimerText = lustGifFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
lustTimerText:SetPoint("BOTTOM", lustGifFrame, "TOP", 0, 5)
lustTimerText:SetTextColor(1, 1, 1)

local COLS, ROWS = 4, 8
local TOTAL_FRAMES = COLS * ROWS
local FRAME_DURATION = 1 / 6 
local currentFrame = 0
local timeSinceLastUpdate = 0
local TEX_WIDTH = 768
local TEX_HEIGHT = 1536
local FRAME_WIDTH = TEX_WIDTH / COLS
local FRAME_HEIGHT = TEX_HEIGHT / ROWS

-- FIX: Function to set specific frame UVs immediately
local function SetAnimationFrame(frameIdx)
    local col = frameIdx % COLS
    local row = math.floor(frameIdx / COLS)
    local left = (col * FRAME_WIDTH) / TEX_WIDTH
    local right = ((col + 1) * FRAME_WIDTH) / TEX_WIDTH
    local top = (row * FRAME_HEIGHT) / TEX_HEIGHT
    local bottom = ((row + 1) * FRAME_HEIGHT) / TEX_HEIGHT
    lustGifTexture:SetTexCoord(left, right, top, bottom)
end

local function ResetAnimation()
    currentFrame = 0
    timeSinceLastUpdate = 0
    SetAnimationFrame(0)
end

local function UpdateAnimation(elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    while timeSinceLastUpdate >= FRAME_DURATION do
        timeSinceLastUpdate = timeSinceLastUpdate - FRAME_DURATION
        currentFrame = (currentFrame + 1) % TOTAL_FRAMES
        SetAnimationFrame(currentFrame)
    end
end

lustGifFrame:RegisterForDrag("LeftButton")
lustGifFrame:SetScript("OnDragStart", lustGifFrame.StartMoving)
lustGifFrame:SetScript("OnDragStop", function()
    lustGifFrame:StopMovingOrSizing()
    local point, _, _, x, y = lustGifFrame:GetPoint()
    if EmiNotSoRaidToolsDB then
        EmiNotSoRaidToolsDB.lustPosition = { point = point, x = x, y = y }
    end
end)

function Emi_UpdateLustSize(size)
    if lustGifFrame then lustGifFrame:SetSize(size, size) end
end

function Emi_TestLust()
    lustActive = true
    lustEndTime = GetTime() + 10
    ResetAnimation()
    lustGifFrame:Show()
end

function Emi_UpdateLustLockState()
    local db = EmiNotSoRaidToolsDB
    if not db or not db.BloodlustTrackingEnabled then 
        lustGifFrame:Hide()
        return 
    end
    
    if not db.locked then
        lustGifFrame:EnableMouse(true)
        lustGifFrame:SetBackdropColor(0, 0, 0, 0.5)
        ResetAnimation()
        lustGifFrame:Show() 
    else
        lustGifFrame:EnableMouse(false)
        lustGifFrame:SetBackdropColor(0, 0, 0, 0)
        if not lustActive then lustGifFrame:Hide() end
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, unitTarget, castGUID, spellID)
    if event == "PLAYER_ENTERING_WORLD" then
        if EmiNotSoRaidToolsDB then
            local p = EmiNotSoRaidToolsDB.lustPosition or {point="CENTER", x=0, y=200}
            lustGifFrame:ClearAllPoints()
            lustGifFrame:SetPoint(p.point, p.x, p.y)
            ResetAnimation()
        end
        return
    end

    -- Check if spellID exists before using it as a table key
    if event == "UNIT_SPELLCAST_SUCCEEDED" and spellID then
        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.BloodlustTrackingEnabled then
            if LUST_SPELLS[spellID] then
                lustActive = true
                lustEndTime = GetTime() + LUST_SPELLS[spellID]
                ResetAnimation()
                lustGifFrame:Show()
            end
        end
    end
end)

lustGifFrame:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.BloodlustTrackingEnabled then
        self:Hide()
        return
    end

    if lustActive then
        UpdateAnimation(elapsed)
        local remaining = lustEndTime - GetTime()
        if remaining > 0 then
            lustTimerText:SetFormattedText("%.1fs", remaining)
        else
            lustActive = false
            if db.locked then self:Hide() end
        end
    elseif not db.locked then
        UpdateAnimation(elapsed)
        lustTimerText:SetText("TEST")
    end
end)