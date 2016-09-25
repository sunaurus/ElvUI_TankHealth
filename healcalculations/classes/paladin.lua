--Code adapted from weakaura by Hamsda (with permission)
--https://wago.io/profile/Hamsda

--Cache global variables
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitBuff = UnitBuff
local select, unpack = select, unpack
local GetCombatRatingBonus = GetCombatRatingBonus
local GetTalentInfo = GetTalentInfo
local GetSpellInfo = GetSpellInfo
local GetSpellCooldown = GetSpellCooldown
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

local function GetArtifactMultiplier()
    local scatterTheShadowsRank = TH:GetArtifactTraitRank(209223)
    -- Scatter the Shadows multiplier is 6% * rank
    return 1 + scatterTheShadowsRank * 0.06
end

function TH:Calculate_Paladin()

    local lcd = select(2, GetSpellCooldown(184092))
    local hcd = select(2, GetSpellCooldown(213652))

    if lcd > 0 or hcd > 0 then
        return 0
    end

    -- Get missing hp percentage
    local curHP = UnitHealth("player")
    local maxHP = UnitHealthMax("player")
    local missingHp = maxHP - curHP

    -- LOTP heals for 30% of missing health
    local healMulti = 0.30

    -- Stat multipliers
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Check if standing in Consecration or Consecrated Hammer is skilled
    local consMulti = ((select(4, GetTalentInfo(1, 3, 1))) or UnitBuff("player", GetSpellInfo(188370))) and 1.2 or 1

    -- Check for Avenging Wrath
    local awMulti = UnitBuff("player", GetSpellInfo(31884)) and (1 + (select(17, UnitBuff("player", GetSpellInfo(31884)))) / 100) or 1

    -- Check artifact traits

    local artifactMulti = GetArtifactMultiplier()


    -- Multiply everything
    local totalHeal = missingHp * healMulti * consMulti * versatilityMulti * awMulti * artifactMulti

    return totalHeal
end