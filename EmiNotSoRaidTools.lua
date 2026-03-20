local ADDON_NAME = "EmiNotSoRaidTools"
local DEFAULT_ALIVE_TEXT = "Emi is the best"
local DEFAULT_DEAD_TEXT = "Emi has fallen... but is still the best!"

EmiNSRT = EmiNSRT or {}

local FONT_TABLE = {
    FRIZQT = "Fonts\\FRIZQT__.TTF",
    ARIAL = "Fonts\\ARIALN.TTF",
    MORPHEUS = "Fonts\\MORPHEUS.TTF",
    SKURRI = "Fonts\\SKURRI.TTF",
}

local function InitializeDatabaseDefaults()
    EmiNotSoRaidToolsDB = EmiNotSoRaidToolsDB or {}
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
    EmiNotSoRaidToolsDB.lustIconEnabled = (EmiNotSoRaidToolsDB.lustIconEnabled == nil) and true or EmiNotSoRaidToolsDB.lustIconEnabled
    EmiNotSoRaidToolsDB.lustPedroEnabled = (EmiNotSoRaidToolsDB.lustPedroEnabled == nil) and true or EmiNotSoRaidToolsDB.lustPedroEnabled
    EmiNotSoRaidToolsDB.lustPosition = EmiNotSoRaidToolsDB.lustPosition or { point = "CENTER", x = 0, y = 200 }
    EmiNotSoRaidToolsDB.lustPedroPosition = EmiNotSoRaidToolsDB.lustPedroPosition or { point = "CENTER", x = 0, y = 200 }
    EmiNotSoRaidToolsDB.PowerInfusionEnabled = (EmiNotSoRaidToolsDB.PowerInfusionEnabled == nil) and true or EmiNotSoRaidToolsDB.PowerInfusionEnabled
    EmiNotSoRaidToolsDB.powerInfusionPosition = EmiNotSoRaidToolsDB.powerInfusionPosition or { point = "CENTER", x = 0, y = 300 }
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

local function UpdateFrameSize()
    local padding = 12
    displayFrame:SetSize(displayText:GetStringWidth() + padding * 2, displayText:GetStringHeight() + padding * 2)
end

local function UpdateDisplay()
    local db = EmiNotSoRaidToolsDB
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

    local class = select(2, UnitClass("player"))
    if class == "MAGE" then
        if not UnitExists("pet") and IsSpellKnown(31687) then
            petReminderFrame:Show()
            petReminderText:Show()
        else
            petReminderFrame:Hide()
        end
        return
    end

    if UnitExists("pet") then
        petReminderFrame:Show()
        petReminderText:Show()
    else
        petReminderFrame:Hide()
    end
end

local function ApplyLockState()
    local isLocked = EmiNotSoRaidToolsDB.locked

    displayFrame:SetMovable(not isLocked)
    displayFrame:EnableMouse(not isLocked)
    petReminderFrame:SetMovable(not isLocked)
    petReminderFrame:EnableMouse(not isLocked)

    if not isLocked then
        displayFrame:SetBackdropBorderColor(1, 1, 1, 1)
        displayFrame:SetBackdropColor(0, 0, 0, 0.3)
        petReminderFrame:SetBackdropBorderColor(1, 1, 1, 1)
        petReminderFrame:SetBackdropColor(0, 0, 0, 0.3)
        petReminderFrame:Show()
        petReminderText:Show()
    else
        displayFrame:SetBackdropBorderColor(1, 1, 1, 0)
        displayFrame:SetBackdropColor(0, 0, 0, 0)
        petReminderFrame:SetBackdropBorderColor(1, 1, 1, 0)
        petReminderFrame:SetBackdropColor(0, 0, 0, 0)
        UpdatePetDisplay()
    end

    if Emi_UpdateLustLockState then
        Emi_UpdateLustLockState()
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

    EmiNotSoRaidToolsDB.locked = false
    lockButton:SetText("Unlocked")
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

eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitializeDatabaseDefaults()

        local pos = EmiNotSoRaidToolsDB.position
        displayFrame:ClearAllPoints()
        displayFrame:SetPoint(pos.point, pos.x, pos.y)

        local ppos = EmiNotSoRaidToolsDB.petReminderPosition
        petReminderFrame:ClearAllPoints()
        petReminderFrame:SetPoint(ppos.point, ppos.x, ppos.y)

        UpdatePetFrameSize()
        UpdateDisplay()
        UpdatePetDisplay()
        ApplyLockState()
        ShowTab("TextDisplay")
        return
    end

    UpdateDisplay()
    UpdatePetDisplay()
end)
