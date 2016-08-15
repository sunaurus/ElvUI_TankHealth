local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');

function TH:Calculate_Warrior()
    return 1000
end