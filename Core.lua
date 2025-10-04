-- RskChatScanner Core
local addonName, addon = ...

-- Initialize addon with Ace3
addon.core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local core = addon.core

-- Libraries (with fallbacks if missing)
local LSM = LibStub("LibSharedMedia-3.0", true) or {}

-- Add fallback methods if library is missing
if not LSM.Fetch then
    LSM.Fetch = function(_, mediatype, key)
        if mediatype == "statusbar" then
            return "Interface\\TargetingFrame\\UI-StatusBar"
        elseif mediatype == "font" then
            return "Fonts\\FRIZQT__.TTF"
        elseif mediatype == "sound" then
            return "Sound\\Interface\\iTellMessage.ogg"
        end
    end
end

-- Expose activeBars globally so UI/Bars.lua can access it
addon.activeBars = addon.activeBars or {}
local activeBars = addon.activeBars
local barAnchors = {}
local matches = {}
local barsLocked = true

-- Function to create anchor if it doesn't exist
local function CreateAnchor()
    if barAnchors[1] then
        return barAnchors[1]
    end
    
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        return nil
    end
    
    local appearance = addon.Config.db.profile.appearance
    
    -- Create anchor frame
    local anchor = CreateFrame("Frame", "RskChatScannerBarAnchor", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    anchor:SetSize(appearance.barWidth, appearance.barHeight)
    anchor:SetPoint(appearance.barPosition.point, 
                   UIParent, 
                   appearance.barPosition.relativePoint, 
                   appearance.barPosition.x, 
                   appearance.barPosition.y)
    anchor:SetMovable(true)
    anchor:EnableMouse(false) -- Locked by default
    anchor:RegisterForDrag("LeftButton")
    
    -- Add visual background when unlocked
    if anchor.SetBackdrop then
        anchor:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        anchor:SetBackdropColor(0, 1, 0, 0.3)
        anchor:SetBackdropBorderColor(0, 1, 0, 0.8)
    end
    
    -- Add text
    anchor.text = anchor:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    anchor.text:SetPoint("CENTER")
    anchor.text:SetText("Drag to move")
    anchor.text:SetTextColor(1, 1, 1)
    
    -- Hide anchor by default (locked)
    anchor:Hide()
    
    anchor:SetScript("OnDragStart", function(self) self:StartMoving() end)
    anchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        appearance.barPosition.point = point
        appearance.barPosition.relativePoint = relativePoint
        appearance.barPosition.x = x
        appearance.barPosition.y = y
    end)
    
    barAnchors[1] = anchor
    return anchor
end

-- Function to toggle lock/unlock bars
local function ToggleBarsLock()
    barsLocked = not barsLocked
    
    -- Create anchor if it doesn't exist
    local anchor = CreateAnchor()
    
    if anchor then
        if barsLocked then
            anchor:EnableMouse(false)
            anchor:Hide()
            print("|cff00ff00ChatScanner PRO:|r Bars locked")
        else
            anchor:EnableMouse(true)
            anchor:Show()
            print("|cff00ff00ChatScanner PRO:|r Bars unlocked - Drag the green anchor to move notifications")
        end
    else
        print("|cff00ff00ChatScanner PRO:|r Error: Could not create anchor")
    end
end

-- Function to reposition all active bars
local function RepositionBars()
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        return
    end
    
    local appearance = addon.Config.db.profile.appearance
    local anchor = barAnchors[1]
    
    if not anchor then return end
    
    for i, bar in ipairs(activeBars) do
        bar:ClearAllPoints()
        local offset = (i - 1) * (appearance.barHeight + appearance.barSpacing)
        if appearance.barGrowDirection == "UP" then
            bar:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, offset)
        else
            bar:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -offset)
        end
    end
end

-- Parse comma-separated keywords with special syntax
function core.ParseKeywords(keywordString)
    if not keywordString or keywordString == "" then
        return { normal = {}, required = {}, groups = {} }
    end
    
    local result = {
        normal = {},   -- Normal keywords (any one is enough)
        required = {}, -- Required keywords (all must be present)
        groups = {}    -- Groups of keywords (all in a group must be present)
    }
    
    -- Process normal keywords (separated by commas)
    for keyword in string.gmatch(keywordString, "([^,]+)") do
        local trimmed = string.trim(keyword):lower()
        
        -- Check for required keywords with + syntax
        if string.match(trimmed, "^%+(.+)%+$") then
            local required = string.match(trimmed, "^%+(.+)%+$")
            table.insert(result.required, required)
        
        -- Check for keyword groups with & syntax
        elseif string.match(trimmed, "^%&(.+)%&$") then
            local group = string.match(trimmed, "^%&(.+)%&$")
            local groupWords = {}
            
            for word in string.gmatch(group, "([^%s]+)") do
                table.insert(groupWords, word:lower())
            end
            
            if #groupWords > 0 then
                table.insert(result.groups, groupWords)
            end
        
        -- Normal keywords
        else
            table.insert(result.normal, trimmed:lower())
        end
    end
    
    return result
end

