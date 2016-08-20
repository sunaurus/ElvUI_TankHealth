--Cache global variables
local UnitPower = UnitPower
local UnitAttackPower = UnitAttackPower
local unpack = unpack
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellCount = GetSpellCount
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

function TH:Calculate_Monk()
    local energy = UnitPower("player")
    if energy < 15 then
        return 0
    end

    -- Stat multipliers
    local APBase, APPos, APNeg = UnitAttackPower("player")
    local AP = APBase + APPos + APNeg

    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Healing spheres
    local spheres = GetSpellCount(115072) or 0

    local singleSphereHeal = (7.5 * AP) * versatilityMulti
    local totalHeal = singleSphereHeal * spheres

    return totalHeal
end