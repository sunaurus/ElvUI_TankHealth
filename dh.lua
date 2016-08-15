local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');

function TH:Calculate_DH()
    local defaultCrit = 16
    local critRating = GetCombatRating(CR_CRIT_SPELL)
    local critPercent = defaultCrit + (critRating / 350)

    -- Stat multipliers
    local AP = UnitAttackPower("player")
    local pain = UnitPower("player")
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMP = 1 + (versatility / 100)

    -- Trait multipliers
    -- I think this is from WA? Not sure
    --    local devourSouls = WA_GIANTDH_DEVOUR_SOULS_TRAIT
    local devourSouls = 1
    --    local tormentedSouls = WA_GIANTDH_TORMENTED_SOULS_TRAIT
    local tormentedSouls = 1

    -- Cooldown multipliers
    local healMultiplr = 1
    if UnitAura("player", "Guardian Spirit") then
        healMultiplr = healMultiplr + 0.4
    end

    if UnitAura("player", "Divine Hymn") then
        healMultiplr = healMultiplr + 0.1
    end

    -- Soul Fragments healing
    local fragments = 0
    if UnitBuff("player", "Soul Fragments") then
        fragments = select(4, UnitBuff("player", "Soul Fragments"))
    end

    local singleFragHeal = (2.5 * AP) * versatilityMP
    local totalFragHeal = (2.5 * AP) * fragments * versatilityMP

    -- Soul Cleave healing
    local cleaveHeal = ((2 * AP) * 4.5) * versatilityMP * (min(60, pain) / 60) * devourSouls * tormentedSouls
    local cleaveHealMax = ((2 * AP) * 4.5) * versatilityMP * devourSouls * tormentedSouls

    -- Total healing
    local totalHeal = (totalFragHeal + cleaveHeal) * healMultiplr
    local totalHealMax = ((singleFragHeal * 5) + cleaveHealMax) * healMultiplr

    return math.ceil(totalHeal)
end