-- RskChatScanner Keyword Preview
local addonName, addon = ...
local L = addon.L or {}

-- Initialize keyword preview module
addon.KeywordPreview = {}
local preview = addon.KeywordPreview

-- Create a frame for keyword preview
function preview:CreatePreviewFrame()
    if self.frame then
        return self.frame
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "RskChatScannerKeywordPreviewFrame", UIParent, "BackdropTemplate")
    frame:SetSize(300, 150)
    frame:SetPoint("CENTER", UIParent, "CENTER")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    
    -- Create title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText(L["Keyword Preview"] or "Aperçu des mots-clés")
    
    -- Create close button
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    -- Create content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -40)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    
    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -30, 0)
    
    -- Create scroll child
    local scrollChild = CreateFrame("Frame")
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetSize(scrollFrame:GetWidth(), 200)
    
    -- Create text display
    local textDisplay = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    textDisplay:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
    textDisplay:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0)
    textDisplay:SetJustifyH("LEFT")
    textDisplay:SetJustifyV("TOP")
    textDisplay:SetText("")
    
    -- Store references
    frame.title = title
    frame.content = content
    frame.scrollFrame = scrollFrame
    frame.scrollChild = scrollChild
    frame.textDisplay = textDisplay
    
    self.frame = frame
    return frame
end

-- Preview keywords
function preview:PreviewKeywords(keywordString)
    local frame = self:CreatePreviewFrame()
    
    -- Parse keywords
    local keywords = addon.core.ParseKeywords(keywordString)
    
    -- Build preview text
    local text = L["Keyword Analysis"] or "Analyse des mots-clés :\n\n"
    
    -- Standard keywords
    text = text .. "|cFFFFFFFF" .. (L["Standard Keywords"] or "Mots-clés standard") .. "|r\n"
    if #keywords.normal > 0 then
        for _, keyword in ipairs(keywords.normal) do
            text = text .. "- |cFF00FF00" .. keyword .. "|r\n"
        end
    else
        text = text .. "- " .. (L["None"] or "Aucun") .. "\n"
    end
    
    -- Required keywords
    text = text .. "\n|cFFFFFFFF" .. (L["Required Keywords"] or "Mots-clés requis") .. "|r\n"
    if #keywords.required > 0 then
        for _, keyword in ipairs(keywords.required) do
            text = text .. "- |cFFFF9900" .. keyword .. "|r\n"
        end
    else
        text = text .. "- " .. (L["None"] or "Aucun") .. "\n"
    end
    
    -- Keyword groups
    text = text .. "\n|cFFFFFFFF" .. (L["Keyword Groups"] or "Groupes de mots-clés") .. "|r\n"
    if #keywords.groups > 0 then
        for i, group in ipairs(keywords.groups) do
            text = text .. "- " .. (L["Group"] or "Groupe") .. " " .. i .. ": "
            for j, word in ipairs(group) do
                text = text .. "|cFF00CCFF" .. word .. "|r"
                if j < #group then
                    text = text .. " + "
                end
            end
            text = text .. "\n"
        end
    else
        text = text .. "- " .. (L["None"] or "Aucun") .. "\n"
    end
    
    -- Match logic
    text = text .. "\n|cFFFFFFFF" .. (L["Match Logic"] or "Logique de correspondance") .. "|r\n"
    
    local conditions = {}
    
    if #keywords.required > 0 then
        table.insert(conditions, (L["All required keywords must be present"] or "Tous les mots-clés requis doivent être présents"))
    end
    
    if #keywords.groups > 0 then
        table.insert(conditions, (L["All words in at least one group must be present"] or "Tous les mots d'au moins un groupe doivent être présents"))
    end
    
    if #keywords.normal > 0 then
        table.insert(conditions, (L["At least one standard keyword must be present"] or "Au moins un mot-clé standard doit être présent"))
    end
    
    if #conditions == 0 then
        text = text .. "- " .. (L["No keywords defined"] or "Aucun mot-clé défini") .. "\n"
    else
        for i, condition in ipairs(conditions) do
            if i == 1 then
                text = text .. "- " .. condition .. "\n"
            elseif i < #conditions then
                text = text .. "- " .. (L["AND"] or "ET") .. " " .. condition .. "\n"
            else
                text = text .. "- " .. (L["OR"] or "OU") .. " " .. condition .. "\n"
            end
        end
    end
    
    -- Set text and show frame
    frame.textDisplay:SetText(text)
    frame:Show()
end

-- Test keywords against a sample message
function preview:TestKeywords(keywordString, message)
    local frame = self:CreatePreviewFrame()
    
    -- Parse keywords
    local keywords = addon.core.ParseKeywords(keywordString)
    
    -- Test message
    local matches, matchedKeyword = addon.core.MessageMatchesKeywords(message, keywords)
    
    -- Build preview text
    local text = L["Keyword Test"] or "Test des mots-clés :\n\n"
    
    -- Message
    text = text .. "|cFFFFFFFF" .. (L["Test Message"] or "Message de test") .. "|r\n"
    text = text .. "- " .. message .. "\n\n"
    
    -- Match result
    text = text .. "|cFFFFFFFF" .. (L["Result"] or "Résultat") .. "|r\n"
    if matches then
        text = text .. "- |cFF00FF00" .. (L["MATCH"] or "CORRESPONDANCE") .. "|r\n"
        text = text .. "- " .. (L["Matched keyword"] or "Mot-clé correspondant") .. ": |cFF00CCFF" .. matchedKeyword .. "|r\n"
    else
        text = text .. "- |cFFFF0000" .. (L["NO MATCH"] or "PAS DE CORRESPONDANCE") .. "|r\n"
    end
    
    -- Set text and show frame
    frame.textDisplay:SetText(text)
    frame:Show()
end
