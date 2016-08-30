--Code adapted from weakaura by MightBeGiant (with permission)
--http://www.mmo-champion.com/threads/1984610-Demon-Hunter-Weak-Auras-Thread?p=41713755&viewfull=1#post41713755

--Cache global variables
local UnitPower = UnitPower
local UnitAttackPower = UnitAttackPower
local UnitBuff = UnitBuff
local min = math.min
local select, unpack = select, unpack
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");


local function GetArtifactMultiplier()
    local devourSoulsRank = TH:GetArtifactTraitRank(212821)
    local tormentedSoulsRank = TH:GetArtifactTraitRank(214744)
    -- Devour souls multiplier is 3% * rank
    local multiplier = 1 + devourSoulsRank * 0.03
    -- Tormented Souls multiplier is 10% * rank
    multiplier = multiplier * (1 + tormentedSoulsRank * 0.1)
    return multiplier
end

function TH:Calculate_DH()

    local pain = UnitPower("player")
    if pain < 30 then
        return 0
    end

    -- Stat multipliers
    local APBase, APPos, APNeg = UnitAttackPower("player")
    local AP = APBase + APPos + APNeg

    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Artifact trait multipliers
    local artifactMulti = GetArtifactMultiplier()

    -- Soul Fragments healing
    local fragments = select(4, UnitBuff("player", GetSpellInfo(203981))) or 0

    local singleFragHeal = (2.5 * AP) * versatilityMulti
    local totalFragHeal = singleFragHeal * fragments

    -- Soul Cleave healing

    local baseHeal = 2 * AP * 5.5

    local cleaveHeal = baseHeal * versatilityMulti * (min(60, pain) / 60) * artifactMulti
    --    local cleaveHealMax = AP * healMulti * versatilityMulti * artifactMulti

    -- Total healing
    local totalHeal = (totalFragHeal + cleaveHeal)
    --    local totalHealMax = ((singleFragHeal * 5) + cleaveHealMax)

    return totalHeal
end