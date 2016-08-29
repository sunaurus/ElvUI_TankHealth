--Code adapted from weakaura by Hamsda (with permission)
--https://wago.io/profile/Hamsda

--Cache global variables
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitBuff = UnitBuff
local UnitAttackPower = UnitAttackPower
local unpack, select = unpack, select
local max, min = math.max, math.min
local GetCombatRatingBonus = GetCombatRatingBonus
local GetTalentInfo = GetTalentInfo
local GetSpellInfo = GetSpellInfo
local GetSpellCooldown = GetSpellCooldown
local GetVersatilityBonus = GetVersatilityBonus
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE


local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

local function GetArtifactMultiplier()
    local scatterTheShadowsRank = TH:GetArtifactTraitRank(203225)
    -- Dragon Skin is 2% * rank
    return 1 + scatterTheShadowsRank * 0.02
end

function TH:Calculate_Warrior()
    --Rage
    local rage = UnitPower("player")

    local cd = select(2, GetSpellCooldown(190456))

    if rage < 20 or cd > 0 then
        return 0
    end
    local minRage, maxRage = 20, 60
    if UnitBuff("player", GetSpellInfo(202574)) then
        minRage, maxRage = 10, 30
    end
    local calcRage = max(minRage, min(maxRage, rage))

    -- Stat multipliers
    local APBase, APPos, APNeg = UnitAttackPower("player")
    local AP = APBase + APPos + APNeg

    local versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityMulti = 1 + (versatility / 100)

    -- Artifact multiplier
    local artifactMulti = GetArtifactMultiplier()

    --Dragon Scales
    local scalesMulti = UnitBuff("player", GetSpellInfo(203581)) and 1.4 or 1

    --Never Surrender
    local curHP = UnitHealth("player")
    local maxHP = UnitHealthMax("player")
    local misPerc = (maxHP - curHP) / maxHP
    local nevSur = select(4, GetTalentInfo(5, 2, 1))
    local nevSurMulti = nevSur and (1 + 0.75 * misPerc) or 1

    --Indomitable
    local indomMulti = select(4, GetTalentInfo(5, 3, 1)) and 1.25 or 1

    local curIP = select(17, UnitBuff("player", GetSpellInfo(190456))) or 0
    curIP = curIP / 0.9 --get the tooltip value instead of the absorb

    local maxIP = AP * 28 * versatilityMulti * indomMulti

    local newIP = maxIP * (calcRage / maxRage) * artifactMulti * scalesMulti * nevSurMulti

    local cap = maxIP * 3
    if nevSur then
        cap = cap * 1.75
    end

    local diff = cap - curIP

    local castIP = min(diff, newIP)

    return castIP

end