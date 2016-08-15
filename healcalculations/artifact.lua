local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TH = E:GetModule("TankHealth");

function TH:GetArtifactMultiplier()
    local u, e, a = UIParent, "ARTIFACT_UPDATE", C_ArtifactUI

    local artifactFuncs = {
        [128832] = TH.Calculate_DH_Artifact,
        [128402] = TH.Calculate_DK_Artifact,
        [128821] = TH.Calculate_Druid_Artifact,
        [128938] = TH.Calculate_Monk_Artifact,
        [128867] = TH.Calculate_Paladin_Artifact,
        [128288] = TH.Calculate_Warrior_Artifact
    }

    local equippedArtifact = a.GetEquippedArtifactInfo()

    if not artifactFuncs[equippedArtifact] then
        return 1
    end


    SetCVar("Sound_EnableAllSound", 0)
    u:UnregisterEvent(e)
    SocketInventoryItem(16)

    local multiplier = artifactFuncs[equippedArtifact](a)
    a.Clear()

    u:RegisterEvent(e)
    SetCVar("Sound_EnableAllSound", 1)

    return multiplier
end


