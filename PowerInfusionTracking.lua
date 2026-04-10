local powerInfusionIcon
local powerInfusionResizeHandles = {}
local POWER_INFUSION_MIN_SIZE = 24
local POWER_INFUSION_MAX_SIZE = 400

local lastWhisperTime = 0
local piAlertActive = false
local whisperTimer = nil
local WHISPER_COOLDOWN = 5
local POWER_INFUSION_ALERT_DURATION = 3

local function IsPowerInfusionWhisper(message)
    if not message then
        return false
    end
    local lower = message:lower()
    return lower:find("%f[%a]pi%f[%A]") ~= nil
end

local function ShowPowerInfusionWhisperAlert()
    if whisperTimer then
        whisperTimer:Cancel()
        whisperTimer = nil
    end

    piAlertActive = true
    local text = (EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertText) or "PI"
    powerInfusionText:SetText(text)
    powerInfusionIcon:Show()

    whisperTimer = C_Timer.NewTimer(POWER_INFUSION_ALERT_DURATION, function()
        piAlertActive = false
        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.locked then
            powerInfusionIcon:Hide()
        else
            powerInfusionText:SetText("")
        end
    end)
end

local function SavePowerInfusionState()
    if not EmiNotSoRaidToolsDB then
        return
    end

    local point, _, _, x, y = powerInfusionIcon:GetPoint()
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertPosition = { point = point, x = x, y = y }
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertSize = math.floor(powerInfusionIcon:GetWidth() + 0.5)
end

local function SetPowerInfusionResizeHandlesVisible(visible)
    for _, handle in ipairs(powerInfusionResizeHandles) do
        handle:SetShown(visible)
    end
end

-- Power Infusion Icon Frame
powerInfusionIcon = CreateFrame("Frame", "EmiPowerInfusionIcon", UIParent, "BackdropTemplate")
powerInfusionIcon:SetSize(80, 80)
powerInfusionIcon:SetPoint("CENTER", 0, 300)
powerInfusionIcon:SetMovable(true)
powerInfusionIcon:SetResizable(true)
if powerInfusionIcon.SetResizeBounds then
    powerInfusionIcon:SetResizeBounds(POWER_INFUSION_MIN_SIZE, POWER_INFUSION_MIN_SIZE, POWER_INFUSION_MAX_SIZE, POWER_INFUSION_MAX_SIZE)
end
powerInfusionIcon:SetClampedToScreen(true)
powerInfusionIcon:EnableMouse(true)
powerInfusionIcon:RegisterForDrag("LeftButton")
powerInfusionIcon:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
powerInfusionIcon:SetBackdropColor(0, 0, 0, 0)

local powerInfusionAspectAdjusting = false
powerInfusionIcon:SetScript("OnSizeChanged", function(self, width, height)
    if powerInfusionAspectAdjusting or not IsShiftKeyDown() then
        return
    end

    local size = math.max(width, height)
    size = math.max(POWER_INFUSION_MIN_SIZE, math.min(POWER_INFUSION_MAX_SIZE, size))
    powerInfusionAspectAdjusting = true
    self:SetSize(size, size)
    powerInfusionAspectAdjusting = false
end)

powerInfusionIcon:SetScript("OnDragStart", powerInfusionIcon.StartMoving)
powerInfusionIcon:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePowerInfusionState()
end)

local function CreatePowerInfusionResizeHandle(point)
    local handle = CreateFrame("Button", nil, powerInfusionIcon, "BackdropTemplate")
    handle:SetSize(5, 5)
    handle:SetPoint(point, powerInfusionIcon, point, 0, 0)
    handle:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
    handle:SetBackdropColor(1, 1, 1, 0.9)
    handle:Hide()
    handle:SetFrameStrata("TOOLTIP")
    handle:SetScript("OnMouseDown", function()
        if EmiNotSoRaidToolsDB and not EmiNotSoRaidToolsDB.locked then
            powerInfusionIcon:StartSizing(point)
        end
    end)
    handle:SetScript("OnMouseUp", function()
        powerInfusionIcon:StopMovingOrSizing()
        SavePowerInfusionState()
    end)
    powerInfusionResizeHandles[#powerInfusionResizeHandles + 1] = handle
end

CreatePowerInfusionResizeHandle("TOPLEFT")
CreatePowerInfusionResizeHandle("TOPRIGHT")
CreatePowerInfusionResizeHandle("BOTTOMLEFT")
CreatePowerInfusionResizeHandle("BOTTOMRIGHT")

-- Alert text
local powerInfusionText = powerInfusionIcon:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
powerInfusionText:SetPoint("CENTER")
powerInfusionText:SetTextColor(1, 1, 1)

powerInfusionIcon:Hide()

function Emi_UpdatePowerInfusionIconSize(size)
    if powerInfusionIcon then
        powerInfusionIcon:SetSize(size, size)
        SavePowerInfusionState()
    end
end

function Emi_UpdatePowerInfusionLockState()
    local db = EmiNotSoRaidToolsDB
    if not db then return end

    if db.PowerInfusionWhisperAlertEnabled then
        if not db.locked then
            powerInfusionIcon:EnableMouse(true)
            powerInfusionIcon:SetBackdropColor(0, 0, 0, 0.5)
            SetPowerInfusionResizeHandlesVisible(true)
            powerInfusionIcon:Show()
        else
            powerInfusionIcon:EnableMouse(false)
            powerInfusionIcon:SetBackdropColor(0, 0, 0, 0)
            SetPowerInfusionResizeHandlesVisible(false)
            if not piAlertActive then
                powerInfusionIcon:Hide()
            end
        end
    else
        SetPowerInfusionResizeHandlesVisible(false)
        powerInfusionIcon:Hide()
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if EmiNotSoRaidToolsDB then
            local p = EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertPosition or { point = "CENTER", x = 0, y = 300 }
            powerInfusionIcon:ClearAllPoints()
            powerInfusionIcon:SetPoint(p.point, p.x, p.y)

            local size = EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertSize or 80
            powerInfusionIcon:SetSize(size, size)
        end
        Emi_UpdatePowerInfusionLockState()

    elseif event == "CHAT_MSG_WHISPER" then
        local message, sender = ...
        if EmiNotSoRaidToolsDB and EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled and UnitAffectingCombat("player") and message and IsPowerInfusionWhisper(message) then
            local currentTime = GetTime()
            if currentTime - lastWhisperTime >= WHISPER_COOLDOWN then
                lastWhisperTime = currentTime
                ShowPowerInfusionWhisperAlert()
                PlaySound(SOUNDKIT.RAID_WARNING, "Master")
            end
        end
    end
end)

powerInfusionIcon:SetScript("OnUpdate", function(self, elapsed)
    local db = EmiNotSoRaidToolsDB
    if not db or not db.PowerInfusionWhisperAlertEnabled then
        self:Hide()
        return
    end

    if piAlertActive then
        return
    elseif not db.locked then
        powerInfusionText:SetText("")
        self:Show()
    else
        self:Hide()
    end
end)
