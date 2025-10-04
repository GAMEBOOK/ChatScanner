-- CraftScan History
local addonName, addon = ...

-- Initialize history module
addon.History = {}
local history = addon.History

-- Libraries
local AceGUI = LibStub("AceGUI-3.0")

-- Local variables
local historyFrame
local matches = {}

-- Store a match
function history:StoreMatch(playerName, message, filterName, matchedKeyword, channel)
    local match = {
        playerName = playerName,
        message = message,
        filterName = filterName,
        matchedKeyword = matchedKeyword,
        channel = channel,
        timestamp = time(),
    }
    
    table.insert(matches, 1, match)
    
    -- Keep only last 100 matches
    while #matches > 100 do
        table.remove(matches)
    end
    
    return match
end

-- Get matches
function history:GetMatches()
    return matches
end

-- Clear history
function history:ClearHistory()
    wipe(matches)
    if historyFrame then
        self:UpdateHistoryList()
    end
end

-- Create history frame
function history:CreateHistoryFrame()
    if historyFrame then
        historyFrame:Show()
        self:UpdateHistoryList()
        return historyFrame
    end
    
    -- Create frame
    historyFrame = AceGUI:Create("Frame")
    historyFrame:SetTitle("CraftScan History")
    historyFrame:SetLayout("Flow")
    historyFrame:SetWidth(700)
    historyFrame:SetHeight(500)
    
    -- Add close callback
    historyFrame:SetCallback("OnClose", function(widget)
        AceGUI:Release(widget)
        historyFrame = nil
    end)
    
    -- Create scroll container
    local scrollContainer = AceGUI:Create("SimpleGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout("Fill")
    historyFrame:AddChild(scrollContainer)
    
    -- Create scroll frame
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List")
    scrollContainer:AddChild(scroll)
    historyFrame.scroll = scroll
    
    -- Add clear button
    local clearButton = AceGUI:Create("Button")
    clearButton:SetText("Clear History")
    clearButton:SetWidth(150)
    clearButton:SetCallback("OnClick", function()
        self:ClearHistory()
    end)
    historyFrame:AddChild(clearButton)
    
    -- Update history list
    self:UpdateHistoryList()
    
    return historyFrame
end

-- Update history list
function history:UpdateHistoryList()
    if not historyFrame or not historyFrame.scroll then return end
    
    local scroll = historyFrame.scroll
    scroll:ReleaseChildren()
    
    if #matches == 0 then
        local label = AceGUI:Create("Label")
        label:SetText("No matches found")
        label:SetFullWidth(true)
        scroll:AddChild(label)
        return
    end
    
    for i, match in ipairs(matches) do
        -- Create container for this entry
        local container = AceGUI:Create("InlineGroup")
        container:SetFullWidth(true)
        container:SetLayout("Flow")
        
        -- Find filter
        local filter
        for _, f in ipairs(addon.Config.db.profile.filters) do
            if f.name == match.filterName then
                filter = f
                break
            end
        end
        
        -- Set title based on filter
        if filter then
            container:SetTitle(string.format("|cff%02x%02x%02x%s|r", 
                                          filter.color.r * 255, 
                                          filter.color.g * 255, 
                                          filter.color.b * 255, 
                                          match.filterName))
        else
            container:SetTitle(match.filterName)
        end
        
        -- Add player info
        local playerInfo = AceGUI:Create("Label")
        playerInfo:SetText(string.format("%s (%s) - %s", 
                                      match.playerName, 
                                      match.channel, 
                                      date("%H:%M:%S", match.timestamp)))
        playerInfo:SetWidth(200)
        container:AddChild(playerInfo)
        
        -- Add message
        local message = AceGUI:Create("Label")
        message:SetText(match.message)
        message:SetWidth(400)
        container:AddChild(message)
        
        -- Add whisper button
        local whisperButton = AceGUI:Create("Button")
        whisperButton:SetText("Whisper")
        whisperButton:SetWidth(80)
        whisperButton:SetCallback("OnClick", function()
            ChatFrame_SendTell(match.playerName)
        end)
        container:AddChild(whisperButton)
        
        scroll:AddChild(container)
    end
end

-- Toggle history frame
function history:ToggleHistoryFrame()
    if historyFrame then
        historyFrame:Hide()
        AceGUI:Release(historyFrame)
        historyFrame = nil
    else
        self:CreateHistoryFrame()
    end
end