-- Check if message matches keywords according to our flexible system
function core.MessageMatchesKeywords(message, keywords)
    local lowerMessage = string.lower(message)
    local matchedKeyword = nil
    
    -- Check required keywords (all must be present)
    if #keywords.required > 0 then
        for _, keyword in ipairs(keywords.required) do
            if not string.find(lowerMessage, keyword, 1, true) then
                return false, nil -- Missing a required keyword
            end
        end
        matchedKeyword = table.concat(keywords.required, "+")
    end
    
    -- Check keyword groups (all keywords in at least one group must be present)
    local groupMatched = false
    if #keywords.groups > 0 then
        for _, group in ipairs(keywords.groups) do
            local allInGroupFound = true
            for _, word in ipairs(group) do
                if not string.find(lowerMessage, word, 1, true) then
                    allInGroupFound = false
                    break
                end
            end
            if allInGroupFound then
                groupMatched = true
                if not matchedKeyword then
                    matchedKeyword = table.concat(group, "&")
                end
                break
            end
        end
        -- If we have groups but none matched, and no required keywords matched either,
        -- then we need to check normal keywords
        if not groupMatched and #keywords.required == 0 then
            -- Continue to normal keywords check
        elseif not groupMatched and #keywords.required > 0 then
            -- Required keywords matched but no group matched
            return true, matchedKeyword
        else
            -- A group matched
            return true, matchedKeyword
        end
    end
    
    -- If we have required keywords but no normal keywords, and required matched,
    -- then we're done
    if #keywords.required > 0 and #keywords.normal == 0 then
        return true, matchedKeyword
    end
    
    -- Check normal keywords (any one is enough)
    for _, keyword in ipairs(keywords.normal) do
        if string.find(lowerMessage, keyword, 1, true) then
            return true, keyword
        end
    end
    
    -- If we have required keywords but no normal keywords matched,
    -- we still consider it a match
    if #keywords.required > 0 then
        return true, matchedKeyword
    end
    
    -- No match found
    return false, nil
end

-- Get player info (level, class, guild)
local function GetPlayerInfo(playerName)
    local info = {
        name = playerName,
        level = nil,
        class = nil,
        classColor = nil,
        guild = nil,
        classIcon = nil
    }
    
    -- Try to get info from target/mouseover/party/raid
    local unit = nil
    if UnitName("target") == playerName then
        unit = "target"
    elseif UnitName("mouseover") == playerName then
        unit = "mouseover"
    else
        -- Check party
        for i = 1, 4 do
            if UnitName("party" .. i) == playerName then
                unit = "party" .. i
                break
            end
        end
        -- Check raid
        if not unit then
            for i = 1, 40 do
                if UnitName("raid" .. i) == playerName then
                    unit = "raid" .. i
                    break
                end
            end
        end
    end
    
    if unit then
        info.level = UnitLevel(unit)
        local _, class = UnitClass(unit)
        info.class = class
        
        -- Get class color
        if class and RAID_CLASS_COLORS[class] then
            info.classColor = RAID_CLASS_COLORS[class]
        end
        
        -- Get class icon
        local classIcons = {
            WARRIOR = "Interface\\Icons\\ClassIcon_Warrior",
            PALADIN = "Interface\\Icons\\ClassIcon_Paladin",
            HUNTER = "Interface\\Icons\\ClassIcon_Hunter",
            ROGUE = "Interface\\Icons\\ClassIcon_Rogue",
            PRIEST = "Interface\\Icons\\ClassIcon_Priest",
            SHAMAN = "Interface\\Icons\\ClassIcon_Shaman",
            MAGE = "Interface\\Icons\\ClassIcon_Mage",
            WARLOCK = "Interface\\Icons\\ClassIcon_Warlock",
            DRUID = "Interface\\Icons\\ClassIcon_Druid"
        }
        info.classIcon = classIcons[class]
        
        -- Get guild
        info.guild = GetGuildInfo(unit)
    end
    
    return info
end

-- Add player to blacklist
function core:AddToBlacklist(playerName, duration, reason)
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile.blacklist then
        return
    end
    
    local blacklist = addon.Config.db.profile.blacklist.players
    
    -- Check if player is already blacklisted
    for _, entry in ipairs(blacklist) do
        if entry.name == playerName then
            print("|cffFF6B6BChatScanner PRO:|r " .. playerName .. " is already blacklisted")
            return
        end
    end
    
    -- Add to blacklist
    table.insert(blacklist, {
        name = playerName,
        reason = reason or "No reason",
        timestamp = time(),
        duration = duration  -- 0 = forever, otherwise seconds
    })
    
    local durationText = duration == 0 and "forever" or (duration == 3600 and "1 hour" or "24 hours")
    print("|cffFF0000ChatScanner PRO:|r " .. playerName .. " added to blacklist for " .. durationText)
    
    -- Close all notifications from this player
    self:CloseNotificationsFromPlayer(playerName)
end

-- Close all notifications from a specific player
function core:CloseNotificationsFromPlayer(playerName)
    if addon.Bars and addon.Bars.ClosePlayerBars then
        addon.Bars:ClosePlayerBars(playerName)
    end
end

-- Check if player is blacklisted
function core:IsBlacklisted(playerName)
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile.blacklist then
        return false
    end
    
    local blacklist = addon.Config.db.profile.blacklist.players
    local currentTime = time()
    
    for i = #blacklist, 1, -1 do
        local entry = blacklist[i]
        if entry.name == playerName then
            -- Check if temporary blacklist has expired
            if entry.duration > 0 then
                local expiresAt = entry.timestamp + entry.duration
                if currentTime >= expiresAt then
                    -- Remove expired entry
                    table.remove(blacklist, i)
                    return false
                end
            end
            return true
        end
    end
    
    return false
end

