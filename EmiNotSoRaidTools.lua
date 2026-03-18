-- EmiNotSoRaidTools Addon
-- Displays customizable text on screen for raid tools, changing based on player status.
local ADDON_NAME = "EmiNotSoRaidTools"
local DEFAULT_ALIVE_TEXT = "Emi is the best"
local DEFAULT_DEAD_TEXT = "Emi has fallen... but is still the best!"
local FONT_TABLE = {
    FRIZQT = "Fonts\\FRIZQT__.TTF",
    ARIAL = "Fonts\\ARIALN.TTF",
    MORPHEUS = "Fonts\\MORPHEUS.TTF",
    SKURRI = "Fonts\\SKURRI.TTF",
}

-- Event handling frame
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_PET")
eventFrame:RegisterEvent("TRAIT_CONFIG_UPDATED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

-- Initialize database defaults
local function InitializeDatabaseDefaults()
    EmiNotSoRaidToolsDB = EmiNotSoRaidToolsDB or {}
    EmiNotSoRaidToolsDB.aliveText = EmiNotSoRaidToolsDB.aliveText or DEFAULT_ALIVE_TEXT
    EmiNotSoRaidToolsDB.deadText = EmiNotSoRaidToolsDB.deadText or DEFAULT_DEAD_TEXT
    EmiNotSoRaidToolsDB.fontSize = EmiNotSoRaidToolsDB.fontSize or 32
    if EmiNotSoRaidToolsDB.fontSize < 8 then EmiNotSoRaidToolsDB.fontSize = 8 end
    if EmiNotSoRaidToolsDB.fontSize > 120 then EmiNotSoRaidToolsDB.fontSize = 120 end
    EmiNotSoRaidToolsDB.font = EmiNotSoRaidToolsDB.font or "FRIZQT"
    EmiNotSoRaidToolsDB.colorAlive = EmiNotSoRaidToolsDB.colorAlive or { r = 1, g = 1, b = 1 }
    EmiNotSoRaidToolsDB.colorDead = EmiNotSoRaidToolsDB.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
    EmiNotSoRaidToolsDB.locked = (EmiNotSoRaidToolsDB.locked == nil) and true or EmiNotSoRaidToolsDB.locked
    EmiNotSoRaidToolsDB.position = EmiNotSoRaidToolsDB.position or { point = "CENTER", x = 0, y = 0 }
    EmiNotSoRaidToolsDB.petReminderEnabled = (EmiNotSoRaidToolsDB.petReminderEnabled == nil) and false or EmiNotSoRaidToolsDB.petReminderEnabled
    EmiNotSoRaidToolsDB.petReminderPosition = EmiNotSoRaidToolsDB.petReminderPosition or { point = "CENTER", x = 0, y = 100 }
    EmiNotSoRaidToolsDB.BloodlustTrackingEnabled = (EmiNotSoRaidToolsDB.BloodlustTrackingEnabled == nil) and true or EmiNotSoRaidToolsDB.BloodlustTrackingEnabled
    EmiNotSoRaidToolsDB.lustPosition = EmiNotSoRaidToolsDB.lustPosition or { point = "CENTER", x = 0, y = 200 }
end

-- Display frame for showing the text
local displayFrame = CreateFrame("Frame", ADDON_NAME .. "_Display", UIParent, "BackdropTemplate")
displayFrame:SetSize(1, 1)
displayFrame:SetPoint("CENTER")
displayFrame:SetBackdrop({ bgFile = "Interface/ChatFrame/ChatFrameBackground" })
displayFrame:SetBackdropColor(0, 0, 0, 0)
displayFrame:SetBackdropBorderColor(1, 1, 1, 0)

displayFrame:EnableMouse(false)
displayFrame:SetMovable(false)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart", displayFrame.StartMoving)
displayFrame:SetScript("OnDragStop", function()
    displayFrame:StopMovingOrSizing()
    local point, _, _, x, y = displayFrame:GetPoint()
    EmiNotSoRaidToolsDB.position = { point = point, x = x, y = y }
end)

local displayText = displayFrame:CreateFontString(nil, "OVERLAY")
displayText:SetPoint("CENTER")

-- Pet reminder container frame
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

local function UpdatePetDisplay()
    -- If unlocked, force show for movement
    if not EmiNotSoRaidToolsDB.locked then
        petReminderFrame:Show()
        petReminderText:Show()
        return
    end

    if EmiNotSoRaidToolsDB.petReminderEnabled then
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
        else
            if not UnitExists("pet") then
                petReminderFrame:Hide()
            else
                petReminderFrame:Show()
                petReminderText:Show()
            end
        end
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
    
    -- Add this line to handle the Bloodlust frame:
    if Emi_UpdateLustLockState then Emi_UpdateLustLockState() end
end

-- Configuration frame
local configFrame = CreateFrame("Frame", ADDON_NAME .. "_Config", UIParent, "BackdropTemplate")
configFrame:SetSize(420, 500)
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
lockButton:SetSize(70, 22)
lockButton:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 8, -8)
lockButton:SetScript("OnClick", function()
    EmiNotSoRaidToolsDB.locked = not EmiNotSoRaidToolsDB.locked
    lockButton:SetText(EmiNotSoRaidToolsDB.locked and "Locked" or "Unlocked")
    ApplyLockState()
end)
configFrame.lockButton = lockButton

local aliveLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aliveLabel:SetPoint("TOP", titleLabel, "BOTTOM", 0, -18)
aliveLabel:SetText("Alive Text")

local aliveInput = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
aliveInput:SetSize(330, 26)
aliveInput:SetPoint("TOP", aliveLabel, "BOTTOM", 0, -6)
aliveInput:SetAutoFocus(false)

local deadLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
deadLabel:SetPoint("TOP", aliveInput, "BOTTOM", 0, -8)
deadLabel:SetText("Dead Text")

local deadInput = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
deadInput:SetSize(330, 26)
deadInput:SetPoint("TOP", deadLabel, "BOTTOM", 0, -6)
deadInput:SetAutoFocus(false)

if not UIDropDownMenu_Initialize then LoadAddOn("Blizzard_UIDropDownMenu") end
local fontDropdown = CreateFrame("Frame", ADDON_NAME .. "_FontDropdown", configFrame, "UIDropDownMenuTemplate")
fontDropdown:SetPoint("TOP", deadInput, "BOTTOM", 0, -30)
UIDropDownMenu_SetWidth(fontDropdown, 150)

local fontSizeSlider = CreateFrame("Slider", ADDON_NAME .. "_FontSlider", configFrame, "OptionsSliderTemplate")
fontSizeSlider:SetPoint("TOP", fontDropdown, "BOTTOM", 0, -30)
fontSizeSlider:SetWidth(240)
fontSizeSlider:SetMinMaxValues(8, 120)
fontSizeSlider:SetValueStep(1)
fontSizeSlider:SetObeyStepOnDrag(true)

local fontSizeInput = CreateFrame("EditBox", nil, configFrame, "InputBoxTemplate")
fontSizeInput:SetSize(30, 24)
fontSizeInput:SetPoint("LEFT", fontSizeSlider, "RIGHT", 12, 0)
fontSizeInput:SetAutoFocus(false)
fontSizeInput:SetNumeric(true)

local function UpdateFrameSize()
    local padding = 12
    displayFrame:SetSize(displayText:GetStringWidth() + padding * 2, displayText:GetStringHeight() + padding * 2)
end

local function UpdateDisplay()
    local db = EmiNotSoRaidToolsDB
    local fontPath = FONT_TABLE[db.font] or FONT_TABLE.FRIZQT
    displayText:SetFont(fontPath, db.fontSize, "")
    
    if not UnitIsDead("player") and not UnitIsGhost("player") then
        displayText:SetText(db.aliveText or DEFAULT_ALIVE_TEXT)
        local c = db.colorAlive or { r = 1, g = 1, b = 1 }
        displayText:SetTextColor(c.r, c.g, c.b)
    else
        displayText:SetText(db.deadText or DEFAULT_DEAD_TEXT)
        local c = db.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
        displayText:SetTextColor(c.r, c.g, c.b)
    end
    UpdateFrameSize()
end

local function UpdatePetFrameSize()
    petReminderFrame:SetSize(petReminderText:GetStringWidth() + 20, petReminderText:GetStringHeight() + 20)
end

local function SetFontSize(value)
    value = math.max(8, math.min(120, math.floor(value)))
    EmiNotSoRaidToolsDB.fontSize = value
    fontSizeSlider:SetValue(value)
    fontSizeInput:SetText(value)
    UpdateDisplay()
end

local aliveColorBox = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
aliveColorBox:SetSize(20, 20)
aliveColorBox:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })

local deadColorBox = CreateFrame("Frame", nil, configFrame, "BackdropTemplate")
deadColorBox:SetSize(20, 20)
deadColorBox:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })

local function UpdateColorBoxes()
    local a = EmiNotSoRaidToolsDB.colorAlive or { r = 1, g = 1, b = 1 }
    aliveColorBox:SetBackdropColor(a.r, a.g, a.b, 1)
    local d = EmiNotSoRaidToolsDB.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
    deadColorBox:SetBackdropColor(d.r, d.g, d.b, 1)
end

local function OpenColorPicker(key)
    local info = {}
    local curr = EmiNotSoRaidToolsDB[key] or { r = 1, g = 1, b = 1 }
    info.r, info.g, info.b = curr.r, curr.g, curr.b
    info.swatchFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        EmiNotSoRaidToolsDB[key] = { r = r, g = g, b = b }
        UpdateDisplay()
        UpdateColorBoxes()
    end
    info.cancelFunc = function(prev)
        EmiNotSoRaidToolsDB[key] = prev
        UpdateDisplay()
        UpdateColorBoxes()
    end
    info.previousValues = curr
    ColorPickerFrame:SetupColorPickerAndShow(info)
