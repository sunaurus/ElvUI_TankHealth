local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule('TankHealth');

function TH:GetArtifactMultiplier()
    local u, e, a = UIParent, "ARTIFACT_UPDATE", C_ArtifactUI

    local multiplier = 1

    local artifactClasses = {
        [128832] = "DH",
        [128402] = "DK",
        [128821] = "Druid",
        [128938] = "Monk",
        [128867] = "Paladin",
        [128288] = "Warrior"
    }

    local equippedArtifact = artifact.GetEquippedArtifactInfo()

    if not artifactClasses[equippedArtifact] then
        return multiplier
    end


    SetCVar("Sound_EnableAllSound", 0)
    u:UnregisterEvent(e)
    SocketInventoryItem(16)

    if artifactClasses[equippedArtifact] == "DH" then

        local devourSoulsRank = select(3, a.GetPowerInfo(1233))
        local tormentedSoulsRank = select(3, a.GetPowerInfo(1328))

        -- Devour souls multiplier is 3% * rank
        multiplier = 1 + devourSoulsRank * 0.03
        -- Tormented Souls multiplier is 10% * rank
        multiplier = multiplier * (1 + tormentedSoulsRank * 0.1)

    elseif artifactClasses[equippedArtifact] == "DK" then
        --unimplemented
    elseif artifactClasses[equippedArtifact] == "Druid" then
        local wildfleshRank = select(3, a.GetPowerInfo(200400))

        -- Wildflesh multiplier is 5% * rank
        multiplier = 1 + wildfleshRank * 0.05

    elseif artifactClasses[equippedArtifact] == "Monk" then
        --unimplemented
    elseif artifactClasses[equippedArtifact] == "Paladin" then
        --unimplemented
    elseif artifactClasses[equippedArtifact] == "Warrior" then
        --unimplemented
    end


    a.Clear()
    u:RegisterEvent(e)
    SetCVar("Sound_EnableAllSound", 1)

    return multiplier
end


