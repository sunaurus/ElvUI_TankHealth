local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');

function TH:Calculate_Druid_Artifact(a)
    local wildfleshRank = select(3, a.GetPowerInfo(200400))
    -- Wildflesh multiplier is 5% * rank
    return 1 + wildfleshRank * 0.05
end

function TH:Calculate_Druid()
    --unimplemented
    return 100000
end