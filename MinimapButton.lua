-- ChatScanner PRO - Minimap Button
local addonName, addon = ...

-- Initialize Minimap Button module
addon.MinimapButton = {}
local minimapButton = addon.MinimapButton

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

-- Create LDB object
local dataObj = LDB:NewDataObject("ChatScannerPRO", {
    type = "data source",
    text = "ChatScanner PRO",
    icon = "Interface\\Icons\\INV_Misc_Note_01",
    OnClick = function(self, button)
        if button == "LeftButton" then
            -- Toggle addon on/off
            if addon.Config and addon.Config.db and addon.Config.db.profile then
                addon.Config.db.profile.enabled = not addon.Config.db.profile.enabled
                local status = addon.Config.db.profile.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"
                print("|cff00ff00ChatScanner PRO:|r " .. status)
            end
        elseif button == "RightButton" then
            -- Show menu
            minimapButton:ShowMenu(self)
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        
        tooltip:AddLine("|cffFFD700ChatScanner PRO|r")
        tooltip:AddLine(" ")
        
        -- Status
        if addon.Config and addon.Config.db and addon.Config.db.profile then
            local enabled = addon.Config.db.profile.enabled
            local status = enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"
            tooltip:AddDoubleLine("Status:", status)
            
            -- Active filters count
            local activeFilters = 0
            for _, filter in ipairs(addon.Config.db.profile.filters or {}) do
                if filter.enabled then
                    activeFilters = activeFilters + 1
                end
            end
            tooltip:AddDoubleLine("Active Filters:", "|cff00FFFF" .. activeFilters .. "|r")
            
            -- AutoFlood status
            if addon.AutoFlood and addon.AutoFlood.IsActive then
                local autoFloodStatus = addon.AutoFlood:IsActive() and "|cff00ff00Running|r" or "|cff888888Stopped|r"
                tooltip:AddDoubleLine("AutoFlood:", autoFloodStatus)
            end
            
            -- Last notification
            if addon.Config.db.profile.history and addon.Config.db.profile.history.entries and #addon.Config.db.profile.history.entries > 0 then
                local lastEntry = addon.Config.db.profile.history.entries[1]
                local timeAgo = time() - lastEntry.timestamp
                local timeStr = ""
                if timeAgo < 60 then
                    timeStr = timeAgo .. "s ago"
                elseif timeAgo < 3600 then
                    timeStr = math.floor(timeAgo / 60) .. "m ago"
                else
                    timeStr = math.floor(timeAgo / 3600) .. "h ago"
                end
                tooltip:AddDoubleLine("Last Match:", "|cffFFFFFF" .. timeStr .. "|r")
            end
        end
        
        tooltip:AddLine(" ")
        tooltip:AddLine("|cffFFFF00Left-Click:|r Toggle On/Off")
        tooltip:AddLine("|cffFFFF00Right-Click:|r Quick Menu")
        tooltip:AddLine("|cffFFFF00Shift+Click:|r Open Options")
    end
})

-- Show context menu
function minimapButton:ShowMenu(frame)
    if not addon.Config or not addon.Config.db or not addon.Config.db.profile then
        return
    end
    
    local menu = {}
    
    -- Enable/Disable
    table.insert(menu, {
        text = addon.Config.db.profile.enabled and "Disable Scanner" or "Enable Scanner",
        notCheckable = true,
        func = function()
            addon.Config.db.profile.enabled = not addon.Config.db.profile.enabled
            local status = addon.Config.db.profile.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"
            print("|cff00ff00ChatScanner PRO:|r " .. status)
        end
    })
    
    -- AutoFlood toggle
    if addon.AutoFlood then
        table.insert(menu, {
            text = addon.AutoFlood:IsActive() and "Stop AutoFlood" or "Start AutoFlood",
            notCheckable = true,
            func = function()
                if addon.AutoFlood.Toggle then
                    addon.AutoFlood:Toggle()
                end
            end
        })
    end
    
    -- Separator
    table.insert(menu, {
        text = "",
        isTitle = true,
        notCheckable = true
    })
    
    -- Test notification
    table.insert(menu, {
        text = "Test Notification",
        notCheckable = true,
        func = function()
            if addon.core and addon.core.TestNotification then
                addon.core:TestNotification()
            end
        end
    })
    
    -- Clear history
    table.insert(menu, {
        text = "Clear History",
        notCheckable = true,
        func = function()
            if addon.Config.db.profile.history then
                addon.Config.db.profile.history.entries = {}
                print("|cff00ff00ChatScanner PRO:|r History cleared")
            end
        end
    })
    
    -- Separator
    table.insert(menu, {
        text = "",
        isTitle = true,
        notCheckable = true
    })
    
    -- Open options
    table.insert(menu, {
        text = "Open Options",
        notCheckable = true,
        func = function()
            local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
            if AceConfigDialog then
                AceConfigDialog:Open("ChatScanner")
            end
        end
    })
    
    -- Show menu using EasyMenu alternative
    local menuFrame = CreateFrame("Frame", "ChatScannerMinimapMenu", UIParent, "UIDropDownMenuTemplate")
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU", 2)
end

-- Initialize minimap button
function minimapButton:Initialize()
    if not LDBIcon then
        print("|cffFF0000ChatScanner PRO:|r LibDBIcon not found, minimap button disabled")
        return
    end
    
    -- Register with LibDBIcon
    LDBIcon:Register("ChatScannerPRO", dataObj, addon.Config.db.profile.minimap)
    
    -- Handle shift+click to open options
    local originalOnClick = dataObj.OnClick
    dataObj.OnClick = function(self, button)
        if IsShiftKeyDown() then
            local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
            if AceConfigDialog then
                AceConfigDialog:Open(addonName)
            end
        else
            originalOnClick(self, button)
        end
    end
end

-- Show/Hide minimap button
function minimapButton:Toggle()
    if LDBIcon then
        if addon.Config.db.profile.minimap.hide then
            LDBIcon:Show("ChatScannerPRO")
        else
            LDBIcon:Hide("ChatScannerPRO")
        end
        addon.Config.db.profile.minimap.hide = not addon.Config.db.profile.minimap.hide
    end
end