-- Show template menu
function core:ShowTemplateMenu(playerName, parent)
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        return
    end
    
    local templates = addon.Config.db.profile.templates
    if not templates or #templates == 0 then
        print("|cffFF0000ChatScanner PRO:|r No templates available. Create templates in the Templates tab.")
        ChatFrame_SendTell(playerName)
        return
    end
    
    -- Get enabled templates
    local enabledTemplates = {}
    for _, template in ipairs(templates) do
        if template.enabled then
            table.insert(enabledTemplates, template)
        end
    end
    
    if #enabledTemplates == 0 then
        print("|cffFF0000ChatScanner PRO:|r No enabled templates")
        ChatFrame_SendTell(playerName)
        return
    end
    
    -- If only one template, send it directly
    if #enabledTemplates == 1 then
        local template = enabledTemplates[1]
        SendChatMessage(template.text, "WHISPER", nil, playerName)
        print("|cff00ff00ChatScanner PRO:|r Sent template '" .. template.name .. "' to " .. playerName)
        return
    end
    
    -- Multiple templates: show selection dialog
    StaticPopupDialogs["CHATSCANNER_SELECT_TEMPLATE"] = {
        text = "Select template to send to " .. playerName .. ":",
        button1 = "Cancel",
        OnShow = function(self)
            -- Create buttons for each template
            local yOffset = -60
            for i, template in ipairs(enabledTemplates) do
                local btn = CreateFrame("Button", nil, self, "UIPanelButtonTemplate")
                btn:SetSize(200, 25)
                btn:SetPoint("TOP", self, "TOP", 0, yOffset)
                btn:SetText(template.name)
                btn:SetScript("OnClick", function()
                    SendChatMessage(template.text, "WHISPER", nil, playerName)
                    print("|cff00ff00ChatScanner PRO:|r Sent template '" .. template.name .. "' to " .. playerName)
                    self:Hide()
                end)
                yOffset = yOffset - 30
            end
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3
    }
    StaticPopup_Show("CHATSCANNER_SELECT_TEMPLATE")
end

