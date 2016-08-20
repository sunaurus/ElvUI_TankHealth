--Cache global variables
local UnitBuff = UnitBuff
local unpack = unpack
local GetSpellInfo = GetSpellInfo

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

-- Cache Globals
local UnitBuff = UnitBuff

function TH:GetCooldownMultiplier()

    -- Guardian Spirit
    local gsMulti = UnitBuff("player", GetSpellInfo(47788)) and 1.4 or 1

    -- Divine Hymn
    local dhMulti = UnitBuff("player", GetSpellInfo(64844)) and 1.1 or 1

    -- Protection of Tyr
    local potMulti = UnitBuff("player", GetSpellInfo(211210)) and 1.15 or 1


    return gsMulti * dhMulti * potMulti
end
