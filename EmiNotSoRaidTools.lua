local ADDON_NAME = "EmiNotSoRaidTools"
local DEFAULT_ALIVE_TEXT = "I am the best"
local DEFAULT_DEAD_TEXT = "I have fallen..."

EmiNSRT = EmiNSRT or {}

local FONT_TABLE = {
    FRIZQT = "Fonts\\FRIZQT__.TTF",
    ARIAL = "Fonts\\ARIALN.TTF",
    MORPHEUS = "Fonts\\MORPHEUS.TTF",
    SKURRI = "Fonts\\SKURRI.TTF",
}

local function InitializeDatabaseDefaults()
    EmiNotSoRaidToolsDB = EmiNotSoRaidToolsDB or {}
    EmiNotSoRaidToolsDB.textEnabled = (EmiNotSoRaidToolsDB.textEnabled == nil) and true or EmiNotSoRaidToolsDB.textEnabled
    EmiNotSoRaidToolsDB.aliveText = EmiNotSoRaidToolsDB.aliveText or DEFAULT_ALIVE_TEXT
    EmiNotSoRaidToolsDB.deadText = EmiNotSoRaidToolsDB.deadText or DEFAULT_DEAD_TEXT
    EmiNotSoRaidToolsDB.fontSize = EmiNotSoRaidToolsDB.fontSize or 32
    EmiNotSoRaidToolsDB.fontSize = math.max(8, math.min(120, EmiNotSoRaidToolsDB.fontSize))
    EmiNotSoRaidToolsDB.font = EmiNotSoRaidToolsDB.font or "FRIZQT"
    EmiNotSoRaidToolsDB.colorAlive = EmiNotSoRaidToolsDB.colorAlive or { r = 1, g = 1, b = 1 }
    EmiNotSoRaidToolsDB.colorDead = EmiNotSoRaidToolsDB.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
    EmiNotSoRaidToolsDB.locked = (EmiNotSoRaidToolsDB.locked == nil) and true or EmiNotSoRaidToolsDB.locked
    EmiNotSoRaidToolsDB.position = EmiNotSoRaidToolsDB.position or { point = "CENTER", x = 0, y = 0 }
    EmiNotSoRaidToolsDB.petReminderEnabled = (EmiNotSoRaidToolsDB.petReminderEnabled == nil) and false or EmiNotSoRaidToolsDB.petReminderEnabled
    EmiNotSoRaidToolsDB.petReminderPosition = EmiNotSoRaidToolsDB.petReminderPosition or { point = "CENTER", x = 0, y = 100 }
    EmiNotSoRaidToolsDB.blackInkyReminderEnabled = (EmiNotSoRaidToolsDB.blackInkyReminderEnabled == nil) and false or EmiNotSoRaidToolsDB.blackInkyReminderEnabled
    EmiNotSoRaidToolsDB.blackInkyReminderPosition = EmiNotSoRaidToolsDB.blackInkyReminderPosition or { point = "CENTER", x = 0, y = 150 }
    EmiNotSoRaidToolsDB.blackInkyZoneIDs = EmiNotSoRaidToolsDB.blackInkyZoneIDs or {}
    EmiNotSoRaidToolsDB.lustIconEnabled = (EmiNotSoRaidToolsDB.lustIconEnabled == nil) and true or EmiNotSoRaidToolsDB.lustIconEnabled
    EmiNotSoRaidToolsDB.lustPosition = EmiNotSoRaidToolsDB.lustPosition or { point = "CENTER", x = 0, y = 200 }
    EmiNotSoRaidToolsDB.lustSize = EmiNotSoRaidToolsDB.lustSize or 34
    EmiNotSoRaidToolsDB.lustPedroEnabled = (EmiNotSoRaidToolsDB.lustPedroEnabled == nil) and true or EmiNotSoRaidToolsDB.lustPedroEnabled
    EmiNotSoRaidToolsDB.lustPedroPosition = EmiNotSoRaidToolsDB.lustPedroPosition or { point = "CENTER", x = 0, y = 200 }
    EmiNotSoRaidToolsDB.lustPedroSize = EmiNotSoRaidToolsDB.lustPedroSize or 120
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled = (EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled == nil) and false or EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertText = EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertText or "PI"
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertPosition = EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertPosition or { point = "CENTER", x = 0, y = 300 }
    EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertSize = EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertSize or 80
end

local displayFrame = CreateFrame("Frame", ADDON_NAME .. "_Display", UIParent, "BackdropTemplate")
displayFrame:SetSize(1, 1)
displayFrame:SetPoint("CENTER")
displayFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
displayFrame:SetBackdropColor(0, 0, 0, 0)
displayFrame:SetBackdropBorderColor(1, 1, 1, 0)
displayFrame:SetMovable(false)
displayFrame:EnableMouse(false)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart", displayFrame.StartMoving)
displayFrame:SetScript("OnDragStop", function()
    displayFrame:StopMovingOrSizing()
    local point, _, _, x, y = displayFrame:GetPoint()
    EmiNotSoRaidToolsDB.position = { point = point, x = x, y = y }
end)

