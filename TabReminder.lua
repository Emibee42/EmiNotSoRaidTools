-- luacheck: globals Emi_BuildReminderTab CreateFrame EmiNotSoRaidToolsDB C_Map wipe table tonumber

function Emi_BuildReminderTab(ctx)
    local page = ctx.page

    local petReminderCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    petReminderCheckbox:SetPoint("TOPLEFT", page, "TOPLEFT", 8, -10)
    petReminderCheckbox.text:SetText("Enable Pet Reminder")
    petReminderCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.petReminderEnabled = self:GetChecked()
        ctx.updatePetDisplay()
    end)

    local blackInkyCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    blackInkyCheckbox:SetPoint("TOPLEFT", petReminderCheckbox, "BOTTOMLEFT", 0, -20)
    blackInkyCheckbox.text:SetText("Enable Black Inky Potion Reminder")
    blackInkyCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.blackInkyReminderEnabled = self:GetChecked()
        if ctx.updateBlackInkyDisplay then
            ctx.updateBlackInkyDisplay()
        end
    end)

    local reminderHint = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    reminderHint:SetPoint("TOPLEFT", blackInkyCheckbox, "BOTTOMLEFT", 6, -8)
    reminderHint:SetJustifyH("LEFT")
    reminderHint:SetText("When unlocked, the reminder frame is shown for movement.")

    local addZoneId
    local zoneIdInput = CreateFrame("EditBox", nil, page, "InputBoxTemplate")
    zoneIdInput:SetPoint("TOPLEFT", reminderHint, "BOTTOMLEFT", 0, -16)
    zoneIdInput:SetSize(140, 24)
    zoneIdInput:SetAutoFocus(false)
    zoneIdInput:SetFontObject("GameFontHighlight")
    zoneIdInput:SetText("")
    zoneIdInput:SetMaxLetters(8)
    zoneIdInput:SetScript("OnEnterPressed", function(self)
        addZoneId(self:GetText())
        self:ClearFocus()
    end)
    zoneIdInput:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    local addZoneButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    addZoneButton:SetSize(80, 24)
    addZoneButton:SetPoint("LEFT", zoneIdInput, "RIGHT", 8, 0)
    addZoneButton:SetText("Add ID")

    local addCurrentMapButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    addCurrentMapButton:SetSize(120, 24)
    addCurrentMapButton:SetPoint("LEFT", addZoneButton, "RIGHT", 8, 0)
    addCurrentMapButton:SetText("Add Current Map")

    local zoneStatus = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    zoneStatus:SetPoint("TOPLEFT", zoneIdInput, "BOTTOMLEFT", 0, -6)
    zoneStatus:SetJustifyH("LEFT")
    zoneStatus:SetText("")

    local zoneListTitle = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    zoneListTitle:SetPoint("TOPLEFT", zoneStatus, "BOTTOMLEFT", 0, -12)
    zoneListTitle:SetText("Black Inky reminder active IDs:")

    local zoneListContainer = CreateFrame("Frame", nil, page)
    zoneListContainer:SetPoint("TOPLEFT", zoneListTitle, "BOTTOMLEFT", 0, -8)
    zoneListContainer:SetSize(400, 180)

    local zoneRows = {}
    local function RebuildZoneList()
        for _, row in ipairs(zoneRows) do
            row:Hide()
        end
        wipe(zoneRows)

        local ids = EmiNotSoRaidToolsDB.blackInkyZoneIDs or {}
        local yOffset = 0
        for index, zoneId in ipairs(ids) do
            local row = CreateFrame("Frame", nil, zoneListContainer)
            row:SetSize(400, 22)
            row:SetPoint("TOPLEFT", zoneListContainer, "TOPLEFT", 0, yOffset)

            local name = C_Map.GetMapInfo(zoneId)
            local displayText = tostring(zoneId)
            if name and name.name then
                displayText = displayText .. " - " .. name.name
            end

            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            row.text:SetPoint("LEFT", 0, 0)
            row.text:SetText(displayText)

            row.removeButton = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            row.removeButton:SetSize(58, 20)
            row.removeButton:SetPoint("RIGHT", -100, 0)
            row.removeButton:SetText("Remove")
            local capturedIndex = index
            row.removeButton:SetScript("OnClick", function()
                table.remove(EmiNotSoRaidToolsDB.blackInkyZoneIDs, capturedIndex)
                RebuildZoneList()
            end)

            zoneRows[#zoneRows + 1] = row
            yOffset = yOffset - 24
        end
    end

    addZoneId = function(text)
        local zoneId = tonumber(text and text:match("%d+"))
        if not zoneId then
            zoneStatus:SetText("Enter a numeric zone ID.")
            return
        end

        if not C_Map.GetMapInfo(zoneId) then
            zoneStatus:SetText("Map ID not found. Not added.")
            return
        end

        EmiNotSoRaidToolsDB.blackInkyZoneIDs = EmiNotSoRaidToolsDB.blackInkyZoneIDs or {}
        for _, existingId in ipairs(EmiNotSoRaidToolsDB.blackInkyZoneIDs) do
            if existingId == zoneId then
                zoneStatus:SetText("ID already in the list.")
                return
            end
        end

        table.insert(EmiNotSoRaidToolsDB.blackInkyZoneIDs, zoneId)
        table.sort(EmiNotSoRaidToolsDB.blackInkyZoneIDs)
        zoneStatus:SetText("Added ID " .. zoneId)
        zoneIdInput:SetText("")
        RebuildZoneList()
    end

    addZoneButton:SetScript("OnClick", function()
        addZoneId(zoneIdInput:GetText())
    end)

    addCurrentMapButton:SetScript("OnClick", function()
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then
            zoneStatus:SetText("Current map ID not available.")
            return
        end
        addZoneId(tostring(mapID))
    end)

    return function()
        petReminderCheckbox:SetChecked(EmiNotSoRaidToolsDB.petReminderEnabled)
        blackInkyCheckbox:SetChecked(EmiNotSoRaidToolsDB.blackInkyReminderEnabled)
        RebuildZoneList()
    end
end
