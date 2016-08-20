local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

function TH:Calculate_Monk()
    local energy = UnitPower("player")
    if energy < 15 then
        return 0
    end

    -- Stat multipliers
    local AP = UnitAttackPower("player")
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Healing spheres
    local spheres = GetSpellCount(115072) or 0

    local singleSphereHeal = (7.5 * AP) * versatilityMulti
    local totalHeal = singleSphereHeal * spheres

    return math.ceil(totalHeal)
end