local displayText = displayFrame:CreateFontString(nil, "OVERLAY")
displayText:SetPoint("CENTER")

local petReminderFrame = CreateFrame("Frame", ADDON_NAME .. "_PetDisplay", UIParent, "BackdropTemplate")
petReminderFrame:SetSize(200, 50)
petReminderFrame:SetMovable(true)
petReminderFrame:EnableMouse(false)
petReminderFrame:RegisterForDrag("LeftButton")
petReminderFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
petReminderFrame:SetBackdropColor(0, 0, 0, 0)
petReminderFrame:SetScript("OnDragStart", petReminderFrame.StartMoving)
petReminderFrame:SetScript("OnDragStop", function()
    petReminderFrame:StopMovingOrSizing()
    local point, _, _, x, y = petReminderFrame:GetPoint()
    EmiNotSoRaidToolsDB.petReminderPosition = { point = point, x = x, y = y }
end)

local petReminderText = petReminderFrame:CreateFontString(nil, "OVERLAY")
petReminderText:SetPoint("CENTER", petReminderFrame, "CENTER")
petReminderText:SetFont("Fonts\\FRIZQT__.TTF", 40, "OUTLINE")
petReminderText:SetTextColor(1, 0.4, 0.1)
petReminderText:SetText("SUMMON YOUR PET")

local blackInkyFrame = CreateFrame("Frame", ADDON_NAME .. "_BlackInkyDisplay", UIParent, "BackdropTemplate")
blackInkyFrame:SetSize(300, 50)
blackInkyFrame:SetMovable(true)
blackInkyFrame:EnableMouse(false)
blackInkyFrame:RegisterForDrag("LeftButton")
blackInkyFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
blackInkyFrame:SetBackdropColor(0, 0, 0, 0)
blackInkyFrame:SetScript("OnDragStart", blackInkyFrame.StartMoving)
blackInkyFrame:SetScript("OnDragStop", function()
    blackInkyFrame:StopMovingOrSizing()
    local point, _, _, x, y = blackInkyFrame:GetPoint()
    EmiNotSoRaidToolsDB.blackInkyReminderPosition = { point = point, x = x, y = y }
end)

local blackInkyText = blackInkyFrame:CreateFontString(nil, "OVERLAY")
blackInkyText:SetPoint("CENTER", blackInkyFrame, "CENTER")
blackInkyText:SetFont("Fonts\\FRIZQT__.TTF", 40, "OUTLINE")
blackInkyText:SetTextColor(1, 0.8, 0)
blackInkyText:SetText("USE BLACK INKY POTION")

local function UpdateFrameSize()
    local padding = 12
    displayFrame:SetSize(displayText:GetStringWidth() + padding * 2, displayText:GetStringHeight() + padding * 2)
end

local function UpdateDisplay()
    local db = EmiNotSoRaidToolsDB

    if not db.textEnabled then
        displayFrame:SetShown(not db.locked)
        if db.locked then
            return
        end
    else
        displayFrame:Show()
    end

    local fontPath = FONT_TABLE[db.font] or FONT_TABLE.FRIZQT
    displayText:SetFont(fontPath, db.fontSize, "")

    if UnitIsDead("player") or UnitIsGhost("player") then
        local c = db.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
        displayText:SetText(db.deadText or DEFAULT_DEAD_TEXT)
        displayText:SetTextColor(c.r, c.g, c.b)
    else
        local c = db.colorAlive or { r = 1, g = 1, b = 1 }
        displayText:SetText(db.aliveText or DEFAULT_ALIVE_TEXT)
        displayText:SetTextColor(c.r, c.g, c.b)
    end

    UpdateFrameSize()
end

local function UpdatePetFrameSize()
    petReminderFrame:SetSize(petReminderText:GetStringWidth() + 20, petReminderText:GetStringHeight() + 20)
end

local function UpdateBlackInkyFrameSize()
    blackInkyFrame:SetSize(blackInkyText:GetStringWidth() + 20, blackInkyText:GetStringHeight() + 20)
end

local function PlayerHasBuff(spellID)
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local auraData = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
        return auraData ~= nil
    elseif C_UnitAuras and C_UnitAuras.GetUnitAuraBySpellID then
        local auraData = C_UnitAuras.GetUnitAuraBySpellID("player", spellID)
        return auraData ~= nil
    elseif UnitAura then
        local auraName = UnitAura("player", spellID, "HELPFUL")
        return auraName ~= nil
    elseif UnitBuff then
        return UnitBuff("player", spellID) ~= nil
    end
    return false
