-- RskChatScanner Bars
local addonName, addon = ...

-- Initialize bars module
addon.Bars = {}
local bars = addon.Bars

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

-- Local variables
-- Use shared activeBars from Core.lua
addon.activeBars = addon.activeBars or {}
local activeBars = addon.activeBars
local maxBars = 10
local barAnchor

-- Create bar anchor
function bars:CreateAnchor()
    if barAnchor then return barAnchor end
    
    local appearance = addon.Config.db.profile.appearance
    
    -- Create anchor frame
    barAnchor = CreateFrame("Frame", "CraftScanBarAnchor", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    barAnchor:SetSize(appearance.barWidth, appearance.barHeight)
    barAnchor:SetPoint(appearance.barPosition.point, 
                     UIParent, 
                     appearance.barPosition.relativePoint, 
                     appearance.barPosition.x, 
                     appearance.barPosition.y)
    
    -- Make anchor movable
    barAnchor:SetMovable(true)
    barAnchor:EnableMouse(true)
    barAnchor:RegisterForDrag("LeftButton")
    barAnchor:SetScript("OnDragStart", function(self) self:StartMoving() end)
    barAnchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        appearance.barPosition.point = point
        appearance.barPosition.relativePoint = relativePoint
        appearance.barPosition.x = x
        appearance.barPosition.y = y
    end)
    
    -- Add background when moving
    if barAnchor.SetBackdrop then
        barAnchor:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        barAnchor:SetBackdropColor(0, 0, 0, 0.5)
    end
    
    -- Add label
    barAnchor.label = barAnchor:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    barAnchor.label:SetPoint("CENTER")
    barAnchor.label:SetText("CraftScan Anchor")
    barAnchor.label:Hide()
    
    -- Show label when moving
    barAnchor:SetScript("OnDragStart", function(self)
        self:StartMoving()
        self.label:Show()
        if self.SetBackdrop then
            self:SetBackdropColor(0, 0, 0, 0.8)
        end
    end)
    
    barAnchor:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.label:Hide()
        if self.SetBackdrop then
            self:SetBackdropColor(0, 0, 0, 0)
        end
        local point, _, relativePoint, x, y = self:GetPoint()
        appearance.barPosition.point = point
        appearance.barPosition.relativePoint = relativePoint
        appearance.barPosition.x = x
        appearance.barPosition.y = y
    end)
    
    -- Hide by default
    barAnchor:Hide()
    
    return barAnchor
end

-- Create a bar for a match
function bars:CreateBar(match)
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
    
    -- Create a simple frame instead of using LibCandyBar
    local bar = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    bar:SetSize(appearance.barWidth, appearance.barHeight)
    
    -- Add background
    if bar.SetBackdrop then
        bar:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        bar:SetBackdropColor(filter.color.r, filter.color.g, filter.color.b, 0.5)
    end
    
    -- Add text
    bar.label = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bar.label:SetPoint("LEFT", bar, "LEFT", 10, 0)
    bar.label:SetText(match.playerName)
    bar.label:SetTextColor(1, 1, 1)
    
    -- Add icon
    bar.icon = bar:CreateTexture(nil, "ARTWORK")
    bar.icon:SetSize(appearance.barHeight - 4, appearance.barHeight - 4)
    bar.icon:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    bar.icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    -- Enable mouse interaction
    bar:EnableMouse(true)
    
    -- Add tooltip
    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:AddLine("CraftScan: " .. match.filterName)
        GameTooltip:AddLine(match.playerName .. " (" .. match.channel .. ")")
        GameTooltip:AddLine(match.message, 1, 1, 1, true)
        GameTooltip:AddLine("Click to whisper", 0, 1, 0)
        GameTooltip:Show()
    end)
    
    bar:SetScript("OnLeave", function()
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
        -- Auto-hide after duration
        C_Timer.After(self.duration or 10, function()
            self:Stop()
        end)
    end
    
    bar.Stop = function(self)
        if self.onStopCallback then
            self.onStopCallback()
        end
        self:Hide()
    end
    
    bar.SetCallback = function(self, event, callback)
        if event == "OnStop" then
            self.onStopCallback = callback
        end
    end
    
    -- Set properties
    bar:SetLabel(match.playerName)
    bar:SetDuration(10) -- 10 seconds duration
    bar:SetColor(filter.color.r, filter.color.g, filter.color.b)
    bar:SetTextColor(1, 1, 1)
    
    -- Create anchor if it doesn't exist
    if not barAnchor then
        barAnchor = self:CreateAnchor()
        barAnchor:Show()
    end
    
    -- Position based on grow direction
    local offset = #activeBars * (appearance.barHeight + appearance.barSpacing)
    if appearance.barGrowDirection == "UP" then
        bar:SetPoint("BOTTOMLEFT", barAnchor, "TOPLEFT", 0, offset)
    else
        bar:SetPoint("TOPLEFT", barAnchor, "BOTTOMLEFT", 0, -offset)
    end
    
    -- Start the bar
    bar:Start()
    
    -- Add to active bars
    table.insert(activeBars, bar)
    
    -- Remove oldest bar if we have too many
    if #activeBars > maxBars then
        local oldestBar = table.remove(activeBars, 1)
        oldestBar:Stop()
    end
    
    -- Set callback for when the bar stops
    bar:SetCallback("OnStop", function()
        for i, activeBar in ipairs(activeBars) do
            if activeBar == bar then
                table.remove(activeBars, i)
                break
            end
        end
        
        -- Hide anchor if no bars are active
        if #activeBars == 0 and barAnchor then
            barAnchor:Hide()
        end
    end)
    
    return bar
end

-- Update bar positions
function bars:UpdateBarPositions()
    local appearance = addon.Config.db.profile.appearance
    
    for i, bar in ipairs(activeBars) do
        local offset = (i - 1) * (appearance.barHeight + appearance.barSpacing)
        if appearance.barGrowDirection == "UP" then
            bar:SetPoint("BOTTOMLEFT", barAnchor, "TOPLEFT", 0, offset)
        else
            bar:SetPoint("TOPLEFT", barAnchor, "BOTTOMLEFT", 0, -offset)
        end
    end
end

-- Stop all bars
function bars:StopAllBars()
    for i = #activeBars, 1, -1 do
        activeBars[i]:Stop()
    end
    wipe(activeBars)
    
    if barAnchor then
        barAnchor:Hide()
    end
end

-- Close all bars from a specific player
function bars:ClosePlayerBars(playerName)
    if not playerName then return end
    
    local removed = 0
    for i = #activeBars, 1, -1 do
        local bar = activeBars[i]
        if bar and bar.match and bar.match.playerName == playerName then
            bar:Stop()
            removed = removed + 1
        end
    end
    
    if removed > 0 then
        print("|cff00ff00ChatScanner PRO:|r Closed " .. removed .. " notification(s) from " .. playerName)
    end
end
