local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:NewModule("TankHealth", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0"); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

--Default options
P["TankHealth"] = {
    ["color"] = { r = 250 / 255, g = 128 / 255, b = 114 / 255, a = 0.3 },
}

--Function we can call when a setting changes.
function TH:Update()
    local c = E.db.TankHealth.color
    E.UnitFrames.player.HealPrediction.tankHealBar:SetStatusBarColor(c.r, c.g, c.b, c.a)
end

--This function inserts our GUI table into the ElvUI Config. You can read about AceConfig here: http://www.wowace.com/addons/ace3/pages/ace-config-3-0-options-tables/
function TH:InsertOptions()
    E.Options.args.TankHealth = {
        order = 100,
        type = "group",
        name = "TankHealth",
        args = {
            color = {
                order = 1,
                type = "color",
                hasAlpha = true,
                name = "Healbar color",
                get = function(info)
                    local c = E.db.TankHealth.color
                    return c.r, c.g, c.b, c.a
                end,
                set = function(info, r, g, b, a)
                    local c = E.db.TankHealth.color
                    c.r, c.g, c.b, c.a = r, g, b, a
                    TH:Update()
                end,
            },
        },
    }
end

local function CalculateHeal()

    local specId = GetInspectSpecialization("player")

    local calcFuncs = {
        [581] = TH.Calculate_DH,
        [250] = TH.Calculate_DK,
        [104] = TH.Calculate_Druid,
        [268] = TH.Calculate_Monk,
        [66] = TH.Calculate_Paladin,
        [73] = TH.Calculate_Warrior
    }
    if calcFuncs[specId] then
        return calcFuncs[class]()
    else
        return 0
    end
end



function TH:Override(event, unit)
    -- Most of this is duplicated code from oUF/elements/healprediction.lua
    if (self.unit ~= unit) or not unit then return end

    local hp = self.HealPrediction
    hp.parent = self
    if (hp.PreUpdate) then hp:PreUpdate(unit) end

    local myIncomingHeal = UnitGetIncomingHeals(unit, "player") or 0
    local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
    local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
    local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
    local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

    local overHealAbsorb = false
    if (health < myCurrentHealAbsorb) then
        overHealAbsorb = true
        myCurrentHealAbsorb = health
    end

    if (health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * hp.maxOverflow) then
        allIncomingHeal = maxHealth * hp.maxOverflow - health + myCurrentHealAbsorb
    end

    local otherIncomingHeal = 0
    if (allIncomingHeal < myIncomingHeal) then
        myIncomingHeal = allIncomingHeal
    else
        otherIncomingHeal = allIncomingHeal - myIncomingHeal
    end

    local overAbsorb = false
    if (health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
        if (totalAbsorb > 0) then
            overAbsorb = true
        end


        if (allIncomingHeal > myCurrentHealAbsorb) then
            totalAbsorb = max(0, maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal))
        else
            totalAbsorb = max(0, maxHealth - health)
        end
    end

    if (myCurrentHealAbsorb > allIncomingHeal) then
        myCurrentHealAbsorb = myCurrentHealAbsorb - allIncomingHeal
    else
        myCurrentHealAbsorb = 0
    end



    local tankHeal = min(maxHealth - health, totalAbsorb + CalculateHeal())

    --    print("tankHeal: " .. tankHeal)
    --    print("totalAbsorb + CalculateHeal(): " .. totalAbsorb + CalculateHeal())

    if (hp.myBar) then
        hp.myBar:SetMinMaxValues(0, maxHealth)
        hp.myBar:SetValue(myIncomingHeal)
        hp.myBar:Show()
    end

    if (hp.otherBar) then
        hp.otherBar:SetMinMaxValues(0, maxHealth)
        hp.otherBar:SetValue(otherIncomingHeal)
        hp.otherBar:Show()
    end

    if (hp.absorbBar) then
        hp.absorbBar:SetMinMaxValues(0, maxHealth)
        hp.absorbBar:SetValue(totalAbsorb)
        hp.absorbBar:Show()
    end

    if (hp.healAbsorbBar) then
        hp.healAbsorbBar:SetMinMaxValues(0, maxHealth)
        hp.healAbsorbBar:SetValue(myCurrentHealAbsorb)
        hp.healAbsorbBar:Show()
    end

    if (hp.tankHealBar) then
        hp.tankHealBar:SetMinMaxValues(0, maxHealth)
        hp.tankHealBar:SetValue(tankHeal)
        hp.tankHealBar:Show()
    end

    if (hp.PostUpdate) then
        return TH:UpdateHealComm(unit, overAbsorb, overHealAbsorb)
    end
end

function TH:Construct()

    local tankHealBar = CreateFrame("StatusBar", nil, E.UnitFrames.player)
    tankHealBar:SetStatusBarTexture(E["media"].blankTex)
    tankHealBar:SetFrameLevel(E.UnitFrames.player.Health:GetFrameLevel() - 2)
    tankHealBar:Hide()

    if E.UnitFrames.player.Health then
        tankHealBar:SetParent(E.UnitFrames.player.Health)
    end

    return tankHealBar
end

function TH:Configure()
    local frame = E.UnitFrames.player
    local healPrediction = frame.HealPrediction

    if frame.db.healPrediction then
        if not frame:IsElementEnabled("HealPrediction") then
            frame:EnableElement("HealPrediction")
        end

        if not frame.USE_PORTRAIT_OVERLAY then
            healPrediction.tankHealBar:SetParent(frame)
        else
            healPrediction.tankHealBar:SetParent(frame.Portrait.overlay)
        end

        local orientation = frame.db.health and frame.db.health.orientation
        if orientation then
            healPrediction.tankHealBar:SetOrientation(orientation)
        end

        local c = E.db.TankHealth.color
        healPrediction.tankHealBar:SetStatusBarColor(c.r, c.g, c.b, c.a)

    else
        if frame:IsElementEnabled("HealPrediction") then
            frame:DisableElement("HealPrediction")
        end
    end
end


local function UpdateFillBar(frame, previousTexture, bar, amount)
    -- This is duplicated code from ElvUI/Modules/unitframes/elements/healprediction.lua
    if (amount == 0) then
        bar:Hide();
        return previousTexture;
    end

    local orientation = frame.Health:GetOrientation()
    bar:ClearAllPoints()
    if orientation == "HORIZONTAL" then
        bar:Point("TOPLEFT", previousTexture, "TOPRIGHT");
        bar:Point("BOTTOMLEFT", previousTexture, "BOTTOMRIGHT");
    else
        bar:Point("BOTTOMRIGHT", previousTexture, "TOPRIGHT");
        bar:Point("BOTTOMLEFT", previousTexture, "TOPLEFT");
    end

    local totalWidth, totalHeight = frame.Health:GetSize();
    if orientation == "HORIZONTAL" then
        bar:Width(totalWidth);
    else
        bar:Height(totalHeight);
    end

    return bar:GetStatusBarTexture();
end

function TH:UpdateHealComm(unit, myIncomingHeal, allIncomingHeal, totalAbsorb)
    -- This is also mostly duplicated code from ElvUI/Modules/unitframes/elements/healprediction.lua
    local frame = E.UnitFrames.player
    local previousTexture = frame.Health:GetStatusBarTexture();

    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.myBar, myIncomingHeal);
    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.otherBar, allIncomingHeal);
    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.absorbBar, totalAbsorb);
    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.tankHealBar, 1);
end



function TH:Initialize()
    local p = E.UnitFrames.player
    p.HealPrediction.tankHealBar = TH.Construct()
    p:RegisterEvent("UNIT_POWER", TH.Override)
    if select(2, UnitClass("unit")) == "DRUID" then
        TH.receivedDamage = {}
        p:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", TH.TrackDamage)
    end
    TH:Configure()
    TH:Update()
    p.HealPrediction.Override = TH.Override

    --Register plugin so options are properly inserted when config is loaded
    EP:RegisterPlugin(addonName, TH.InsertOptions)
end

E:RegisterModule(TH:GetName()) --Register the module with ElvUI. ElvUI will now call TankHealth:Initialize() when ElvUI is ready to load our plugin.