-- Create a notification bar
local function CreateBar(match)
    -- Get settings
    local settings = addon.Config.db.profile
    local appearance = settings.appearance
    
    -- Find filter
    local filter
    for _, f in ipairs(settings.filters) do
        if f.name == match.filterName then
            filter = f
            break
        end
    end
    
    if not filter then return end
    
    -- Play sound if enabled (global and per-filter)
    if settings.settings.soundEnabled and (filter.playSound ~= false) then
        local soundFile = LSM:Fetch("sound", appearance.sound) or "Sound\\Interface\\iTellMessage.ogg"
        PlaySoundFile(soundFile, "Master")
    end
    
    -- Create a frame for the notification bar
    local bar = CreateFrame("Frame", nil, UIParent)
    bar:SetSize(appearance.barWidth, appearance.barHeight)
    
    -- Store match data for later reference (blacklist, etc.)
    bar.match = match
    
    -- Set initial opacity to 0 for fade-in animation
    bar:SetAlpha(0)
    
    -- Add main texture background using selected bar texture
    bar.bg = bar:CreateTexture(nil, "BACKGROUND")
    bar.bg:SetAllPoints(bar)
    local barTexture = LSM:Fetch("statusbar", appearance.barTexture) or "Interface\\TargetingFrame\\UI-StatusBar"
    bar.bg:SetTexture(barTexture)
    bar.bg:SetVertexColor(filter.color.r, filter.color.g, filter.color.b, appearance.barOpacity or 0.9)
    
    -- Add simple border
    bar.border = CreateFrame("Frame", nil, bar, BackdropTemplateMixin and "BackdropTemplate")
    bar.border:SetAllPoints(bar)
    if bar.border.SetBackdrop then
        bar.border:SetBackdrop({
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        bar.border:SetBackdropBorderColor(0, 0, 0, 0.8)
    end
    
    -- Get player info
    local playerInfo = GetPlayerInfo(match.playerName)
    
    -- Get font settings for later use
    local fontPath = LSM:Fetch("font", appearance.font) or "Fonts\\FRIZQT__.TTF"
    local fontSize = appearance.fontSize or 12
    
    -- Add icon on the left (filter icon, class icon, or default)
    bar.icon = bar:CreateTexture(nil, "ARTWORK")
    local iconSize = appearance.barHeight - 6
    bar.icon:SetSize(iconSize, iconSize)
    bar.icon:SetPoint("LEFT", bar, "LEFT", 3, 0)
    
    -- Priority: Filter icon > Class icon > Default icon
    if filter.icon and filter.icon ~= "" then
        bar.icon:SetTexture(filter.icon)
    elseif playerInfo.classIcon then
        bar.icon:SetTexture(playerInfo.classIcon)
    else
        bar.icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    end
    
    -- Create compact button container on the right (2 rows)
    local buttonWidth = 60
    local buttonHeight = (appearance.barHeight - 8) / 2 -- Split height in 2
    local buttonSpacing = 2
    
    -- Container frame for buttons
    bar.buttonContainer = CreateFrame("Frame", nil, bar)
    bar.buttonContainer:SetSize(buttonWidth * 2 + buttonSpacing, appearance.barHeight - 6)
    bar.buttonContainer:SetPoint("RIGHT", bar, "RIGHT", -3, 0)
    
    -- Top row: Reply and Invite
    bar.replyButton = CreateFrame("Button", nil, bar.buttonContainer)
    bar.replyButton:SetSize(buttonWidth, buttonHeight)
    bar.replyButton:SetPoint("TOPLEFT", bar.buttonContainer, "TOPLEFT", 0, 0)
    
    bar.replyButton.bg = bar.replyButton:CreateTexture(nil, "BACKGROUND")
    bar.replyButton.bg:SetAllPoints()
    bar.replyButton.bg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
    bar.replyButton.text = bar.replyButton:CreateFontString(nil, "OVERLAY")
    bar.replyButton.text:SetPoint("CENTER")
    bar.replyButton.text:SetFont(fontPath, math.max(fontSize - 2, 8), "OUTLINE")
    bar.replyButton.text:SetText("Reply")
    bar.replyButton.text:SetTextColor(1, 1, 1)
    bar.replyButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.3, 0.8, 0.3, 1)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Whisper " .. match.playerName)
        if addon.Config.db.profile.templates and #addon.Config.db.profile.templates > 0 then
            GameTooltip:AddLine("Right-click for templates", 0.5, 0.5, 1)
        end
        GameTooltip:Show()
    end)
    bar.replyButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.2, 0.6, 0.2, 0.8)
        GameTooltip:Hide()
    end)
    bar.replyButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    bar.replyButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            ChatFrame_SendTell(match.playerName)
        elseif button == "RightButton" then
            core:ShowTemplateMenu(match.playerName, self)
        end
    end)
    
    -- Invite button (top right)
    bar.inviteButton = CreateFrame("Button", nil, bar.buttonContainer)
    bar.inviteButton:SetSize(buttonWidth, buttonHeight)
    bar.inviteButton:SetPoint("TOPRIGHT", bar.buttonContainer, "TOPRIGHT", 0, 0)
    bar.inviteButton.bg = bar.inviteButton:CreateTexture(nil, "BACKGROUND")
    bar.inviteButton.bg:SetAllPoints()
    bar.inviteButton.bg:SetColorTexture(0.8, 0.6, 0.2, 0.8)
    bar.inviteButton.text = bar.inviteButton:CreateFontString(nil, "OVERLAY")
    bar.inviteButton.text:SetPoint("CENTER")
    bar.inviteButton.text:SetFont(fontPath, math.max(fontSize - 2, 8), "OUTLINE")
    bar.inviteButton.text:SetText("Invite")
    bar.inviteButton.text:SetTextColor(1, 1, 1)
    bar.inviteButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 0.8, 0.3, 1)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Invite to group")
        GameTooltip:Show()
    end)
    bar.inviteButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.8, 0.6, 0.2, 0.8)
        GameTooltip:Hide()
    end)
    bar.inviteButton:SetScript("OnClick", function()
        InviteUnit(match.playerName)
        print("|cff00ff00ChatScanner PRO:|r Invited " .. match.playerName)
    end)
    
    -- Copy button (bottom left)
    bar.copyButton = CreateFrame("Button", nil, bar.buttonContainer)
    bar.copyButton:SetSize(buttonWidth, buttonHeight)
    bar.copyButton:SetPoint("BOTTOMLEFT", bar.buttonContainer, "BOTTOMLEFT", 0, 0)
    bar.copyButton.bg = bar.copyButton:CreateTexture(nil, "BACKGROUND")
    bar.copyButton.bg:SetAllPoints()
    bar.copyButton.bg:SetColorTexture(0.4, 0.4, 0.8, 0.8)
    bar.copyButton.text = bar.copyButton:CreateFontString(nil, "OVERLAY")
    bar.copyButton.text:SetPoint("CENTER")
    bar.copyButton.text:SetFont(fontPath, math.max(fontSize - 2, 8), "OUTLINE")
    bar.copyButton.text:SetText("Copy")
    bar.copyButton.text:SetTextColor(1, 1, 1)
    bar.copyButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(0.5, 0.5, 1, 1)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Copy name")
        GameTooltip:Show()
    end)
    bar.copyButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.4, 0.4, 0.8, 0.8)
        GameTooltip:Hide()
    end)
    bar.copyButton:SetScript("OnClick", function()
        -- Create a popup dialog with the name to copy
        StaticPopupDialogs["CHATSCANNER_COPY_NAME"] = {
            text = "Copy this name (Ctrl+C):",
            button1 = "Close",
            hasEditBox = true,
            OnShow = function(self)
                self.editBox:SetText(match.playerName)
                self.editBox:HighlightText()
                self.editBox:SetFocus()
            end,
            OnAccept = function(self)
                -- Nothing to do, just close
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
        StaticPopup_Show("CHATSCANNER_COPY_NAME")
    end)
    
    -- Ignore button (bottom right)
    bar.ignoreButton = CreateFrame("Button", nil, bar.buttonContainer)
    bar.ignoreButton:SetSize(buttonWidth, buttonHeight)
    bar.ignoreButton:SetPoint("BOTTOMRIGHT", bar.buttonContainer, "BOTTOMRIGHT", 0, 0)
    bar.ignoreButton.bg = bar.ignoreButton:CreateTexture(nil, "BACKGROUND")
    bar.ignoreButton.bg:SetAllPoints()
    bar.ignoreButton.bg:SetColorTexture(0.8, 0.2, 0.2, 0.8)
    bar.ignoreButton.text = bar.ignoreButton:CreateFontString(nil, "OVERLAY")
    bar.ignoreButton.text:SetPoint("CENTER")
    bar.ignoreButton.text:SetFont(fontPath, math.max(fontSize - 2, 8), "OUTLINE")
    bar.ignoreButton.text:SetText("Ignore")
    bar.ignoreButton.text:SetTextColor(1, 1, 1)
    bar.ignoreButton:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 0.3, 0.3, 1)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("Ignore player")
        GameTooltip:Show()
    end)
    bar.ignoreButton:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(0.8, 0.2, 0.2, 0.8)
        GameTooltip:Hide()
    end)
    bar.ignoreButton:SetScript("OnClick", function()
        -- Show simple popup to choose ignore duration
        StaticPopupDialogs["CHATSCANNER_IGNORE_PLAYER"] = {
            text = "Ignore " .. match.playerName .. " for how long?",
            button1 = "1 Hour",
            button2 = "24 Hours",
            button3 = "Forever",
            OnAccept = function()
                if addon.core then
                    addon.core:AddToBlacklist(match.playerName, 3600, "Ignored from notification")
                end
            end,
            OnCancel = function()
                if addon.core then
                    addon.core:AddToBlacklist(match.playerName, 86400, "Ignored from notification")
                end
            end,
            OnAlt = function()
                if addon.core then
                    addon.core:AddToBlacklist(match.playerName, 0, "Ignored from notification")
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
        StaticPopup_Show("CHATSCANNER_IGNORE_PLAYER")
    end)
    
    -- Build enriched player text
    local playerText = match.playerName
    
    -- Add level if available
    if playerInfo.level and playerInfo.level > 0 then
        playerText = playerText .. " [" .. playerInfo.level .. "]"
    end
    
    -- Add guild if available
    if playerInfo.guild then
        playerText = playerText .. " <" .. playerInfo.guild .. ">"
    end
    
    -- Add text next to icon (with space for action buttons)
    bar.label = bar:CreateFontString(nil, "OVERLAY")
    bar.label:SetPoint("LEFT", bar.icon, "RIGHT", 8, 0)
    bar.label:SetPoint("RIGHT", bar.buttonContainer, "LEFT", -5, 0)
    -- Apply custom font from settings
    bar.label:SetFont(fontPath, fontSize, "OUTLINE")
    bar.label:SetText(playerText)
    
    -- Apply class color if available
    if playerInfo.classColor then
        bar.label:SetTextColor(playerInfo.classColor.r, playerInfo.classColor.g, playerInfo.classColor.b)
    else
        bar.label:SetTextColor(1, 1, 1)
    end
    
    bar.label:SetJustifyH("LEFT")
    
    -- Enable mouse interaction
    bar:EnableMouse(true)
    
    -- Add tooltip and pause on hover
    bar:SetScript("OnEnter", function(self)
        -- Pause on hover functionality
        if appearance.pauseOnHover then
            self.isPaused = true
            if self.hideTimer then
                self.hideTimer:Cancel()
            end
        end
        
        -- Show tooltip
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("|cffFFD700ChatScanner PRO|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine("Filter:", "|cffFFFFFF" .. match.filterName .. "|r")
        GameTooltip:AddDoubleLine("Player:", playerText)
        
        if playerInfo.class then
            GameTooltip:AddDoubleLine("Class:", "|cff" .. 
                string.format("%02x%02x%02x", 
                    playerInfo.classColor.r * 255, 
                    playerInfo.classColor.g * 255, 
                    playerInfo.classColor.b * 255) .. 
                playerInfo.class .. "|r")
        end
        
        GameTooltip:AddDoubleLine("Channel:", "|cffFF6B6B" .. match.channel .. "|r")
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Message:", 1, 1, 0)
        GameTooltip:AddLine(match.message, 1, 1, 1, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cff00FF00Click bar to whisper|r")
        if appearance.pauseOnHover then
            GameTooltip:AddLine("|cff888888(Timer paused while hovering)|r")
        end
        GameTooltip:Show()
    end)
    
    bar:SetScript("OnLeave", function(self)
        -- Resume timer if pause on hover is enabled
        if appearance.pauseOnHover then
            self.isPaused = false
            -- Restart timer
            self.hideTimer = C_Timer.After(self.duration or 10, function()
                if not self.isPaused then
                    self:Stop()
                end
            end)
        end
        
        GameTooltip:Hide()
    end)
    
    -- Add click handler
    bar:SetScript("OnMouseDown", function()
        ChatFrame_SendTell(match.playerName)
    end)
    
    -- Add methods to mimic LibCandyBar
    bar.SetLabel = function(self, text)
        self.label:SetText(text)
    end
    
    bar.SetDuration = function(self, duration)
        self.duration = duration
    end
    
    bar.SetColor = function(self, r, g, b)
        if self.SetBackdrop then
            self:SetBackdropColor(r, g, b, 0.5)
        end
    end
    
    bar.SetTextColor = function(self, r, g, b)
        self.label:SetTextColor(r, g, b)
    end
    
    bar.SetTimeVisibility = function(self, visible) end
    
    bar.SetIcon = function(self, icon)
        self.icon:SetTexture(icon)
    end
    
    bar.Start = function(self)
        self:Show()
        
        -- Fade-in animation
        local fadeInDuration = appearance.fadeInDuration or 0.3
        if fadeInDuration > 0 then
            local startTime = GetTime()
            local fadeInFrame = CreateFrame("Frame")
            fadeInFrame:SetScript("OnUpdate", function(frame)
                local elapsed = GetTime() - startTime
                local progress = math.min(elapsed / fadeInDuration, 1)
                self:SetAlpha(progress)
                
                if progress >= 1 then
                    frame:SetScript("OnUpdate", nil)
                end
            end)
        else
            self:SetAlpha(1)
        end
        
        -- Auto-hide after duration
        self.hideTimer = C_Timer.After(self.duration or 10, function()
            if not self.isPaused then
                self:Stop()
            end
        end)
    end
    
    bar.Stop = function(self)
        -- Fade-out animation
        local fadeOutDuration = appearance.fadeOutDuration or 0.5
        if fadeOutDuration > 0 then
            local startAlpha = self:GetAlpha()
            local startTime = GetTime()
            local fadeOutFrame = CreateFrame("Frame")
            fadeOutFrame:SetScript("OnUpdate", function(frame)
                local elapsed = GetTime() - startTime
                local progress = math.min(elapsed / fadeOutDuration, 1)
                self:SetAlpha(startAlpha * (1 - progress))
                
                if progress >= 1 then
                    frame:SetScript("OnUpdate", nil)
                    if self.onStopCallback then
                        self.onStopCallback()
                    end
                    self:Hide()
                end
            end)
        else
            if self.onStopCallback then
                self.onStopCallback()
            end
            self:Hide()
        end
    end
    
    bar.SetCallback = function(self, event, callback)
        if event == "OnStop" then
            self.onStopCallback = callback
        end
    end
    
    -- Set properties
    bar:SetLabel(match.playerName)
    
    -- Use custom duration from settings
    local duration = addon.Config.db.profile.settings.notificationDuration or 10
    bar:SetDuration(duration)
    
    bar:SetColor(filter.color.r, filter.color.g, filter.color.b)
    bar:SetTextColor(1, 1, 1)
    
    -- Les scripts sont déjà définis plus haut
    
    -- Get or create anchor
    local anchor = CreateAnchor()
    if not anchor then
        print("ChatScanner PRO: Error creating anchor")
        return
    end
    
    -- Start the bar
    bar:Start()
    
    -- Add to active bars
    table.insert(activeBars, bar)
    
    -- Remove oldest bar if we have too many (use setting)
    local maxBars = addon.Config.db.profile.settings.maxNotifications or 10
    if #activeBars > maxBars then
        local oldestBar = table.remove(activeBars, 1)
        oldestBar:Stop()
    end
    
    -- Reposition all bars
    RepositionBars()
    
    -- Set callback for when the bar stops
    bar:SetCallback("OnStop", function()
        for i, activeBar in ipairs(activeBars) do
            if activeBar == bar then
                table.remove(activeBars, i)
                -- Reposition remaining bars when one is removed
                RepositionBars()
                break
            end
        end
    end)
    
    return bar
end

-- Store a match
local function StoreMatch(playerName, message, filterName, matchedKeyword, channel)
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

-- Function to update chat event registrations
function core:UpdateChatEventRegistrations()
    -- Unregister all chat events first
    self:UnregisterEvent("CHAT_MSG_SAY")
    self:UnregisterEvent("CHAT_MSG_YELL")
    self:UnregisterEvent("CHAT_MSG_GUILD")
    self:UnregisterEvent("CHAT_MSG_PARTY")
    self:UnregisterEvent("CHAT_MSG_RAID")
    self:UnregisterEvent("CHAT_MSG_CHANNEL")
    self:UnregisterEvent("CHAT_MSG_WHISPER")
    
    -- Register only enabled channels
    if addon.Config and addon.Config.db and addon.Config.db.profile and addon.Config.db.profile.settings and addon.Config.db.profile.settings.chatChannels then
        local channels = addon.Config.db.profile.settings.chatChannels
        if channels.SAY then self:RegisterEvent("CHAT_MSG_SAY", ScanMessage) end
        if channels.YELL then self:RegisterEvent("CHAT_MSG_YELL", ScanMessage) end
        if channels.GUILD then self:RegisterEvent("CHAT_MSG_GUILD", ScanMessage) end
        if channels.PARTY then self:RegisterEvent("CHAT_MSG_PARTY", ScanMessage) end
        if channels.RAID then self:RegisterEvent("CHAT_MSG_RAID", ScanMessage) end
        if channels.CHANNEL then self:RegisterEvent("CHAT_MSG_CHANNEL", ScanMessage) end
        if channels.WHISPER then self:RegisterEvent("CHAT_MSG_WHISPER", ScanMessage) end
    end
end

-- Anti-spam cache: stores recent messages to detect duplicates
local recentMessages = {}
local SPAM_WINDOW = 5 -- seconds

-- Main chat scanning function
local function ScanMessage(event, message, sender, _, channelName, _, _, _, channelNumber, ...)
    -- Check if addon is enabled
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile or not addon.Config.db.profile.enabled then
        return
    end
    
    -- Check if we should pause during combat
    if addon.Config.db.profile.settings.pauseInCombat and InCombatLockdown() then
        return
    end
    
    -- Remove realm from sender name
    local playerName = sender and string.match(sender, "([^-]+)") or "Unknown"
    
    -- Skip own messages if option is enabled
    if addon.Config.db.profile.settings.ignoreOwnMessages and playerName == UnitName("player") then
        return
    end
    
    -- Skip blacklisted players
    if core:IsBlacklisted(playerName) then
        return
    end
    
    -- Anti-spam: Check if this is a duplicate message from the same player
    if addon.Config.db.profile.settings.antiSpam then
        local messageKey = playerName .. ":" .. message
        local currentTime = time()
        
        -- Clean old entries
        for key, timestamp in pairs(recentMessages) do
            if currentTime - timestamp > SPAM_WINDOW then
                recentMessages[key] = nil
            end
        end
        
        -- Check if this message was sent recently
        if recentMessages[messageKey] then
            -- Duplicate detected, skip
            return
        end
        
        -- Store this message
        recentMessages[messageKey] = currentTime
    end
    
    -- Determine channel type
    local channelType = event:gsub("CHAT_MSG_", "")
    
    -- Check if we should scan this channel
    if channelType == "CHANNEL" then
        if not addon.Config.db.profile.settings or not addon.Config.db.profile.settings.chatChannels or not addon.Config.db.profile.settings.chatChannels.CHANNEL then
            return
        end
        
        -- For CHANNEL events, check if this specific channel is enabled
        local channels = addon.Config.db.profile.settings.chatChannels
        if channels and channels.specificChannels then
            -- Check if this channel number is in the enabled list
            local channelEnabled = false
            for _, enabledNum in ipairs(channels.specificChannels) do
                if enabledNum == channelNumber then
                    channelEnabled = true
                    break
                end
            end
            if not channelEnabled then
                return
            end
        end
    end
    
    -- Check against all enabled filters
    local alreadyNotified = false
    for _, filter in ipairs(addon.Config.db.profile.filters or {}) do
        if filter.enabled and not alreadyNotified then
            local keywords = core.ParseKeywords(filter.keywords)
            local matches, matchedKeyword = core.MessageMatchesKeywords(message, keywords)
            
            if matches then
                alreadyNotified = true -- Prevent multiple notifications for same message
                local channelDisplay = channelType
                if channelType == "CHANNEL" and channelName then
                    channelDisplay = channelName
                end
                
                local match = StoreMatch(playerName, message, filter.name, matchedKeyword, channelDisplay)
                
                -- Update statistics
                if addon.Config and addon.Config.db and addon.Config.db.profile.statistics then
                    local stats = addon.Config.db.profile.statistics
                    if not stats.filterMatches[filter.name] then
                        stats.filterMatches[filter.name] = {today = 0, week = 0, total = 0}
                    end
                    stats.filterMatches[filter.name].today = (stats.filterMatches[filter.name].today or 0) + 1
                    stats.filterMatches[filter.name].week = (stats.filterMatches[filter.name].week or 0) + 1
                    stats.filterMatches[filter.name].total = (stats.filterMatches[filter.name].total or 0) + 1
                end
                
                -- Add to history if enabled
                if addon.Config and addon.Config.db and addon.Config.db.profile and addon.Config.db.profile.history then
                    if addon.Config.db.profile.history.enabled then
                        -- Ensure entries table exists
                        if not addon.Config.db.profile.history.entries then
                            addon.Config.db.profile.history.entries = {}
                        end
                        
                        local historyEntry = {
                            timestamp = time(),
                            playerName = playerName,
                            message = message,
                            filterName = filter.name,
                            channel = channelDisplay,
                            matchedKeyword = matchedKeyword
                        }
                        table.insert(addon.Config.db.profile.history.entries, 1, historyEntry) -- Insert at beginning
                        
                        -- Limit history size
                        local maxEntries = addon.Config.db.profile.history.maxEntries or 100
                        while #addon.Config.db.profile.history.entries > maxEntries do
                            table.remove(addon.Config.db.profile.history.entries)
                        end
                    end
                end
                
                -- Create notification bar using our custom implementation
                local bar = CreateBar(match)
                
                -- Make the bar interactive
                if bar and bar.EnableMouse then
                    bar:EnableMouse(true)
                end
                
                -- Play sound if enabled
                if addon.Config.db.profile.settings and addon.Config.db.profile.settings.soundEnabled then
                    local soundFile = "Sound\\Interface\\iTellMessage.ogg"
                    if LSM and LSM.Fetch then
                        soundFile = LSM:Fetch("sound", addon.Config.db.profile.appearance and addon.Config.db.profile.appearance.sound or "ChatScanner Ping")
                    end
                    PlaySoundFile(soundFile, "Master")
                end
                
                -- Only trigger once per message
                break
            end
        end
    end
end

-- Initialize addon
function core:OnInitialize()
    -- Create default settings if they don't exist
    if not addon.Config or not addon.Config.Initialize then
        addon.Config = addon.Config or {}
        addon.Config.db = {
            profile = {
                enabled = true,
                minimap = {
                    hide = false,
                },
                filters = {
                    -- Pas de filtres par défaut, l'utilisateur doit créer les siens
                },
                settings = {
                    chatChannels = {
                        SAY = false,
                        YELL = false,
                        GUILD = true,
                        PARTY = false,
                        RAID = false,
                        CHANNEL = true, -- Trade, General, etc.
                        WHISPER = false,
                    },
                    soundEnabled = true,
                    ignoreOwnMessages = true,
                    notificationDuration = 10,
                    maxNotifications = 10,
                    pauseInCombat = false,
                },
                appearance = {
                    barTexture = "ChatScanner Smooth",
                    font = "ChatScanner Expressway",
                    fontSize = 12,
                    barWidth = 200,
                    barHeight = 20,
                    barSpacing = 2,
                    barGrowDirection = "UP",
                    sound = "ChatScanner Ping",
                    barPosition = {
                        point = "CENTER",
                        relativePoint = "CENTER",
                        x = 0,
                        y = 0
                    }
                },
                autoFlood = {
                    enabled = false,
                    messages = {},
                    rate = 60,
                    currentIndex = 1,
                }
            }
        }
        
        addon.Config.Initialize = function() end
    else
        -- Initialize config
        addon.Config:Initialize()
    end
    
    -- Register chat events dynamically based on settings
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Unregister all chat events first
        self:UnregisterEvent("CHAT_MSG_SAY")
        self:UnregisterEvent("CHAT_MSG_YELL")
        self:UnregisterEvent("CHAT_MSG_GUILD")
        self:UnregisterEvent("CHAT_MSG_PARTY")
        self:UnregisterEvent("CHAT_MSG_RAID")
        self:UnregisterEvent("CHAT_MSG_CHANNEL")
        self:UnregisterEvent("CHAT_MSG_WHISPER")
        
        -- Register only enabled channels
        if addon.Config and addon.Config.db and addon.Config.db.profile and addon.Config.db.profile.settings and addon.Config.db.profile.settings.chatChannels then
            local channels = addon.Config.db.profile.settings.chatChannels
            if channels.SAY then self:RegisterEvent("CHAT_MSG_SAY", ScanMessage) end
            if channels.YELL then self:RegisterEvent("CHAT_MSG_YELL", ScanMessage) end
            if channels.GUILD then self:RegisterEvent("CHAT_MSG_GUILD", ScanMessage) end
            if channels.PARTY then self:RegisterEvent("CHAT_MSG_PARTY", ScanMessage) end
            if channels.RAID then self:RegisterEvent("CHAT_MSG_RAID", ScanMessage) end
            if channels.CHANNEL then self:RegisterEvent("CHAT_MSG_CHANNEL", ScanMessage) end
            if channels.WHISPER then self:RegisterEvent("CHAT_MSG_WHISPER", ScanMessage) end
        end
    end)
    
    -- Initial registration of chat events
    if addon.Config and addon.Config.db and addon.Config.db.profile and addon.Config.db.profile.settings and addon.Config.db.profile.settings.chatChannels then
        local channels = addon.Config.db.profile.settings.chatChannels
        if channels.SAY then self:RegisterEvent("CHAT_MSG_SAY", ScanMessage) end
        if channels.YELL then self:RegisterEvent("CHAT_MSG_YELL", ScanMessage) end
        if channels.GUILD then self:RegisterEvent("CHAT_MSG_GUILD", ScanMessage) end
        if channels.PARTY then self:RegisterEvent("CHAT_MSG_PARTY", ScanMessage) end
        if channels.RAID then self:RegisterEvent("CHAT_MSG_RAID", ScanMessage) end
        if channels.CHANNEL then self:RegisterEvent("CHAT_MSG_CHANNEL", ScanMessage) end
        if channels.WHISPER then self:RegisterEvent("CHAT_MSG_WHISPER", ScanMessage) end
    end
    
    -- Register slash command
    if self.RegisterChatCommand then
        self:RegisterChatCommand("cs", "SlashCommand")
        self:RegisterChatCommand("craftscan", "SlashCommand")
    end
    
    -- Initialize menu button
    if addon.MenuButton and addon.MenuButton.Initialize then
        addon.MenuButton:Initialize()
    end
    
    -- Print welcome message
    if self.Print then
        self:Print("|cffFFD700ChatScanner PRO|r v2.0.0 loaded. Type |cffffffff/cs|r to open options.")
    else
        print("|cffFFD700ChatScanner PRO|r v2.0.0 loaded. Type |cffffffff/cs|r to open options.")
    end
end

-- Test notification function
function core:TestNotification()
    -- Create a test match with the first enabled filter, or a default one
    local testFilter = nil
    for _, filter in ipairs(addon.Config.db.profile.filters or {}) do
        if filter.enabled then
            testFilter = filter
            break
        end
    end
    
    if not testFilter then
        print("ChatScanner PRO: No enabled filters found. Create and enable a filter first!")
        return
    end
    
    local testMatch = {
        playerName = "TestPlayer",
        message = "This is a test notification message!",
        filterName = testFilter.name,
        matchedKeyword = "test",
        channel = "Test",
        timestamp = time(),
    }
    
    CreateBar(testMatch)
    print("ChatScanner PRO: Test notification displayed!")
end

-- Expose toggle function
function core:ToggleBarsLock()
    ToggleBarsLock()
end

-- Test notification for a specific filter
function core:TestFilterNotification(filterName)
    local testMatch = {
        playerName = "TestPlayer",
        message = "This is a test notification for " .. filterName,
        filterName = filterName,
        matchedKeyword = "test",
        channel = "Test",
        timestamp = time(),
    }
    
    CreateBar(testMatch)
    print("ChatScanner PRO: Test notification displayed for filter: " .. filterName)
end

-- Slash command handler
function core:SlashCommand(input)
    local printFunc = self.Print and function(...) self:Print(...) end or print
    
    if not input or input:trim() == "" then
        -- Open options
        local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
        if AceConfigDialog and AceConfigDialog.Open then
            AceConfigDialog:Open(addonName)
        else
            printFunc("ChatScanner PRO: Options dialog not available. Use /cs help for commands.")
        end
    elseif input == "help" then
        printFunc("ChatScanner PRO Commands:")
        printFunc("  /cs - Open options")
        printFunc("  /cs help - Show this help")
        printFunc("  /cs test - Show a test notification")
        printFunc("  /cs unlock - Toggle lock/unlock bars position")
        printFunc("  /cs keywords - Show keyword syntax help")
        printFunc("  /cs enable - Enable addon")
        printFunc("  /cs disable - Disable addon")
    elseif input == "keywords" then
        printFunc("ChatScanner PRO Keyword Syntax:")
        printFunc("  Standard keywords: mot1, mot2, mot3")
        printFunc("    - Message matches if ANY keyword is present")
        printFunc("  Required keywords: +mot1+, +mot2+, mot3")
        printFunc("    - Keywords with + must ALL be present")
        printFunc("    - Other keywords work normally (any one is enough)")
        printFunc("  Keyword groups: &mot1 mot2&, mot3")
        printFunc("    - ALL words inside & must be present together")
        printFunc("    - Other keywords work normally")
        printFunc("  Examples:")
        printFunc("    - wts, vend - Matches if 'wts' OR 'vend' is present")
        printFunc("    - +wts+, +vend+ - Matches if 'wts' AND 'vend' are present")
        printFunc("    - &wts vend& - Matches if 'wts' AND 'vend' are present together")
    elseif input == "test" then
        self:TestNotification()
    elseif input == "unlock" then
        self:ToggleBarsLock()
    elseif input == "enable" then
        if addon.Config and addon.Config.db and addon.Config.db.profile then
            addon.Config.db.profile.enabled = true
            printFunc("ChatScanner PRO enabled")
        else
            printFunc("ChatScanner PRO: Config not initialized")
        end
    elseif input == "disable" then
        if addon.Config and addon.Config.db and addon.Config.db.profile then
            addon.Config.db.profile.enabled = false
            printFunc("ChatScanner PRO disabled")
        else
            printFunc("ChatScanner PRO: Config not initialized")
        end
    end
end
