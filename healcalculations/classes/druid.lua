--Code adapted from weakaura by Hamsda (with permission)
--https://wago.io/profile/Hamsda

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

local function GetArtifactMultiplier()
    local wildfleshRank = TH:GetArtifactTraitRank(200400)
    -- Wildflesh multiplier is 5% * rank
    return 1 + wildfleshRank * 0.05
end

function TH:Calculate_Druid()

    -- Stat multipliers
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)
    local mastery = GetMastery()
    local masteryMulti = 1 + (mastery / 100)

    -- Artifact trait multipliers
    local artifactMulti = TH:GetArtifactMultiplier()

    -- Cooldown multipliers
    local healMulti = GetCooldownMultiplier()

    -- Guardian of Elune
    local goeMulti = UnitBuff("player", GetSpellInfo(213680)) and 1.2 or 1

    -- Life Cocoon
    local lcMulti = UnitBuff("player", GetSpellInfo(116849)) and 1.5 or 1

    --T17
    local t17Multi = 1
    local t17n, _, _, t17s = UnitBuff("player", GetSpellInfo(177969))
    if t17n then
        t17Multi = 1 + t17s * 0.1
    end

    --T18
    local t18Multi = UnitBuff("player", GetSpellInfo(192081)) and aura_env.GetNumSetPieces("T18") >= 2 and 1.2 or 1

    --T19
    local t19Multi = 1
    local t19n, _, _, t19s = UnitBuff("player", GetSpellInfo(211160))
    if t19n then
        t19Multi = 1 + (t19s / 3)
    end


    local multiplier = versatilityMulti * artifactMulti * masteryMulti * goeMulti * lcMulti * t17Multi * t18Multi * t19Multi * healMulti

    -- Min healing, 5% of maxhealth:
    local minHeal = UnitHealthMax("player") * 0.05
    minHeal = minHeal * multiplier

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

    local totalHeal = (receivedDamage / 2) * multiplier

    if totalHeal < minHeal then
        totalHeal = minHeal
    end

    return math.floor(totalHeal) or 0
end
