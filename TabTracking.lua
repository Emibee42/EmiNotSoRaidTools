-- luacheck: globals Emi_BuildTrackingTab CreateFrame EmiNotSoRaidToolsDB UnitClass

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

    local _, playerClass = UnitClass("player")
    local powerInfusionWhisperCheckbox
    if playerClass == "PRIEST" then
        powerInfusionWhisperCheckbox = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
        powerInfusionWhisperCheckbox:SetPoint("TOPLEFT", testLustButton, "BOTTOMLEFT", 0, -14)
        powerInfusionWhisperCheckbox.text:SetText("Enable PI whisper alerts")
        powerInfusionWhisperCheckbox:SetScript("OnClick", function(self)
            EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled = self:GetChecked()
            if ctx.updatePowerInfusionLockState then
                ctx.updatePowerInfusionLockState()
            end
        end)
    end

    local resizeDisclaimer = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resizeDisclaimer:SetPoint("TOPLEFT", powerInfusionWhisperCheckbox or testLustButton, "BOTTOMLEFT", 6, -8)
    resizeDisclaimer:SetWidth(340)
    resizeDisclaimer:SetJustifyH("LEFT")
    resizeDisclaimer:SetJustifyV("TOP")
    resizeDisclaimer:SetText("Tip: Tracking frames can be resized from corners while unlocked. Hold Shift to keep proportions.")

    return function()
        bloodlustTrackingCheckbox:SetChecked(EmiNotSoRaidToolsDB.lustIconEnabled)
        bloodlustPedroTrackingCheckbox:SetChecked(EmiNotSoRaidToolsDB.lustPedroEnabled)
        if powerInfusionWhisperCheckbox then
            powerInfusionWhisperCheckbox:SetChecked(EmiNotSoRaidToolsDB.PowerInfusionWhisperAlertEnabled)
        end
    end
end
