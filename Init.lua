-- ChatScanner PRO - Initialization file
local addonName, addon = ...

-- Déclaration locale pour éviter les erreurs de référence
if not addon then
    print("|cffff0000ChatScanner PRO:|r Erreur critique: addon non défini dans Init.lua")
    addon = {}
end

-- Version de l'addon
addon.version = "2.0.0"

-- Localization table
addon.L = {}

-- Debug function
addon.Debug = function(...)
    print("|cff00ff00ChatScanner Debug:|r", ...)
end

-- Initialize slash commands immediately
SLASH_CRAFTSCANCLASSIC1 = "/craftscan"
SLASH_CRAFTSCANCLASSIC2 = "/cs"

SlashCmdList["CRAFTSCANCLASSIC"] = function(msg)
    -- Open Ace3 config dialog
    local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
    if AceConfigDialog then
        AceConfigDialog:Open("ChatScanner")
    else
        print("|cffFF0000ChatScanner PRO:|r Error: AceConfigDialog not found")
    end
end

-- Create a frame to handle events
local loadingFrame = CreateFrame("Frame")
loadingFrame:RegisterEvent("ADDON_LOADED")
loadingFrame:RegisterEvent("PLAYER_LOGIN")

loadingFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        addon.Debug("Addon chargé")
        
        -- Initialize saved variables if they don't exist
        if not ChatScannerPRO_ClassicDB then
            ChatScannerPRO_ClassicDB = {}
        end
        
        -- S'assurer que les paramètres existent
        if not ChatScannerPRO_ClassicDB.settings then
            ChatScannerPRO_ClassicDB.settings = {
                soundEnabled = true,
                visualAlertEnabled = true,
                chatChannels = {
                    SAY = false,
                    YELL = false,
                    GUILD = true,
                    PARTY = false,
                    RAID = false,
                    CHANNEL = true, -- Trade, General, etc.
                    WHISPER = false,
                }
            }
        end
        
        -- S'assurer que les filtres existent
        if not ChatScannerPRO_ClassicDB.filters then
            ChatScannerPRO_ClassicDB.filters = {
                {
                    name = "WTS (Vente)",
                    keywords = "wts, vends, vend",
                    enabled = true,
                    color = {r = 1, g = 0.5, b = 0}
                },
                {
                    name = "Boost",
                    keywords = "boost, carry, port",
                    enabled = true,
                    color = {r = 0.5, g = 0.5, b = 1}
                },
                {
                    name = "WTB (Achat)",
                    keywords = "wtb, achète, cherche",
                    enabled = false,
                    color = {r = 0, g = 1, b = 0.5}
                },
                {
                    name = "LFG (Groupe)",
                    keywords = "lfg, lfm, lf tank, lf heal, lf dps",
                    enabled = false,
                    color = {r = 1, g = 1, b = 0}
                },
            }
        end
        
        -- S'assurer que l'historique des correspondances existe
        if not ChatScannerPRO_ClassicDB.matches then
            ChatScannerPRO_ClassicDB.matches = {}
        end
        
    elseif event == "PLAYER_LOGIN" then
        -- Print welcome message after a short delay
        C_Timer.After(1, function()
            print("|cffFFD700ChatScanner PRO|r v2.0.0 loaded. Type |cffffffff/cs|r to open options.")
        end)
    end
end)
