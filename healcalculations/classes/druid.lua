--Code adapted from weakaura by Hamsda (with permission)
--https://wago.io/profile/Hamsda

--Cache global variables
local UnitPower = UnitPower
local UnitHealthMax = UnitHealthMax
local UnitBuff = UnitBuff
local unpack, time, pairs, select = unpack, time, pairs, select
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetSpellCooldown = GetSpellCooldown
local GetMastery = GetMastery
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

local function GetArtifactMultiplier()
    local wildfleshRank = TH:GetArtifactTraitRank(200400)
    -- Wildflesh multiplier is 5% * rank
    return 1 + wildfleshRank * 0.05
end

function TH:Calculate_Druid()

    local rage = UnitPower("player")

    local cd = select(2, GetSpellCooldown(22842))

    if rage < 10 or cd > 0 then
        return 0
    end

    -- Stat multipliers
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)
    local mastery = GetMastery()
    local masteryMulti = 1 + (mastery / 100)

    -- Artifact trait multipliers
    local artifactMulti = GetArtifactMultiplier()

    -- Guardian of Elune
    local goeMulti = UnitBuff("player", GetSpellInfo(213680)) and 1.2 or 1

    -- Life Cocoon
    local lcMulti = UnitBuff("player", GetSpellInfo(116849)) and 1.5 or 1

    --T19
    local t19Multi = 1
    local t19n, _, _, t19s = UnitBuff("player", GetSpellInfo(211160))
    if t19n then
        t19Multi = 1 + (t19s / 3)
    end


    local multiplier = versatilityMulti * artifactMulti * masteryMulti * goeMulti * lcMulti * t19Multi

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

    return totalHeal or 0
end
