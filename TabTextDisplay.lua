function Emi_BuildTextDisplayTab(ctx)
    local page = ctx.page

    if not UIDropDownMenu_Initialize then
        LoadAddOn("Blizzard_UIDropDownMenu")
    end

    local aliveLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    aliveLabel:SetPoint("TOPLEFT", page, "TOPLEFT", 6, -8)
    aliveLabel:SetText("Alive Text")

    local aliveInput = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    aliveInput:SetSize(350, 26)
    aliveInput:SetPoint("TOPLEFT", aliveLabel, "BOTTOMLEFT", 0, -6)
    aliveInput:SetAutoFocus(false)

    local deadLabel = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deadLabel:SetPoint("TOPLEFT", aliveInput, "BOTTOMLEFT", 0, -10)
    deadLabel:SetText("Dead Text")

    local deadInput = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    deadInput:SetSize(350, 26)
    deadInput:SetPoint("TOPLEFT", deadLabel, "BOTTOMLEFT", 0, -6)
    deadInput:SetAutoFocus(false)

    local fontDropdown = CreateFrame("Frame", ctx.addonName .. "_FontDropdown", page, "UIDropDownMenuTemplate")
    fontDropdown:SetPoint("TOPLEFT", deadInput, "BOTTOMLEFT", -16, -20)
    UIDropDownMenu_SetWidth(fontDropdown, 150)

    local fontSizeSlider = CreateFrame("Slider", ctx.addonName .. "_FontSlider", page, "OptionsSliderTemplate")
    fontSizeSlider:SetPoint("TOPLEFT", fontDropdown, "BOTTOMLEFT", 16, -20)
    fontSizeSlider:SetWidth(240)
    fontSizeSlider:SetMinMaxValues(8, 120)
    fontSizeSlider:SetValueStep(1)
    fontSizeSlider:SetObeyStepOnDrag(true)

    local fontSizeInput = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    fontSizeInput:SetSize(36, 24)
    fontSizeInput:SetPoint("LEFT", fontSizeSlider, "RIGHT", 12, 0)
    fontSizeInput:SetAutoFocus(false)
    fontSizeInput:SetNumeric(true)

    local aliveColorBox = CreateFrame("Frame", nil, page, "BackdropTemplate")
    aliveColorBox:SetSize(20, 20)
    aliveColorBox:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })

    local deadColorBox = CreateFrame("Frame", nil, page, "BackdropTemplate")
    deadColorBox:SetSize(20, 20)
    deadColorBox:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8x8" })

    local function UpdateColorBoxes()
        local a = EmiNotSoRaidToolsDB.colorAlive or { r = 1, g = 1, b = 1 }
        local d = EmiNotSoRaidToolsDB.colorDead or { r = 0.8, g = 0.2, b = 0.2 }
        aliveColorBox:SetBackdropColor(a.r, a.g, a.b, 1)
        deadColorBox:SetBackdropColor(d.r, d.g, d.b, 1)
    end

    local function OpenColorPicker(key)
        local info = {}
        local curr = EmiNotSoRaidToolsDB[key] or { r = 1, g = 1, b = 1 }
        info.r, info.g, info.b = curr.r, curr.g, curr.b
        info.previousValues = curr
        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            EmiNotSoRaidToolsDB[key] = { r = r, g = g, b = b }
            ctx.updateDisplay()
            UpdateColorBoxes()
        end
        info.cancelFunc = function(prev)
            EmiNotSoRaidToolsDB[key] = prev
            ctx.updateDisplay()
            UpdateColorBoxes()
        end
        ColorPickerFrame:SetupColorPickerAndShow(info)
    end

    local aliveColorButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    aliveColorButton:SetSize(140, 26)
    aliveColorButton:SetPoint("TOPLEFT", fontSizeSlider, "BOTTOMLEFT", 6, -30)
    aliveColorButton:SetText("Alive Color")
    aliveColorButton:SetScript("OnClick", function()
        OpenColorPicker("colorAlive")
    end)
    aliveColorBox:SetPoint("LEFT", aliveColorButton, "RIGHT", 10, 0)

    local deadColorButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    deadColorButton:SetSize(140, 26)
    deadColorButton:SetPoint("TOPLEFT", aliveColorButton, "BOTTOMLEFT", 0, -10)
    deadColorButton:SetText("Dead Color")
    deadColorButton:SetScript("OnClick", function()
        OpenColorPicker("colorDead")
    end)
    deadColorBox:SetPoint("LEFT", deadColorButton, "RIGHT", 10, 0)

    local function SetFontSize(value)
        value = math.max(8, math.min(120, math.floor(value)))
        EmiNotSoRaidToolsDB.fontSize = value
        fontSizeSlider:SetValue(value)
        fontSizeInput:SetText(value)
        ctx.updateDisplay()
    end

    fontSizeSlider:SetScript("OnValueChanged", function(_, value)
        SetFontSize(value)
    end)

    fontSizeInput:SetScript("OnEnterPressed", function(self)
        local v = tonumber(self:GetText())
        if v then
            SetFontSize(v)
        else
            self:SetText(EmiNotSoRaidToolsDB.fontSize)
        end
        self:ClearFocus()
    end)

    aliveInput:SetScript("OnEnterPressed", function(self)
        EmiNotSoRaidToolsDB.aliveText = self:GetText()
        ctx.updateDisplay()
        self:ClearFocus()
    end)

    deadInput:SetScript("OnEnterPressed", function(self)
        EmiNotSoRaidToolsDB.deadText = self:GetText()
        ctx.updateDisplay()
        self:ClearFocus()
    end)

    UIDropDownMenu_Initialize(fontDropdown, function()
        for name in pairs(ctx.fontTable) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.value = name
            info.func = function(option)
                EmiNotSoRaidToolsDB.font = option.value
                UIDropDownMenu_SetText(fontDropdown, option.value)
                ctx.updateDisplay()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return function()
        local db = EmiNotSoRaidToolsDB
        aliveInput:SetText(db.aliveText)
        deadInput:SetText(db.deadText)
        fontSizeSlider:SetValue(db.fontSize)
        fontSizeInput:SetText(db.fontSize)
        UIDropDownMenu_SetText(fontDropdown, db.font)
        UpdateColorBoxes()
    end
end
