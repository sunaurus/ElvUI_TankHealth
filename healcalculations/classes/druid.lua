--Initially based on work by Ooshraxa
--http://www.mmo-champion.com/threads/2024876-WA2-Guardian-Frenzied-Regen-Tracker

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');

function TH:Calculate_Druid_Artifact(a)
    local wildfleshRank = select(3, a.GetPowerInfo(200400))
    -- Wildflesh multiplier is 5% * rank
    return 1 + wildfleshRank * 0.05
end

function TH:Calculate_Druid()

    -- Stat multipliers
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMP = 1 + (versatility / 100)
    local mastery = GetMastery()
    local masteryMP = 1 + (mastery / 100)

    -- Artifact trait multipliers
    local artifactMultiplr = TH:GetArtifactMultiplier()

    -- Cooldown multipliers
    local healMultiplr = TH:GetCooldownMultiplier()

    -- Guardian of Elune
    local guardianOfElune = 1
    if UnitAura("player", "Guardian of Elune") then
        guardianOfElune = 1.2
    end

    -- Min healing, 5% of maxhealth:
    local minHeal = UnitHealthMax("player") * 0.05
    minHeal = ((minHeal * versatilityMP * artifactMultiplr) * masteryMP) * guardianOfElune * healMultiplr

    -- Received damage
    local now = time()
    local receivedDamage = 0
    for key, value in pairs(TH.receivedDamage) do
        -- Check if damage was done within past 5 seconds
        if key > now - 5 then
            receivedDamage = receivedDamage + value or 0
        else
            TH.receivedDamage[key] = nil
        end
    end

    -- Heal is only half of damage taken, plus Versatility:
    local totalHeal = (((receivedDamage / 2) * versatilityMP * artifactMultiplr) * masteryMP) * guardianOfElune * healMultiplr
    -- Only output heal value if it's greater than MinHeal:
    if totalHeal < minHeal then
        totalHeal = minHeal
    end

    return math.floor(totalHeal) or 0
end

function TH:TrackDamage(timeStamp, event, ...)

    if (string.find(event, '_DAMAGE')) then
        local _, _, _, _, _, destGUID, _, _, _, amount, sourceName, _, spellAmount = ...
        if (destGUID == UnitGUID('player')) then
            -- If it's a melee attack:
            if sourceName == -1 then
                TH.receivedDamage[timeStamp] = amount
            else
                TH.receivedDamage[timeStamp] = spellAmount
            end
        end
    end
end