end

local function IsBlackInkyZoneActive()
    local ids = EmiNotSoRaidToolsDB.blackInkyZoneIDs
    if not ids or #ids == 0 then
        return false
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        return false
    end

    local currentMapID = mapID
    while currentMapID do
        for _, id in ipairs(ids) do
            if id == currentMapID then
                return true
            end
        end

        local info = C_Map.GetMapInfo(currentMapID)
        if not info or not info.parentMapID or info.parentMapID == currentMapID then
            break
        end
        currentMapID = info.parentMapID
    end

    return false
end

local function UpdateBlackInkyDisplay()
    local db = EmiNotSoRaidToolsDB
    local hasBuff = PlayerHasBuff(185394)
    local dead = UnitIsDead("player")
    local ghost = UnitIsGhost("player")
    local combat = UnitAffectingCombat("player")
    local enabled = db.blackInkyReminderEnabled
    local zoneActive = IsBlackInkyZoneActive()

    if not db.locked then
        if hasBuff or dead or ghost or combat or not enabled or not zoneActive then
            blackInkyFrame:Hide()
            return
        end

        blackInkyFrame:Show()
        blackInkyText:Show()
        return
    end

    if hasBuff or dead or ghost or combat or not enabled or not zoneActive then
        blackInkyFrame:Hide()
        return
    end

    blackInkyFrame:Show()
    blackInkyText:Show()
end

local function CanClassHavePet()
    local class = select(2, UnitClass("player"))
    local spec = GetSpecialization(false, false)
    local hunterHasPet = spec == 1 or spec == 3 or (spec == 2 and not IsSpellKnown(1232995))

    return (class == "MAGE" and IsSpellKnown(31687))
        or (class == "HUNTER" and hunterHasPet)
        or class == "WARLOCK"
        or (class == "DEATHKNIGHT" and spec == 3)
end

local function UpdatePetDisplay()
    local db = EmiNotSoRaidToolsDB

    if not db.locked then
        petReminderFrame:Show()
        petReminderText:Show()
        return
    end

    if not db.petReminderEnabled then
        petReminderFrame:Hide()
        return
    end

    if UnitIsDead("player") or UnitIsGhost("player") then
        petReminderFrame:Hide()
        return
    end

    if CanClassHavePet() then
        if not UnitExists("pet") then
            petReminderFrame:Show()
            petReminderText:Show()
        else
            petReminderFrame:Hide()
        end
    else
        petReminderFrame:Hide()
        return
    end
end

local function ApplyLockState()
    local isLocked = EmiNotSoRaidToolsDB.locked

    displayFrame:SetMovable(not isLocked)
    displayFrame:EnableMouse(not isLocked)
    petReminderFrame:SetMovable(not isLocked)
    petReminderFrame:EnableMouse(not isLocked)
    blackInkyFrame:SetMovable(not isLocked)
    blackInkyFrame:EnableMouse(not isLocked)

    if not isLocked then
        displayFrame:SetBackdropBorderColor(1, 1, 1, 1)
        displayFrame:SetBackdropColor(0, 0, 0, 0.3)
        petReminderFrame:SetBackdropBorderColor(1, 1, 1, 1)
        petReminderFrame:SetBackdropColor(0, 0, 0, 0.3)
        blackInkyFrame:SetBackdropBorderColor(1, 1, 1, 1)
        blackInkyFrame:SetBackdropColor(0, 0, 0, 0.3)
        petReminderFrame:Show()
        petReminderText:Show()
        blackInkyFrame:Show()
        blackInkyText:Show()
        displayFrame:Show()
        UpdateDisplay()
    else
        displayFrame:SetBackdropBorderColor(1, 1, 1, 0)
        displayFrame:SetBackdropColor(0, 0, 0, 0)
        petReminderFrame:SetBackdropBorderColor(1, 1, 1, 0)
        petReminderFrame:SetBackdropColor(0, 0, 0, 0)
        blackInkyFrame:SetBackdropBorderColor(1, 1, 1, 0)
        blackInkyFrame:SetBackdropColor(0, 0, 0, 0)
        UpdatePetDisplay()
        UpdateBlackInkyDisplay()
    end

    if Emi_UpdateLustLockState then
        Emi_UpdateLustLockState()
    end

    if Emi_UpdatePowerInfusionLockState then
        Emi_UpdatePowerInfusionLockState()
    end
end

local configFrame = CreateFrame("Frame", ADDON_NAME .. "_Config", UIParent, "BackdropTemplate")
configFrame:SetSize(430, 530)
configFrame:SetPoint("CENTER", 0, -200)
configFrame:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })
configFrame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
configFrame:EnableMouse(true)
configFrame:SetMovable(true)
configFrame:RegisterForDrag("LeftButton")
configFrame:SetScript("OnDragStart", configFrame.StartMoving)
configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
configFrame:Hide()

