function Emi_BuildTrackingTab(ctx)
    local page = ctx.page

    local bloodlustTrackingCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    bloodlustTrackingCheckbox:SetPoint("TOPLEFT", page, "TOPLEFT", 8, -10)
    bloodlustTrackingCheckbox.text:SetText("Enable Bloodlust Tracking")
    bloodlustTrackingCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.lustIconEnabled = self:GetChecked()
        if ctx.updateLustLockState then
            ctx.updateLustLockState()
        end
    end)

    local bloodlustPedroTrackingCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    bloodlustPedroTrackingCheckbox:SetPoint("TOPLEFT", bloodlustTrackingCheckbox, "BOTTOMLEFT", 0, -12)
    bloodlustPedroTrackingCheckbox.text:SetText("Enable Bloodlust Tracking with PEDRO")
    bloodlustPedroTrackingCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.lustPedroEnabled = self:GetChecked()
        if ctx.updateLustLockState then
            ctx.updateLustLockState()
        end
    end)

    local testLustButton = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    testLustButton:SetSize(160, 26)
    testLustButton:SetPoint("TOPLEFT", bloodlustPedroTrackingCheckbox, "BOTTOMLEFT", 8, -14)
    testLustButton:SetText("Test Lust Tracking")
    testLustButton:SetScript("OnClick", function()
        if ctx.testLust then
            ctx.testLust()
        end
    end)

    local powerInfusionCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    powerInfusionCheckbox:SetPoint("TOPLEFT", testLustButton, "BOTTOMLEFT", -8, -14)
    powerInfusionCheckbox.text:SetText("Enable Power Infusion Tracking")
    powerInfusionCheckbox:SetScript("OnClick", function(self)
        EmiNotSoRaidToolsDB.PowerInfusionEnabled = self:GetChecked()
        if ctx.updatePowerInfusionLockState then
            ctx.updatePowerInfusionLockState()
        end
    end)

    return function()
        bloodlustTrackingCheckbox:SetChecked(EmiNotSoRaidToolsDB.lustIconEnabled)
        bloodlustPedroTrackingCheckbox:SetChecked(EmiNotSoRaidToolsDB.lustPedroEnabled)
        powerInfusionCheckbox:SetChecked(EmiNotSoRaidToolsDB.PowerInfusionEnabled)
    end
end
