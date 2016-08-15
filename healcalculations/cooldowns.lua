local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

function TH:GetCooldownMultiplier()
    local multiplier = 1
    if UnitAura("player", "Guardian Spirit") then
        multiplier = multiplier + 0.4
    end

    if UnitAura("player", "Divine Hymn") then
        multiplier = multiplier + 0.1
    end

    return multiplier
end


