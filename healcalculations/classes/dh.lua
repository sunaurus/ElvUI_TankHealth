--Code modified from WA by MightBeGiant
--http://www.mmo-champion.com/threads/1984610-Demon-Hunter-Weak-Auras-Thread?p=41713755&viewfull=1#post41713755

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');


function TH:Calculate_DH_Artifact(a)
    local devourSoulsRank = select(3, a.GetPowerInfo(1233))
    local tormentedSoulsRank = select(3, a.GetPowerInfo(1328))

    -- Devour souls multiplier is 3% * rank
    multiplier = 1 + devourSoulsRank * 0.03
    -- Tormented Souls multiplier is 10% * rank
    multiplier = multiplier * (1 + tormentedSoulsRank * 0.1)

    return multiplier
end

function TH:Calculate_DH()
    local defaultCrit = 16
    local critRating = GetCombatRating(CR_CRIT_SPELL)
    local critPercent = defaultCrit + (critRating / 350)

    -- Stat multipliers
    local AP = UnitAttackPower("player")
    local pain = UnitPower("player")
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMP = 1 + (versatility / 100)

    -- Artifact trait multipliers
    local artifactMultiplr = TH:GetArtifactMultiplier()

    -- Cooldown multipliers
    local healMultiplr = TH:GetCooldownMultiplier()

    -- Soul Fragments healing
    local fragments = 0
    if UnitBuff("player", "Soul Fragments") then
        fragments = select(4, UnitBuff("player", "Soul Fragments"))
    end

    local singleFragHeal = (2.5 * AP) * versatilityMP
    local totalFragHeal = (2.5 * AP) * fragments * versatilityMP

    -- Soul Cleave healing
    local cleaveHeal = ((2 * AP) * 4.5) * versatilityMP * (min(60, pain) / 60) * artifactMultiplr
    local cleaveHealMax = ((2 * AP) * 4.5) * versatilityMP * artifactMultiplr

    -- Total healing
    local totalHeal = (totalFragHeal + cleaveHeal) * healMultiplr
    local totalHealMax = ((singleFragHeal * 5) + cleaveHealMax) * healMultiplr

    return math.ceil(totalHeal)
end