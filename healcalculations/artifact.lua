--Cache global variables
local unpack, select = unpack, select

local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");
local LA = LibStub("LegionArtifacts-1.1")

function TH:GetArtifactTraitRank(traitId)
    local info = LA:GetPowerInfo(traitId)
    if info then
        return select(3, info)
    else
        return 0
    end
end


