-- ChatScanner PRO - AutoFlood Module
-- Integrated from AutoFlood addon by LenweSaralonde
local addonName, addon = ...

-- Initialize AutoFlood module
addon.AutoFlood = {}
local autoFlood = addon.AutoFlood

-- Constants
local MAX_RATE = 10
local isFloodActive = false

--- Return channel system and number
-- @param channel (string) Channel name
-- @return system (string|nil)
-- @return channelNumber (int|nil)
-- @return channelName (string|nil)
local function GetChannel(channel)
    local ch = strlower(strtrim(channel))
    if ch == "say" or ch == "s" then
        return "SAY", nil, ch
    elseif ch == "guild" or ch == "g" then
        return "GUILD", nil, ch
    elseif ch == "raid" or ch == "ra" then
        return "RAID", nil, ch
    elseif ch == "party" or ch == "p" or ch == "gr" then
        return "PARTY", nil, ch
    elseif ch == "i" then
        return "INSTANCE_CHAT", nil, ch
    elseif ch == "bg" then
        return "BATTLEGROUND", nil, ch
    elseif GetChannelName(channel) ~= 0 then
        return "CHANNEL", (GetChannelName(channel)), channel
    end
    return nil, nil, nil
end

--- Replace variables in message text
local function ReplaceVariables(text)
    if not text then return "" end
    
    -- Get player info
    local playerName = UnitName("player") or "Unknown"
    local playerLevel = UnitLevel("player") or "??"
    local _, playerClass = UnitClass("player")
    local playerClassName = playerClass or "Unknown"
    
    -- Get localized class name with color
    local classColor = RAID_CLASS_COLORS[playerClass]
    local coloredClass = playerClassName
    if classColor then
        coloredClass = string.format("|cff%02x%02x%02x%s|r", 
            classColor.r * 255, classColor.g * 255, classColor.b * 255, playerClassName)
    end
    
    -- Get current zone
    local zone = GetZoneText() or GetSubZoneText() or "Unknown"
    
    -- Get current time
    local hour, minute = GetGameTime()
    local timeStr = string.format("%02d:%02d", hour, minute)
    
    -- Get guild name
    local guildName = GetGuildInfo("player") or "No Guild"
    
    -- Replace variables
    text = string.gsub(text, "{name}", playerName)
    text = string.gsub(text, "{level}", tostring(playerLevel))
    text = string.gsub(text, "{class}", playerClassName)
    text = string.gsub(text, "{coloredclass}", coloredClass)
    text = string.gsub(text, "{zone}", zone)
    text = string.gsub(text, "{time}", timeStr)
    text = string.gsub(text, "{guild}", guildName)
    
    return text
end

--- Send message function (called by timer)
local function SendFloodMessage()
    if not isFloodActive then return end
    
    local config = addon.Config.db.profile.autoFlood
    
    -- Get enabled messages
    local enabledMessages = {}
    for _, msg in ipairs(config.messages) do
        if msg.enabled then
            table.insert(enabledMessages, msg)
        end
    end
    
    if #enabledMessages == 0 then
        print("|cffFF0000ChatScanner PRO:|r No enabled messages")
        autoFlood:Stop()
        return
    end
    
    -- Get current message (with rotation)
    local currentMsg = enabledMessages[config.currentIndex]
    if not currentMsg then
        config.currentIndex = 1
        currentMsg = enabledMessages[1]
    end
    
    -- Move to next message for next iteration
    config.currentIndex = config.currentIndex + 1
    if config.currentIndex > #enabledMessages then
        config.currentIndex = 1
    end
    
    -- Replace variables in message text
    local messageText = ReplaceVariables(currentMsg.text)
    
    local system, channelNumber = GetChannel(currentMsg.channel)
    
    if system == nil then
        print("|cffFF0000ChatScanner PRO:|r Invalid channel: " .. currentMsg.channel)
        -- Try next message
        C_Timer.After(1, SendFloodMessage)
        return
    end
    
    -- Try MessageQueue first (if available)
    local success = false
    if MessageQueue and MessageQueue.SendChatMessage then
        -- Check if there are pending messages
        if not MessageQueue.GetNumPendingMessages or MessageQueue.GetNumPendingMessages() == 0 then
            MessageQueue.SendChatMessage(messageText, system, nil, channelNumber)
            success = true
        end
    end
    
    -- Fallback to direct SendChatMessage (works in Classic)
    if not success then
        local ok, err = pcall(function()
            SendChatMessage(messageText, system, nil, channelNumber)
        end)
        if ok then
            success = true
        end
    end
    
    if success then
        print("|cff00ff00[AutoFlood]|r Message sent to " .. currentMsg.channel)
    else
        print("|cffFF0000ChatScanner PRO:|r Failed to send message")
    end
    
    -- Schedule next message
    if isFloodActive then
        C_Timer.After(config.rate, SendFloodMessage)
    end
end

--- Start AutoFlood
function autoFlood:Start()
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        print("|cffFF0000ChatScanner PRO:|r Config not initialized")
        return
    end
    
    local config = addon.Config.db.profile.autoFlood
    
    -- Validate settings
    if not config.messages or #config.messages == 0 then
        print("|cffFF0000ChatScanner PRO:|r Please add at least one message first")
        return
    end
    
    -- Check if at least one message is enabled
    local hasEnabled = false
    for _, msg in ipairs(config.messages) do
        if msg.enabled then
            hasEnabled = true
            break
        end
    end
    
    if not hasEnabled then
        print("|cffFF0000ChatScanner PRO:|r Please enable at least one message")
        return
    end
    
    if config.rate < MAX_RATE then
        print("|cffFF0000ChatScanner PRO:|r Rate must be at least " .. MAX_RATE .. " seconds")
        return
    end
    
    isFloodActive = true
    config.currentIndex = 1 -- Reset rotation
    
    print("|cff00ff00ChatScanner PRO:|r AutoFlood started")
    print("|cffFFFFFF  Messages:|r " .. #config.messages .. " (" .. (hasEnabled and "rotating" or "none enabled") .. ")")
    print("|cffFFFFFF  Rate:|r " .. config.rate .. " seconds")
    
    -- Start the timer loop
    C_Timer.After(1, SendFloodMessage) -- Send first message after 1 second
end

--- Stop AutoFlood
function autoFlood:Stop()
    isFloodActive = false
    print("|cff00ff00ChatScanner PRO:|r AutoFlood stopped")
end

-- Check if AutoFlood is running
function autoFlood:IsRunning()
    return isFloodActive
end

--- Toggle AutoFlood
function autoFlood:Toggle()
    if isFloodActive then
        self:Stop()
    else
        self:Start()
    end
end

--- Check if AutoFlood is active
function autoFlood:IsActive()
    return isFloodActive
end

--- Get status info
function autoFlood:GetStatus()
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        return "Config not initialized"
    end
    
    local config = addon.Config.db.profile.autoFlood
    local status = isFloodActive and "|cff00ff00ACTIVE|r" or "|cffFF0000INACTIVE|r"
    
    return string.format("AutoFlood: %s\nMessage: %s\nChannel: %s\nRate: %d seconds", 
        status, config.message, config.channel, config.rate)
end

--- Initialize
function autoFlood:Initialize()
    -- Nothing to do here, frame is already created
end
