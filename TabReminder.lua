function Emi_BuildReminderTab(ctx)
    local page = ctx.page

    local petReminderCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    petReminderCheckbox:SetPoint("TOPLEFT", page, "TOPLEFT", 8, -10)
    petReminderCheckbox.text:SetText("Enable Pet Reminder")
    petReminderCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.petReminderEnabled = self:GetChecked()
        ctx.updatePetDisplay()
    end)

    local reminderHint = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    reminderHint:SetPoint("TOPLEFT", petReminderCheckbox, "BOTTOMLEFT", 6, -8)
    reminderHint:SetJustifyH("LEFT")
    reminderHint:SetText("When unlocked, the reminder frame is shown for movement.")

    return function()
        petReminderCheckbox:SetChecked(EmiNotSoRaidToolsDB.petReminderEnabled)
    end
end
