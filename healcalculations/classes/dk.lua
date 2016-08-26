--Code adapted from weakaura by Hamsda (with permission)
--https://wago.io/profile/Hamsda

--Cache global variables
local UnitPower = UnitPower
local UnitBuff = UnitBuff
local UnitHealthMax = UnitHealthMax
local unpack, time, pairs = unpack, time, pairs
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE
local max = math.max

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

local function GetArtifactModifier()
    local vampiricFangsRank = TH:GetArtifactTraitRank(192544)
    -- Vampiric Fangs modifier is +5% to Vampiric Blood per rank
    return vampiricFangsRank * 0.05
end

function TH:Calculate_DK()
    local rpower = UnitPower("player")
    if rpower < 45 then
        return 0
    end
    -- Stat multipliers
    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    --Vampiric Blood
    --check artifact traits
    local vamp = 1.3 + GetArtifactModifier()
    local vampMulti = UnitBuff("player", GetSpellInfo(55233)) and vamp or 1

    -- Received damage
    local now = time()
    local receivedDamage = 0
    for key, value in pairs(TH.receivedDamage) do
        -- Check if damage was done within past 5 seconds
        if key > now - 5 then
            receivedDamage = receivedDamage + value or 0
        else
            TH.receivedDamage[key] = nil
        end
    end

    local totalHeal = (receivedDamage / 5) * versatilityMulti * vampMulti


    -- Minimum heal is 10% of max health
    local maxHP = UnitHealthMax("player")

    return max(totalHeal, maxHP * 0.1)
end