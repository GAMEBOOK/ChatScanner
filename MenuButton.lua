-- SuperRsk ChatScanner Menu Button
local addonName, addon = ...

-- Initialize menu button module
addon.MenuButton = {}
local menuButton = addon.MenuButton

local menuFrame = nil

-- Create portable menu modal
function menuButton:CreateMenu()
    if menuFrame then
        return menuFrame
    end
    
    -- Create main frame
    local frame = CreateFrame("Frame", "ChatScannerMenuModal", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    frame:SetSize(220, 280)
    
    -- Restore saved position or use default
    local db = addon.Config and addon.Config.db
    if db and db.profile.menuButton and db.profile.menuButton.point then
        local pos = db.profile.menuButton
        frame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOffset, pos.yOffset)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(true)
    
    -- Backdrop
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
    end
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetSize(220, 30)
    titleBar:SetPoint("TOP", frame, "TOP", 0, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() 
        frame:StopMovingOrSizing()
        menuButton:SavePosition()
    end)
    
    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", titleBar, "CENTER", 0, -5)
    title:SetText("|cffFFD700ChatScanner PRO|r")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    closeBtn:EnableMouse(true)
    closeBtn:SetScript("OnClick", function() 
        frame:Hide()
        menuButton:SavePosition()
    end)
    
    -- Content area
    local yOffset = -40
    
    -- Status text
    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    statusText:SetPoint("TOP", frame, "TOP", 0, yOffset)
    statusText:SetText("Quick Controls")
    yOffset = yOffset - 25
    
    -- Enable/Disable Scanner button
    local toggleBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    toggleBtn:SetSize(180, 30)
    toggleBtn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    toggleBtn:SetScript("OnClick", function(self)
        if addon.Config and addon.Config.db then
            addon.Config.db.profile.enabled = not addon.Config.db.profile.enabled
            local status = addon.Config.db.profile.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"
            print("|cffFFD700ChatScanner PRO:|r Scanner " .. status)
            menuButton:UpdateButtons()
        end
    end)
    frame.toggleBtn = toggleBtn
    yOffset = yOffset - 35
    
    -- Sound toggle
    local soundBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    soundBtn:SetSize(180, 30)
    soundBtn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    soundBtn:SetScript("OnClick", function(self)
        if addon.Config and addon.Config.db then
            addon.Config.db.profile.settings.soundEnabled = not addon.Config.db.profile.settings.soundEnabled
            local status = addon.Config.db.profile.settings.soundEnabled and "|cff00ff00On|r" or "|cffFF0000Off|r"
            print("|cffFFD700ChatScanner PRO:|r Sound " .. status)
            menuButton:UpdateButtons()
        end
    end)
    frame.soundBtn = soundBtn
    yOffset = yOffset - 35
    
    -- Auto Messages toggle
    local autoBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    autoBtn:SetSize(180, 30)
    autoBtn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    autoBtn:SetScript("OnClick", function(self)
        if addon.AutoFlood then
            if addon.AutoFlood:IsRunning() then
                addon.AutoFlood:Stop()
                print("|cffFFD700ChatScanner PRO:|r Auto Messages |cffFF0000Stopped|r")
            else
                addon.AutoFlood:Start()
                print("|cffFFD700ChatScanner PRO:|r Auto Messages |cff00ff00Started|r")
            end
            menuButton:UpdateButtons()
        end
    end)
    frame.autoBtn = autoBtn
    yOffset = yOffset - 35
    
    -- Test Notification button
    local testBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    testBtn:SetSize(180, 30)
    testBtn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    testBtn:SetText("Test Notification")
    testBtn:SetScript("OnClick", function()
        if addon.core and addon.core.TestNotification then
            addon.core:TestNotification()
        end
    end)
    yOffset = yOffset - 35
    
    -- Open Settings button
    local settingsBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    settingsBtn:SetSize(180, 30)
    settingsBtn:SetPoint("TOP", frame, "TOP", 0, yOffset)
    settingsBtn:SetText("|cff00BFFFOpen Full Settings|r")
    settingsBtn:SetScript("OnClick", function()
        if LibStub and LibStub("AceConfigDialog-3.0", true) then
            LibStub("AceConfigDialog-3.0"):Open("ChatScanner")
            frame:Hide()
        end
    end)
    
    frame:Hide()
    menuFrame = frame
    
    return frame
end

-- Update button texts based on current state
function menuButton:UpdateButtons()
    if not menuFrame then return end
    
    if addon.Config and addon.Config.db then
        -- Toggle scanner button
        local enabled = addon.Config.db.profile.enabled
        menuFrame.toggleBtn:SetText(enabled and "|cff00ff00Scanner: ON|r" or "|cffFF0000Scanner: OFF|r")
        
        -- Sound button
        local soundEnabled = addon.Config.db.profile.settings.soundEnabled
        menuFrame.soundBtn:SetText(soundEnabled and "|cff00ff00Sound: ON|r" or "|cffFF0000Sound: OFF|r")
        
        -- Auto messages button
        if addon.AutoFlood then
            local autoRunning = addon.AutoFlood:IsRunning()
            menuFrame.autoBtn:SetText(autoRunning and "|cff00ff00Auto Msg: ON|r" or "|cffFF0000Auto Msg: OFF|r")
        end
    end
end

-- Create menu button
function menuButton:Create()
    -- Create button frame
    local button = CreateFrame("Button", "SuperRskChatScannerMenuButton", UIParent, "UIPanelButtonTemplate")
    button:SetSize(140, 30)
    button:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    button:SetText("ChatScanner Menu")
    
    -- Make button movable
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self) self:StartMoving() end)
    button:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    
    -- Add click handler
    button:SetScript("OnClick", function()
        local menu = menuButton:CreateMenu()
        if menu:IsShown() then
            menu:Hide()
        else
            menuButton:UpdateButtons()
            menu:Show()
        end
    end)
    
    -- Add tooltip
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine("SuperRsk ChatScanner PRO")
        GameTooltip:AddLine("Left-click to open quick menu", 1, 1, 1)
        GameTooltip:AddLine("Drag to move this button", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    -- Store button
    self.button = button
    
    return button
end

-- Toggle visibility
function menuButton:Toggle()
    if self.button then
        if self.button:IsShown() then
            self.button:Hide()
        else
            self.button:Show()
        end
    end
end

-- Save menu position
function menuButton:SavePosition()
    if not menuFrame then return end
    
    local db = addon.Config and addon.Config.db
    if not db then return end
    
    -- Initialize menuButton table if it doesn't exist
    if not db.profile.menuButton then
        db.profile.menuButton = {}
    end
    
    -- Get current position
    local point, relativeTo, relativePoint, xOffset, yOffset = menuFrame:GetPoint()
    
    -- Save position
    db.profile.menuButton.point = point
    db.profile.menuButton.relativePoint = relativePoint
    db.profile.menuButton.xOffset = xOffset
    db.profile.menuButton.yOffset = yOffset
end

-- Initialize
function menuButton:Initialize()
    self:Create()
    
    -- Check if button should be hidden
    if addon.Config and addon.Config.db and addon.Config.db.profile.settings then
        if addon.Config.db.profile.settings.hideMenuButton then
            self.button:Hide()
        end
    end
end
