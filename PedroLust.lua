local lustActive = false
local lustEndTime = 0

function Emi_SetPedroLustState(active, endTime)
    lustActive = active
    lustEndTime = endTime or 0
end

if Emi_GetLustState then
    lustActive, lustEndTime = Emi_GetLustState()
end

pedroLustGifFrame = CreateFrame("Frame", "EmipedroLustGifFrame", UIParent, "BackdropTemplate")
pedroLustGifFrame:SetSize(200, 200)
pedroLustGifFrame:SetMovable(true)
pedroLustGifFrame:SetClampedToScreen(true)
pedroLustGifFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
pedroLustGifFrame:SetBackdropColor(0, 0, 0, 0)
pedroLustGifFrame:Hide()

local lustGifTexture = pedroLustGifFrame:CreateTexture(nil, "OVERLAY")
lustGifTexture:SetAllPoints()
lustGifTexture:SetTexture("Interface\\AddOns\\EmiNotSoRaidTools\\media\\pedro.tga")

local lustTimerText = pedroLustGifFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
lustTimerText:SetPoint("BOTTOM", pedroLustGifFrame, "TOP", 0, 5)
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

local function SetAnimationFrame(frameIdx)
    local col = frameIdx % COLS
    local row = math.floor(frameIdx / COLS)
    local left = (col * FRAME_WIDTH) / TEX_WIDTH
    local right = ((col + 1) * FRAME_WIDTH) / TEX_WIDTH
    local top = (row * FRAME_HEIGHT) / TEX_HEIGHT
    local bottom = ((row + 1) * FRAME_HEIGHT) / TEX_HEIGHT
    lustGifTexture:SetTexCoord(left, right, top, bottom)
end

function ResetPedroAnimation()
    local p = EmiNotSoRaidToolsDB.lustPedroPosition or {point="CENTER", x=0, y=200}
    pedroLustGifFrame:ClearAllPoints()
    pedroLustGifFrame:SetPoint(p.point, p.x, p.y)

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

pedroLustGifFrame:RegisterForDrag("LeftButton")
pedroLustGifFrame:SetScript("OnDragStart", pedroLustGifFrame.StartMoving)
pedroLustGifFrame:SetScript("OnDragStop", function()
    pedroLustGifFrame:StopMovingOrSizing()
    local point, _, _, x, y = pedroLustGifFrame:GetPoint()
    if EmiNotSoRaidToolsDB then
        EmiNotSoRaidToolsDB.lustPedroPosition = { point = point, x = x, y = y }
    end
end)

function Emi_UpdateLustSize(size)
    if pedroLustGifFrame then pedroLustGifFrame:SetSize(size, size) end
end

pedroLustGifFrame:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.lustPedroEnabled then
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