end

local aliveColorButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
aliveColorButton:SetSize(140, 26)
aliveColorButton:SetPoint("TOP", fontSizeSlider, "BOTTOM", -30, -40)
aliveColorButton:SetText("Alive Color")
aliveColorButton:SetScript("OnClick", function() OpenColorPicker("colorAlive") end)
aliveColorBox:SetPoint("LEFT", aliveColorButton, "RIGHT", 10, 0)

local deadColorButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
deadColorButton:SetSize(140, 26)
deadColorButton:SetPoint("TOP", aliveColorButton, "BOTTOM", 0, -10)
deadColorButton:SetText("Dead Color")
deadColorButton:SetScript("OnClick", function() OpenColorPicker("colorDead") end)
deadColorBox:SetPoint("LEFT", deadColorButton, "RIGHT", 10, 0)

local petReminderCheckbox = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
petReminderCheckbox:SetPoint("TOP", deadColorButton, "BOTTOM", -60, -20)
petReminderCheckbox.text:SetText("Enable Pet Reminder")
petReminderCheckbox:SetScript("OnClick", function(self)
    EmiNotSoRaidToolsDB.petReminderEnabled = self:GetChecked()
    UpdatePetDisplay()
end)

local bloodlustTrackingCheckbox = CreateFrame("CheckButton", nil, configFrame, "UICheckButtonTemplate")
bloodlustTrackingCheckbox:SetPoint("TOP", petReminderCheckbox, "BOTTOM", 0, -10)
bloodlustTrackingCheckbox.text:SetText("Enable Bloodlust Tracking with PEDRO")
bloodlustTrackingCheckbox:SetScript("OnClick", function(self)
    EmiNotSoRaidToolsDB.BloodlustTrackingEnabled = self:GetChecked()
end)

local testLustButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
testLustButton:SetSize(140, 26)
testLustButton:SetPoint("LEFT", bloodlustTrackingCheckbox, "BOTTOM", 25, 0)
testLustButton:SetText("Test PEDRO")
testLustButton:SetScript("OnClick", function()
    if Emi_TestLust then Emi_TestLust() end
end)

fontSizeSlider:SetScript("OnValueChanged", function(self, value) SetFontSize(value) end)
aliveInput:SetScript("OnEnterPressed", function(self) EmiNotSoRaidToolsDB.aliveText = self:GetText() UpdateDisplay() self:ClearFocus() end)
deadInput:SetScript("OnEnterPressed", function(self) EmiNotSoRaidToolsDB.deadText = self:GetText() UpdateDisplay() self:ClearFocus() end)

configFrame:HookScript("OnHide", function()
    EmiNotSoRaidToolsDB.locked = true
    ApplyLockState()
end)

UIDropDownMenu_Initialize(fontDropdown, function(self)
    for name, _ in pairs(FONT_TABLE) do
        local info = UIDropDownMenu_CreateInfo()
        info.text, info.value, info.func = name, name, function(s) 
            EmiNotSoRaidToolsDB.font = s.value
            UIDropDownMenu_SetText(fontDropdown, s.value)
            UpdateDisplay()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

SLASH_EMI1 = "/emi"
SlashCmdList["EMI"] = function()
    InitializeDatabaseDefaults()
    if configFrame:IsShown() then
        EmiNotSoRaidToolsDB.locked = true
        configFrame:Hide()
    else
        aliveInput:SetText(EmiNotSoRaidToolsDB.aliveText)
        deadInput:SetText(EmiNotSoRaidToolsDB.deadText)
        fontSizeSlider:SetValue(EmiNotSoRaidToolsDB.fontSize)
        UIDropDownMenu_SetText(fontDropdown, EmiNotSoRaidToolsDB.font)
        lockButton:SetText("Unlocked")
        petReminderCheckbox:SetChecked(EmiNotSoRaidToolsDB.petReminderEnabled)
        UpdateColorBoxes()
        ApplyLockState()
        configFrame:Show()
    end
end

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        InitializeDatabaseDefaults()
        local pos = EmiNotSoRaidToolsDB.position
        displayFrame:ClearAllPoints()
        displayFrame:SetPoint(pos.point, pos.x, pos.y)
        local ppos = EmiNotSoRaidToolsDB.petReminderPosition
        petReminderFrame:ClearAllPoints()
        petReminderFrame:SetPoint(ppos.point, ppos.x, ppos.y)
        UpdatePetFrameSize()
        ApplyLockState()
        UpdateDisplay()
        UpdatePetDisplay()
    else
        UpdateDisplay()
        UpdatePetDisplay()
    end
end)