local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", 4, 4)
closeButton:SetScript("OnClick", function()
    configFrame:Hide()
end)

local titleLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
titleLabel:SetPoint("TOP", 0, -10)
titleLabel:SetText(ADDON_NAME)

local lockButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
lockButton:SetSize(75, 22)
lockButton:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 10, -10)
lockButton:SetScript("OnClick", function()
    EmiNotSoRaidToolsDB.locked = not EmiNotSoRaidToolsDB.locked
    lockButton:SetText(EmiNotSoRaidToolsDB.locked and "Locked" or "Unlocked")
    ApplyLockState()
end)

local tabButtons = {}
local tabPages = {}
local tabRefreshers = {}
local activeTab = "TextDisplay"

local function ShowTab(tabName)
    activeTab = tabName
    for name, frame in pairs(tabPages) do
        frame:SetShown(name == tabName)
    end
    for name, button in pairs(tabButtons) do
        button:SetEnabled(name ~= tabName)
    end
end

local function CreateTabButton(name, label, anchor, xOffset)
    local button = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    button:SetSize(120, 24)
    if anchor then
        button:SetPoint("LEFT", anchor, "RIGHT", xOffset or 6, 0)
    else
        button:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 12, -46)
    end
    button:SetText(label)
    button:SetScript("OnClick", function() ShowTab(name) end)
    tabButtons[name] = button

    local page = CreateFrame("Frame", nil, configFrame)
    page:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 14, -78)
    page:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -14, 14)
    page:Hide()
    tabPages[name] = page

    return button, page
end

local function BuildTab(name, builder, page)
    if not builder then
        return
    end

    local refresh = builder({
        page = page,
        addonName = ADDON_NAME,
        fontTable = FONT_TABLE,
        updateDisplay = UpdateDisplay,
        updatePetDisplay = UpdatePetDisplay,
        updateBlackInkyDisplay = UpdateBlackInkyDisplay,
        updateLustLockState = Emi_UpdateLustLockState,
        testLust = Emi_TestLust,
        updatePowerInfusionLockState = Emi_UpdatePowerInfusionLockState,
    })

    if type(refresh) == "function" then
        tabRefreshers[name] = refresh
    end
end

local firstTabButton, textPage = CreateTabButton("TextDisplay", "TextDisplay")
local secondTabButton, reminderPage = CreateTabButton("Reminder", "Reminder", firstTabButton, 6)
local _, trackingPage = CreateTabButton("Tracking", "Tracking", secondTabButton, 6)

BuildTab("TextDisplay", Emi_BuildTextDisplayTab, textPage)
BuildTab("Reminder", Emi_BuildReminderTab, reminderPage)
BuildTab("Tracking", Emi_BuildTrackingTab, trackingPage)

local function RefreshConfigUI()
    for _, refresh in pairs(tabRefreshers) do
        refresh()
    end
end

configFrame:HookScript("OnHide", function()
    EmiNotSoRaidToolsDB.locked = true
    lockButton:SetText("Locked")
    ApplyLockState()
end)

SLASH_EMI1 = "/emi"
SlashCmdList["EMI"] = function()
    InitializeDatabaseDefaults()

    if configFrame:IsShown() then
        EmiNotSoRaidToolsDB.locked = true
        configFrame:Hide()
        return
    end

    lockButton:SetText(EmiNotSoRaidToolsDB.locked and "Locked" or "Unlocked")
    RefreshConfigUI()
    ShowTab(activeTab)
    ApplyLockState()
    configFrame:Show()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("UNIT_AURA")

eventFrame:SetScript("OnEvent", function(_, event, arg1, arg2, arg3)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitializeDatabaseDefaults()

        local pos = EmiNotSoRaidToolsDB.position
        displayFrame:ClearAllPoints()
        displayFrame:SetPoint(pos.point, pos.x, pos.y)

        local ppos = EmiNotSoRaidToolsDB.petReminderPosition
        petReminderFrame:ClearAllPoints()
        petReminderFrame:SetPoint(ppos.point, ppos.x, ppos.y)

        local inkPos = EmiNotSoRaidToolsDB.blackInkyReminderPosition
        blackInkyFrame:ClearAllPoints()
        blackInkyFrame:SetPoint(inkPos.point, inkPos.x, inkPos.y)

        UpdatePetFrameSize()
        UpdateBlackInkyFrameSize()
        UpdateDisplay()
        UpdatePetDisplay()
        UpdateBlackInkyDisplay()
        ApplyLockState()
        ShowTab("TextDisplay")
        return
    end

    UpdateDisplay()
    UpdatePetDisplay()
    UpdateBlackInkyDisplay()
end)
