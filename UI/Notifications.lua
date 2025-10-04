-- CraftScan Notifications
local addonName, addon = ...

-- Initialize notifications module
addon.Notifications = {}
local notifications = addon.Notifications

-- Libraries
local LSM = LibStub("LibSharedMedia-3.0")

-- Local variables
local activeNotifications = {}
local maxNotifications = 3
local notificationPool = {}

-- Create a notification frame
local function CreateNotificationFrame()
    local frame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(300, 80)
    frame:SetFrameStrata("HIGH")
    
    -- Add background
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
    end
    
    -- Add icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(32, 32)
    frame.icon:SetPoint("TOPLEFT", 15, -15)
    frame.icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    -- Add title
    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 10, 0)
    frame.title:SetPoint("RIGHT", frame, "RIGHT", -15, 0)
    frame.title:SetJustifyH("LEFT")
    
    -- Add message
    frame.message = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.message:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -5)
    frame.message:SetPoint("RIGHT", frame, "RIGHT", -15, 0)
    frame.message:SetJustifyH("LEFT")
    
    -- Add player name
    frame.player = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.player:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 15, 15)
    frame.player:SetJustifyH("LEFT")
    
    -- Add close button
    frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    frame.close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    frame.close:SetScript("OnClick", function()
        notifications:HideNotification(frame)
    end)
    
    -- Add whisper button
    frame.whisper = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.whisper:SetSize(80, 22)
    frame.whisper:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -15, 15)
    frame.whisper:SetText("Whisper")
    frame.whisper:SetScript("OnClick", function()
        if frame.playerName then
            ChatFrame_SendTell(frame.playerName)
        end
        notifications:HideNotification(frame)
    end)
    
    -- Make frame clickable
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function()
        if frame.playerName then
            ChatFrame_SendTell(frame.playerName)
        end
        notifications:HideNotification(frame)
    end)
    
    -- Hide by default
    frame:Hide()
    
    return frame
end

-- Get a notification frame from the pool
local function GetNotificationFrame()
    if #notificationPool > 0 then
        return table.remove(notificationPool)
    else
        return CreateNotificationFrame()
    end
end

-- Show a notification for a match
function notifications:ShowNotification(match)
    -- Check if visual alerts are enabled
    if not addon.Config.db.profile.settings.visualAlertEnabled then
        return
    end
    
    -- Find filter
    local filter
    for _, f in ipairs(addon.Config.db.profile.filters) do
        if f.name == match.filterName then
            filter = f
            break
        end
    end
    
    if not filter then return end
    
    -- Get a notification frame
    local frame = GetNotificationFrame()
    
    -- Set notification content
    frame.title:SetText(match.filterName)
    if filter.color then
        frame.title:SetTextColor(filter.color.r, filter.color.g, filter.color.b)
    end
    
    -- Truncate message if needed
    local message = match.message
    if #message > 100 then
        message = string.sub(message, 1, 97) .. "..."
    end
    frame.message:SetText(message)
    
    frame.player:SetText(match.playerName .. " (" .. match.channel .. ")")
    frame.playerName = match.playerName
    
    -- Position the notification
    local yOffset = 0
    for _, notification in ipairs(activeNotifications) do
        yOffset = yOffset + notification:GetHeight() + 10
    end
    
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, -50 - yOffset)
    
    -- Show the notification
    frame:Show()
    
    -- Add to active notifications
    table.insert(activeNotifications, frame)
    
    -- Remove oldest notification if we have too many
    if #activeNotifications > maxNotifications then
        self:HideNotification(activeNotifications[1])
    end
    
    -- Auto-hide after 5 seconds
    C_Timer.After(5, function()
        if frame:IsShown() then
            self:HideNotification(frame)
        end
    end)
    
    -- Add fade in animation
    frame:SetAlpha(0)
    frame.fadeIn = frame:CreateAnimationGroup()
    local fadeIn = frame.fadeIn:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    frame.fadeIn:Play()
    
    return frame
end

-- Hide a notification
function notifications:HideNotification(frame)
    -- Remove from active notifications
    for i, notification in ipairs(activeNotifications) do
        if notification == frame then
            table.remove(activeNotifications, i)
            break
        end
    end
    
    -- Add fade out animation
    frame.fadeOut = frame:CreateAnimationGroup()
    local fadeOut = frame.fadeOut:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    frame.fadeOut:SetScript("OnFinished", function()
        frame:Hide()
        frame:SetAlpha(1)
        table.insert(notificationPool, frame)
        
        -- Update positions of remaining notifications
        self:UpdateNotificationPositions()
    end)
    frame.fadeOut:Play()
end

-- Update positions of all notifications
function notifications:UpdateNotificationPositions()
    local yOffset = 0
    for _, notification in ipairs(activeNotifications) do
        notification:ClearAllPoints()
        notification:SetPoint("TOP", UIParent, "TOP", 0, -50 - yOffset)
        yOffset = yOffset + notification:GetHeight() + 10
    end
end

-- Hide all notifications
function notifications:HideAllNotifications()
    for i = #activeNotifications, 1, -1 do
        self:HideNotification(activeNotifications[i])
    end
end
