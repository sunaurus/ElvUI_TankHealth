--Cache global variables
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGUID = UnitGUID
local min, max = math.min, math.max
local select, unpack = select, unpack
local CreateFrame = CreateFrame
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpellInfo = GetSpellInfo


local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:NewModule("TankHealth", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0"); --Create a plugin within ElvUI and adopt AceHook-3.0, AceEvent-3.0 and AceTimer-3.0. We can make use of these later.
local EP = LibStub("LibElvUIPlugin-1.0") --We can use this to automatically insert our GUI tables when ElvUI_Config is loaded.
local addonName, addonTable = ... --See http://www.wowinterface.com/forums/showthread.php?t=51502&p=304704&postcount=2

--Default options
P["TankHealth"] = {
    ["color"] = { r = 250 / 255, g = 128 / 255, b = 114 / 255, a = 0.3 },
    ["overheal"] = false,
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
        name = "|cff00b3ffTankHealth|r",
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
            overheal = {
                order = 2,
                type = "toggle",
                name = "Show overheal",
                get = function(info)
                    return E.db.TankHealth.overheal
                end,
                set = function(info, value)
                    E.db.TankHealth.overheal = value
                end,
            },
        },
    }
end

local function UpdateBar(bar, maxHealth, val)
    if (bar) then
        bar:SetMinMaxValues(0, maxHealth)
        bar:SetValue(val)
        bar:Show()
    end
end



function TH:Override(event, unit)
    -- Most of this is duplicated code from oUF/elements/healprediction.lua
    if (self.unit ~= unit) or not unit then return end

    local hp = self.HealPrediction
    hp.parent = self

    local myIncomingHeal = UnitGetIncomingHeals(unit, "player") or 0
    local allIncomingHeal = UnitGetIncomingHeals(unit) or 0
    local totalAbsorb = UnitGetTotalAbsorbs(unit) or 0
    local myCurrentHealAbsorb = UnitGetTotalHealAbsorbs(unit) or 0
    local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)

    if (health < myCurrentHealAbsorb) then
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

    if (health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then

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



    local cdMulti = TH:GetCooldownMultiplier()

    local tankHeal = totalAbsorb + hp.calcFunc() * cdMulti

    if not E.db.TankHealth.overheal then
        tankHeal = min(maxHealth - health, tankHeal)
    end

    --    print("tankHeal: " .. tankHeal)
    --    print("totalAbsorb + CalculateHeal(): " .. totalAbsorb + CalculateHeal())

    UpdateBar(hp.myBar, maxHealth, myIncomingHeal)
    UpdateBar(hp.otherbar, maxHealth, otherIncomingHeal)
    UpdateBar(hp.absorbBar, maxHealth, totalAbsorb)
    UpdateBar(hp.healAbsorbBar, maxHealth, myCurrentHealAbsorb)
    UpdateBar(hp.tankHealBar, maxHealth, tankHeal)

    TH:UpdateHealComm()
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

local function UpdateFillBar(frame, previousTexture, bar)
    -- This is duplicated code from ElvUI/Modules/unitframes/elements/healprediction.lua
    if (bar:GetValue() == 0) then
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

function TH:UpdateHealComm()
    -- This is also mostly duplicated code from ElvUI/Modules/unitframes/elements/healprediction.lua
    local frame = E.UnitFrames.player
    local previousTexture = frame.Health:GetStatusBarTexture();

    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.myBar);
    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.otherBar);
    previousTexture = UpdateFillBar(frame, previousTexture, frame.HealPrediction.absorbBar);
    UpdateFillBar(frame, previousTexture, frame.HealPrediction.tankHealBar);
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



function TH:TrackDamage(event, time, subevent, ...)
    --Code adapted from weakaura by Hamsda (with permission)
    --https://wago.io/profile/Hamsda
    --target = player
    if select(6, ...) == UnitGUID("player") then

        --set selection offset to amount for baseline SWING_DAMAGE
        local offset = 10

        --handle SPELL_ABSORBED events
        if subevent == "SPELL_ABSORBED" then

            --if a spell gets absorbed, there are 3 additional parameters regarding which spell got absorbed, so move the offset 3 more places
            if GetSpellInfo((select(offset, ...))) == (select(offset + 1, ...)) then
                offset = offset + 3
            end

            --absorb value is 7 places further
            offset = offset + 7
            TH.receivedDamage[time] = select(offset, ...)

            --handle regular XYZ_DAMAGE events
        elseif subevent:find("_DAMAGE") then

            --don't include environmental damage (like falling etc)
            if not subevent:find("ENVIRONMENTAL") then

                --move offset by 3 places for spell info for RANGE_ and SPELL_ prefixes
                if subevent:find("SPELL") then
                    offset = offset + 3
                elseif subevent:find("RANGE") then
                    offset = offset + 3
                end

                TH.receivedDamage[time] = select(offset, ...)
            end
        end
    end
end

function TH:CheckSpec()
    local p = E.UnitFrames.player

    local specIndex = GetSpecialization()
    local specId = GetSpecializationInfo(specIndex)


    local calcFuncs = {
        [581] = TH.Calculate_DH,
        [250] = TH.Calculate_DK,
        [104] = TH.Calculate_Druid,
        [268] = TH.Calculate_Monk,
        [66] = TH.Calculate_Paladin,
        [73] = TH.Calculate_Warrior
    }
    if calcFuncs[specId] then
        p.HealPrediction.calcFunc = calcFuncs[specId]
        p.HealPrediction.tankHealBar = TH.Construct()
        p:RegisterEvent("UNIT_POWER", TH.Override)
        if specId == 104 or specId == 250 then
            TH.receivedDamage = {}
            p:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", TH.TrackDamage)
        end
        TH:Configure()
        TH:Update()
        p.HealPrediction.Override = TH.Override
    else
        p.HealPrediction.Override = nil
        p:UnregisterEvent("UNIT_POWER", TH.Override)
        p:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", TH.TrackDamage)
    end
end

function TH:Initialize()
    E.UnitFrames.player:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", TH.CheckSpec)
    TH:CheckSpec()
    --Register plugin so options are properly inserted when config is loaded
    EP:RegisterPlugin(addonName, TH.InsertOptions)
end

E:RegisterModule(TH:GetName()) --Register the module with ElvUI. ElvUI will now call TankHealth:Initialize() when ElvUI is ready to load our plugin.
