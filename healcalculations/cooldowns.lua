local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

-- Cache Globals
local UnitAura = UnitAura

function TH:GetCooldownMultiplier()
    local multiplier = 1
    if UnitAura("player", "Guardian Spirit") then
        multiplier = multiplier + 0.4
    end

    if UnitAura("player", "Divine Hymn") then
        multiplier = multiplier + 0.1
    end

    if UnitAura("player", "Protection of Tyr") then
        multiplier = multiplier + 0.15
    end

    return multiplier
end
