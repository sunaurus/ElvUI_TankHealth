local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

function TH:Calculate_Monk()
    -- Stat multipliers
    local AP = UnitAttackPower("player")
    local energy = UnitPower("player")
    if pain < 15 then
        return 0
    end
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Healing spheres
    local spheres = 0
    if UnitBuff("player", "Healing Sphere") then
        spheres = select(4, UnitBuff("player", "Healing Sphere"))
    end

    local singleSphereHeal = (7.5 * AP) * versatilityMulti
    local totalHeal = singleSphereHeal * spheres

    return math.ceil(totalHeal)
end