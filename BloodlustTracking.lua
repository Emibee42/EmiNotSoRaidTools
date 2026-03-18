local ADDON_NAME = "EmiNotSoRaidTools"

-- Expanded Spell List from your WeakAura export
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
lustGifTexture:SetTexCoord(0, 1, 0, 1)


-- Animation Settings from WeakAura Export
local COLS, ROWS = 4, 8
local TOTAL_FRAMES = COLS * ROWS
local FRAME_DURATION = 1 / 6 -- Set to 6 FPS as per WeakAura
local currentFrame = 0
local timeSinceLastUpdate = 0
local TEX_WIDTH = 768
local TEX_HEIGHT = 1536

local FRAME_WIDTH = TEX_WIDTH / COLS
local FRAME_HEIGHT = TEX_HEIGHT / ROWS

local function UpdateAnimation(elapsed)
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed

    while timeSinceLastUpdate >= FRAME_DURATION do
        timeSinceLastUpdate = timeSinceLastUpdate - FRAME_DURATION

        currentFrame = (currentFrame + 1) % TOTAL_FRAMES

        local col = currentFrame % COLS
        local row = math.floor(currentFrame / COLS)

        -- Convert pixel coords → UV
        local left = (col * FRAME_WIDTH) / TEX_WIDTH
        local right = ((col + 1) * FRAME_WIDTH) / TEX_WIDTH
        local top = (row * FRAME_HEIGHT) / TEX_HEIGHT
        local bottom = ((row + 1) * FRAME_HEIGHT) / TEX_HEIGHT

        -- Flip vertically (WoW)
        lustGifTexture:SetTexCoord(left, right, top, bottom)
    end
end

-- Dragging Logic
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
    if lustGifFrame then
        lustGifFrame:SetSize(size, size)
    end
end

function Emi_TestLust()
    lustActive = true
    lustEndTime = GetTime() + 10
    lustGifFrame:Show()
end

function Emi_UpdateLustLockState()
    local db = EmiNotSoRaidToolsDB
    if not db then return end
    if not db.locked then
        lustGifFrame:EnableMouse(true)
        lustGifFrame:SetBackdropColor(0, 0, 0, 0.5)
        lustGifFrame:Show() 
    else
        lustGifFrame:EnableMouse(false)
        lustGifFrame:SetBackdropColor(0, 0, 0, 0)
        if not lustActive then lustGifFrame:Hide() end
    end
end

local function ResetAnimation()
    currentFrame = 0
    timeSinceLastUpdate = 0
    -- Manually set the UVs for the very first frame (Frame 0)
    local left = 0
    local right = FRAME_WIDTH / TEX_WIDTH
    local top = 0
    local bottom = FRAME_HEIGHT / TEX_HEIGHT
    lustGifTexture:SetTexCoord(left, right, top, bottom)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if EmiNotSoRaidToolsDB then
            if EmiNotSoRaidToolsDB.lustPosition then
                local p = EmiNotSoRaidToolsDB.lustPosition
                lustGifFrame:ClearAllPoints()
                lustGifFrame:SetPoint(p.point, p.x, p.y)
            else
                lustGifFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
            end
            if EmiNotSoRaidToolsDB.lustSize then
                Emi_UpdateLustSize(EmiNotSoRaidToolsDB.lustSize)
            end
        end
        ResetAnimation()
        return
    end

    local _, _, spellID = ...
    if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.BloodlustTrackingEnabled then
        if LUST_SPELLS[spellID] then
            lustActive = true
            lustEndTime = GetTime() + LUST_SPELLS[spellID]
            lustGifFrame:Show()
        end
    end
end)

lustGifFrame:SetScript("OnUpdate", function(self, elapsed)
    if lustActive or (EmiNotSoRaidToolsDB and not EmiNotSoRaidToolsDB.locked) then
        UpdateAnimation(elapsed)
    end
    
    if lustActive and GetTime() > lustEndTime then
        lustActive = false
        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.locked then
            self:Hide()
        end
    end
end)