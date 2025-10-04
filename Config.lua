-- RskChatScanner Config
local addonName, addon = ...
local L = addon.L or {}

-- Initialize config
addon.Config = {}
local config = addon.Config

-- Libraries (with fallbacks for missing libraries)
local AceConfig = LibStub("AceConfig-3.0", true) or {}
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true) or {}
local AceDB = LibStub("AceDB-3.0", true) or {}
local LSM = LibStub("LibSharedMedia-3.0", true) or {}
local LDB = LibStub("LibDataBroker-1.1", true) or {}
local LDBIcon = LibStub("LibDBIcon-1.0", true) or {}

-- Add fallback methods if libraries are missing
if not AceConfig.RegisterOptionsTable then
    AceConfig.RegisterOptionsTable = function() end
end

if not AceConfigDialog.AddToBlizOptions then
    AceConfigDialog.AddToBlizOptions = function() return {} end
end

if not AceConfigDialog.Open then
    AceConfigDialog.Open = function() end
end

if not AceConfigDialog.Close then
    AceConfigDialog.Close = function() end
end

if not AceDB.New then
    AceDB.New = function() return {profile = {}} end
end

if not LDB.NewDataObject then
    LDB.NewDataObject = function() return {} end
end

if not LDBIcon.Register then
    LDBIcon.Register = function() end
end

if not LDBIcon.Show then
    LDBIcon.Show = function() end
end

if not LDBIcon.Hide then
    LDBIcon.Hide = function() end
end

-- Default settings
local defaults = {
    profile = {
        enabled = true,
        minimap = {
            hide = false,
        },
        filters = {
            -- Pas de filtres par défaut, l'utilisateur doit créer les siens
        },
        settings = {
            soundEnabled = true,
            visualAlertEnabled = true,
            ignoreOwnMessages = true, -- Ignore player's own messages by default
            antiSpam = true, -- Detect duplicate messages within 5 seconds
            notificationDuration = 10, -- Duration in seconds
            maxNotifications = 50, -- Maximum number of bars shown at once
            pauseInCombat = false, -- Pause scanning during combat
            chatChannels = {
                SAY = false,
                YELL = false,
                GUILD = true,
                PARTY = false,
                RAID = false,
                CHANNEL = true, -- Trade, General, etc.
                WHISPER = false,
            }
        },
        appearance = {
            barTexture = addon.Media.DefaultBarTexture,
            font = addon.Media.DefaultFont,
            fontSize = 12,
            sound = addon.Media.DefaultSound,
            barWidth = 200,
            barHeight = 20,
            barSpacing = 2,
            barGrowDirection = "UP", -- UP, DOWN
            barOpacity = 0.9, -- 0.0 to 1.0
            fadeInDuration = 0.3, -- seconds
            fadeOutDuration = 0.5, -- seconds
            pauseOnHover = true, -- Pause fade-out when mouse is over the bar
            barPosition = {
                x = 0,
                y = 0,
                point = "CENTER",
                relativePoint = "CENTER"
            }
        },
        autoFlood = {
            enabled = false,
            messages = {
                -- Default empty, user will add messages
            },
            rate = 60, -- seconds between messages (minimum 10)
            currentIndex = 1, -- Current message index for rotation
        },
        history = {
            enabled = true,
            maxEntries = 100, -- Maximum number of history entries
            entries = {} -- Will store: {timestamp, playerName, message, filterName, channel}
        },
        templates = {
            -- Default empty, user will add templates
        },
        blacklist = {
            players = {} -- Will store: {name, reason, timestamp, duration}
        },
        statistics = {
            enabled = true,
            filterMatches = {}, -- {filterName = {today = 0, week = 0, total = 0}}
            lastReset = time(),
            lastWeekReset = time()
        }
    }
}

-- Initialize database
function config:InitDB()
    self.db = AceDB:New("ChatScannerPRO_DB", defaults)
    return self.db
end

-- Create options table
function config:GetOptions()
    local options = {
        name = "ChatScanner PRO",
        type = "group",
        args = {
            general = {
                name = L["Settings"] or "Settings",
                type = "group",
                order = 1,
                args = {
                    enabled = {
                        name = L["Enable"] or "Enable",
                        desc = L["Enable or disable the addon"] or "Enable or disable the addon",
                        type = "toggle",
                        width = "full",
                        order = 1,
                        get = function() return self.db.profile.enabled end,
                        set = function(_, value) self.db.profile.enabled = value end
                    },
                    minimap = {
                        name = L["Minimap Icon"] or "Minimap Icon",
                        desc = L["Show or hide the minimap icon"] or "Show or hide the minimap icon",
                        type = "toggle",
                        order = 2,
                        get = function() return not self.db.profile.minimap.hide end,
                        set = function(_, value) 
                            self.db.profile.minimap.hide = not value
                            if value then
                                LDBIcon:Show(addonName)
                            else
                                LDBIcon:Hide(addonName)
                            end
                        end
                    },
                    soundEnabled = {
                        name = L["Enable Sounds"] or "Enable Sounds",
                        desc = L["Play sounds when matches are found"] or "Play sounds when matches are found",
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.settings.soundEnabled end,
                        set = function(_, value) self.db.profile.settings.soundEnabled = value end
                    },
                    visualAlertEnabled = {
                        name = L["Enable Visual Alerts"] or "Enable Visual Alerts",
                        desc = L["Show visual alerts when matches are found"] or "Show visual alerts when matches are found",
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.settings.visualAlertEnabled end,
                        set = function(_, value) self.db.profile.settings.visualAlertEnabled = value end
                    },
                    ignoreOwnMessages = {
                        name = L["Ignore Own Messages"] or "Ignore Own Messages",
                        desc = L["Don't trigger notifications for your own messages"] or "Don't trigger notifications for your own messages (recommended to avoid spam)",
                        type = "toggle",
                        order = 5,
                        get = function() return self.db.profile.settings.ignoreOwnMessages end,
                        set = function(_, value) self.db.profile.settings.ignoreOwnMessages = value end
                    },
                    antiSpam = {
                        name = L["Anti-Spam"] or "Anti-Spam Filter",
                        desc = L["Prevent duplicate notifications"] or "Ignore duplicate messages from the same player within 5 seconds (prevents spam across multiple channels)",
                        type = "toggle",
                        order = 5.5,
                        get = function() return self.db.profile.settings.antiSpam end,
                        set = function(_, value) self.db.profile.settings.antiSpam = value end
                    },
                    notificationDuration = {
                        name = L["Notification Duration"] or "Notification Duration",
                        desc = L["How long notifications stay on screen (seconds)"] or "How long notifications stay on screen (in seconds). Set to 120 for permanent until clicked.",
                        type = "range",
                        min = 3,
                        max = 120,
                        step = 1,
                        order = 6,
                        get = function() return self.db.profile.settings.notificationDuration end,
                        set = function(_, value) self.db.profile.settings.notificationDuration = value end
                    },
                    maxNotifications = {
                        name = L["Max Notifications"] or "Max Notifications",
                        desc = L["Maximum number of notification bars shown at once"] or "Maximum number of notification bars shown at once (they will stack vertically)",
                        type = "range",
                        min = 1,
                        max = 100,
                        step = 1,
                        order = 7,
                        get = function() return self.db.profile.settings.maxNotifications end,
                        set = function(_, value) self.db.profile.settings.maxNotifications = value end
                    },
                    pauseInCombat = {
                        name = L["Pause in Combat"] or "Pause in Combat",
                        desc = L["Pause scanning during combat"] or "Pause scanning during combat to avoid distractions",
                        type = "toggle",
                        order = 8,
                        get = function() return self.db.profile.settings.pauseInCombat end,
                        set = function(_, value) self.db.profile.settings.pauseInCombat = value end
                    },
                    showMinimap = {
                        name = L["Show Minimap Button"] or "Show Minimap Button",
                        desc = L["Show or hide the minimap button"] or "Show or hide the minimap button",
                        type = "toggle",
                        order = 9,
                        get = function() return not self.db.profile.minimap.hide end,
                        set = function(_, value) 
                            self.db.profile.minimap.hide = not value
                            if addon.MinimapButton then
                                addon.MinimapButton:Toggle()
                            end
                        end
                    },
                    hideMenuButton = {
                        name = L["Hide Menu Button"] or "Hide Menu Button",
                        desc = L["Hide the center screen menu button"] or "Hide the menu button in the center of the screen (use /cs or minimap button instead)",
                        type = "toggle",
                        order = 10,
                        get = function() return self.db.profile.settings.hideMenuButton end,
                        set = function(_, value) 
                            self.db.profile.settings.hideMenuButton = value
                            if addon.MenuButton then
                                addon.MenuButton:Toggle()
                            end
                        end
                    }
                }
            },
            filters = {
                name = L["Keyword Filters"] or "Keyword Filters",
                type = "group",
                order = 2,
                args = {
                    collapseAll = {
                        name = L["Collapse All"] or "Collapse All",
                        desc = L["Collapse all filters"] or "Collapse all filters to see them at a glance",
                        type = "execute",
                        order = 0.5,
                        width = "normal",
                        func = function()
                            for _, filter in ipairs(self.db.profile.filters) do
                                filter.collapsed = true
                            end
                            self:UpdateFilterOptions()
                        end
                    },
                    newFilter = {
                        name = L["Add New Filter"] or "|cff00FF00+ Add New Filter|r",
                        desc = L["Add a new filter"] or "Add a new filter",
                        type = "execute",
                        order = 1,
                        width = "full",
                        func = function()
                            -- Check if there's already an unconfigured filter
                            for _, f in ipairs(self.db.profile.filters) do
                                if f.keywords == "" and not f.enabled then
                                    print("|cffFF6B6BChatScanner PRO:|r You already have an unconfigured filter. Please configure it first!")
                                    return
                                end
                            end
                            
                            -- Find next available number for filter name
                            local filterNum = 1
                            local nameExists = true
                            while nameExists do
                                nameExists = false
                                for _, f in ipairs(self.db.profile.filters) do
                                    if f.name == "New Filter #" .. filterNum then
                                        nameExists = true
                                        filterNum = filterNum + 1
                                        break
                                    end
                                end
                            end
                            
                            -- Collapse all existing filters first
                            for _, f in ipairs(self.db.profile.filters) do
                                f.collapsed = true
                            end
                            
                            -- Add new filter (expanded by default, but DISABLED until configured)
                            table.insert(self.db.profile.filters, {
                                name = "New Filter #" .. filterNum,
                                keywords = "",
                                enabled = false,  -- Disabled by default until user configures it
                                category = "General",
                                color = {r = 1, g = 1, b = 1},
                                icon = "Interface\\Icons\\INV_Misc_Note_01", -- Default icon
                                collapsed = false
                            })
                            self:UpdateFilterOptions()
                            print("|cffFFD700ChatScanner PRO:|r New filter created. Configure it and enable it when ready!")
                        end
                    },
                    filterList = {
                        name = L["Filters"] or "Filters",
                        type = "group",
                        inline = true,
                        order = 2,
                        args = {} -- Will be populated dynamically
                    }
                }
            },
            channels = {
                name = L["Channels"] or "Channels",
                type = "group",
                order = 3,
                args = {
                    description = {
                        name = "Enable the chat channels you want to monitor. For numbered channels (Trade, General, etc.), they will appear below after you join them.",
                        type = "description",
                        order = 0.5,
                        width = "full",
                        fontSize = "medium"
                    },
                    say = {
                        name = L["Say"] or "Say",
                        desc = L["Scan Say channel"] or "Scan Say channel",
                        type = "toggle",
                        order = 1,
                        get = function() return self.db.profile.settings.chatChannels.SAY end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.SAY = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    yell = {
                        name = L["Yell"] or "Yell",
                        desc = L["Scan Yell channel"] or "Scan Yell channel",
                        type = "toggle",
                        order = 2,
                        get = function() return self.db.profile.settings.chatChannels.YELL end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.YELL = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    guild = {
                        name = L["Guild"] or "Guild",
                        desc = L["Scan Guild channel"] or "Scan Guild channel",
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.settings.chatChannels.GUILD end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.GUILD = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    party = {
                        name = L["Party"] or "Party",
                        desc = L["Scan Party channel"] or "Scan Party channel",
                        type = "toggle",
                        order = 4,
                        get = function() return self.db.profile.settings.chatChannels.PARTY end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.PARTY = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    raid = {
                        name = L["Raid"] or "Raid",
                        desc = L["Scan Raid channel"] or "Scan Raid channel",
                        type = "toggle",
                        order = 5,
                        get = function() return self.db.profile.settings.chatChannels.RAID end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.RAID = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    channel = {
                        name = L["Trade/General"] or "Trade/General",
                        desc = L["Scan Trade and General channels"] or "Scan Trade and General channels",
                        type = "toggle",
                        order = 6,
                        get = function() return self.db.profile.settings.chatChannels.CHANNEL end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.CHANNEL = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    whisper = {
                        name = L["Whisper"] or "Whisper",
                        desc = L["Scan Whisper messages"] or "Scan Whisper messages",
                        type = "toggle",
                        order = 7,
                        get = function() return self.db.profile.settings.chatChannels.WHISPER end,
                        set = function(_, value) 
                            self.db.profile.settings.chatChannels.WHISPER = value
                            if addon.core and addon.core.UpdateChatEventRegistrations then
                                addon.core:UpdateChatEventRegistrations()
                            end
                        end
                    },
                    spacer1 = {
                        name = "\n",
                        type = "description",
                        order = 8,
                        width = "full"
                    },
                    numberedChannelsHeader = {
                        name = "Numbered Channels (Trade, General, etc.)",
                        type = "header",
                        order = 9
                    },
                    numberedChannelsDesc = {
                        name = function()
                            -- Initialize specificChannels if it doesn't exist
                            if not self.db.profile.settings.chatChannels.specificChannels then
                                self.db.profile.settings.chatChannels.specificChannels = {}
                            end
                            
                            -- Get all joined channels
                            local text = "|cff00FFFFJoined Channels:|r\n\n"
                            local hasChannels = false
                            
                            for i = 1, 20 do  -- WoW supports up to 20 channels
                                local id, name = GetChannelName(i)
                                if id and id > 0 and name then
                                    hasChannels = true
                                    local enabled = false
                                    for _, num in ipairs(self.db.profile.settings.chatChannels.specificChannels) do
                                        if num == id then
                                            enabled = true
                                            break
                                        end
                                    end
                                    
                                    local status = enabled and "|cff00ff00✓|r" or "|cffFF0000✗|r"
                                    text = text .. string.format("%s |cffFFD700%d.|r %s\n", status, id, name)
                                end
                            end
                            
                            if not hasChannels then
                                text = text .. "|cffFF6B6BNo channels joined. Join Trade, General, etc. and they will appear here.|r"
                            end
                            
                            return text
                        end,
                        type = "description",
                        order = 10,
                        width = "full",
                        fontSize = "medium"
                    },
                    toggleAllChannels = {
                        name = "Enable All Channels",
                        desc = "Enable or disable all numbered channels at once",
                        type = "execute",
                        order = 11,
                        func = function()
                            if not self.db.profile.settings.chatChannels.specificChannels then
                                self.db.profile.settings.chatChannels.specificChannels = {}
                            end
                            
                            local channels = self.db.profile.settings.chatChannels.specificChannels
                            local allEnabled = true
                            
                            -- Check if all are enabled
                            for i = 1, 20 do
                                local id, name = GetChannelName(i)
                                if id and id > 0 then
                                    local found = false
                                    for _, num in ipairs(channels) do
                                        if num == id then
                                            found = true
                                            break
                                        end
                                    end
                                    if not found then
                                        allEnabled = false
                                        break
                                    end
                                end
                            end
                            
                            -- Toggle
                            if allEnabled then
                                -- Disable all
                                self.db.profile.settings.chatChannels.specificChannels = {}
                                print("|cff00ff00ChatScanner PRO:|r All channels disabled")
                            else
                                -- Enable all
                                local newChannels = {}
                                for i = 1, 20 do
                                    local id, name = GetChannelName(i)
                                    if id and id > 0 then
                                        table.insert(newChannels, id)
                                    end
                                end
                                self.db.profile.settings.chatChannels.specificChannels = newChannels
                                print("|cff00ff00ChatScanner PRO:|r All channels enabled")
                            end
                            
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("ChatScanner")
                        end
                    }
                }
            },
            appearance = {
                name = L["Notifications"] or "Notifications",
                type = "group",
                order = 4,
                args = {
                    barTexture = {
                        name = L["Bar Texture"] or "Bar Texture",
                        desc = L["Texture used for the bars"] or "Texture used for the bars",
                        type = "select",
                        dialogControl = "LSM30_Statusbar",
                        values = AceGUIWidgetLSMlists.statusbar,
                        order = 1,
                        get = function() return self.db.profile.appearance.barTexture end,
                        set = function(_, value) self.db.profile.appearance.barTexture = value end
                    },
                    font = {
                        name = L["Font"] or "Font",
                        desc = L["Font used for the bars"] or "Font used for the bars",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        values = AceGUIWidgetLSMlists.font,
                        order = 2,
                        get = function() return self.db.profile.appearance.font end,
                        set = function(_, value) self.db.profile.appearance.font = value end
                    },
                    fontSize = {
                        name = L["Font Size"] or "Font Size",
                        desc = L["Size of the font"] or "Size of the font",
                        type = "range",
                        min = 8,
                        max = 20,
                        step = 1,
                        order = 3,
                        get = function() return self.db.profile.appearance.fontSize end,
                        set = function(_, value) self.db.profile.appearance.fontSize = value end
                    },
                    sound = {
                        name = L["Sound"] or "Sound",
                        desc = L["Sound played when a match is found"] or "Sound played when a match is found",
                        type = "select",
                        dialogControl = "LSM30_Sound",
                        values = AceGUIWidgetLSMlists.sound,
                        order = 4,
                        get = function() return self.db.profile.appearance.sound end,
                        set = function(_, value) self.db.profile.appearance.sound = value end
                    },
                    barWidth = {
                        name = L["Bar Width"] or "Bar Width",
                        desc = L["Width of the bars"] or "Width of the bars",
                        type = "range",
                        min = 100,
                        max = 400,
                        step = 10,
                        order = 5,
                        get = function() return self.db.profile.appearance.barWidth end,
                        set = function(_, value) self.db.profile.appearance.barWidth = value end
                    },
                    barHeight = {
                        name = L["Bar Height"] or "Bar Height",
                        desc = L["Height of the bars"] or "Height of the bars",
                        type = "range",
                        min = 10,
                        max = 40,
                        step = 1,
                        order = 6,
                        get = function() return self.db.profile.appearance.barHeight end,
                        set = function(_, value) self.db.profile.appearance.barHeight = value end
                    },
                    barSpacing = {
                        name = L["Bar Spacing"] or "Bar Spacing",
                        desc = L["Spacing between bars"] or "Spacing between bars",
                        type = "range",
                        min = 0,
                        max = 10,
                        step = 1,
                        order = 7,
                        get = function() return self.db.profile.appearance.barSpacing end,
                        set = function(_, value) self.db.profile.appearance.barSpacing = value end
                    },
                    barGrowDirection = {
                        name = L["Bar Grow Direction"] or "Bar Grow Direction",
                        desc = L["Direction in which bars grow"] or "Direction in which bars grow",
                        type = "select",
                        values = {
                            UP = L["Up"] or "Up",
                            DOWN = L["Down"] or "Down"
                        },
                        order = 8,
                        get = function() return self.db.profile.appearance.barGrowDirection end,
                        set = function(_, value) self.db.profile.appearance.barGrowDirection = value end
                    },
                    barOpacity = {
                        name = L["Bar Opacity"] or "Bar Opacity",
                        desc = L["Transparency of notification bars"] or "Transparency of notification bars (0 = invisible, 1 = opaque)",
                        type = "range",
                        min = 0.1,
                        max = 1.0,
                        step = 0.05,
                        order = 8.1,
                        get = function() return self.db.profile.appearance.barOpacity end,
                        set = function(_, value) self.db.profile.appearance.barOpacity = value end
                    },
                    fadeInDuration = {
                        name = L["Fade In Duration"] or "Fade In Duration",
                        desc = L["How long bars take to appear"] or "How long bars take to fade in (in seconds)",
                        type = "range",
                        min = 0.0,
                        max = 2.0,
                        step = 0.1,
                        order = 8.2,
                        get = function() return self.db.profile.appearance.fadeInDuration end,
                        set = function(_, value) self.db.profile.appearance.fadeInDuration = value end
                    },
                    fadeOutDuration = {
                        name = L["Fade Out Duration"] or "Fade Out Duration",
                        desc = L["How long bars take to disappear"] or "How long bars take to fade out (in seconds)",
                        type = "range",
                        min = 0.0,
                        max = 2.0,
                        step = 0.1,
                        order = 8.3,
                        get = function() return self.db.profile.appearance.fadeOutDuration end,
                        set = function(_, value) self.db.profile.appearance.fadeOutDuration = value end
                    },
                    pauseOnHover = {
                        name = L["Pause on Hover"] or "Pause on Hover",
                        desc = L["Pause fade-out when mouse is over the bar"] or "Pause fade-out timer when mouse is hovering over the notification bar",
                        type = "toggle",
                        order = 8.4,
                        get = function() return self.db.profile.appearance.pauseOnHover end,
                        set = function(_, value) self.db.profile.appearance.pauseOnHover = value end
                    },
                    spacer = {
                        name = "",
                        type = "description",
                        order = 9,
                        width = "full"
                    },
                    testNotification = {
                        name = L["Test Notification"] or "Test Notification",
                        desc = L["Show a test notification bar"] or "Show a test notification bar to preview your appearance settings",
                        type = "execute",
                        order = 10,
                        width = "full",
                        func = function()
                            if addon.core and addon.core.TestNotification then
                                addon.core:TestNotification()
                            else
                                print("Test notification not available")
                            end
                        end
                    },
                    unlockBars = {
                        name = L["Toggle Lock/Unlock"] or "Toggle Lock/Unlock Bars",
                        desc = L["Toggle lock/unlock bars position"] or "Toggle lock/unlock to move the notification bars position. A green anchor will appear that you can drag.",
                        type = "execute",
                        order = 11,
                        width = "full",
                        func = function()
                            if addon.core and addon.core.ToggleBarsLock then
                                addon.core:ToggleBarsLock()
                            else
                                print("Toggle lock not available")
                            end
                        end
                    }
                }
            },
            autoFlood = {
                name = L["Auto Messages"] or "Auto Messages",
                type = "group",
                order = 5,
                args = {
                    collapseAll = {
                        name = L["Collapse All"] or "Collapse All",
                        desc = L["Collapse all messages"] or "Collapse all auto messages to see them at a glance",
                        type = "execute",
                        order = 0.5,
                        width = "normal",
                        func = function()
                            for _, msg in ipairs(self.db.profile.autoFlood.messages) do
                                msg.collapsed = true
                            end
                            self:UpdateAutoFloodOptions()
                        end
                    },
                    description = {
                        name = L["Auto Flood Description"] or "Automatically send messages at regular intervals. Create multiple messages that will rotate. Each message can have its own channel.",
                        type = "description",
                        order = 1,
                        width = "full",
                        fontSize = "medium"
                    },
                    variables = {
                        name = L["Available Variables"] or "|cff00FFFFAvailable Variables:|r\n" ..
                               "{name} - Your character name\n" ..
                               "{level} - Your level\n" ..
                               "{class} - Your class name\n" ..
                               "{coloredclass} - Your class name with color\n" ..
                               "{zone} - Current zone\n" ..
                               "{time} - Current game time\n" ..
                               "{guild} - Your guild name\n\n" ..
                               "|cffFFD700Example:|r WTS services! Whisper {name} - Level {level} {class}",
                        type = "description",
                        order = 2,
                        width = "full",
                        fontSize = "small"
                    },
                    spacer1 = {
                        name = "",
                        type = "description",
                        order = 3,
                        width = "full"
                    },
                    addMessage = {
                        name = L["Add New Message"] or "|cff00FF00+ Add New Message|r",
                        desc = L["Add a new message to the rotation"] or "Add a new message to the rotation",
                        type = "execute",
                        order = 4,
                        width = "full",
                        func = function()
                            -- Check if there's already an unconfigured message
                            for _, m in ipairs(self.db.profile.autoFlood.messages) do
                                if m.text == "Your message here" and not m.enabled then
                                    print("|cffFF6B6BChatScanner PRO:|r You already have an unconfigured message. Please configure it first!")
                                    return
                                end
                            end
                            
                            table.insert(self.db.profile.autoFlood.messages, {
                                text = "Your message here",
                                channel = "say",
                                enabled = false  -- Disabled by default until configured
                            })
                            self:UpdateAutoFloodOptions()
                            print("|cffFFD700ChatScanner PRO:|r New message created. Configure it and enable it when ready!")
                        end
                    },
                    messageList = {
                        name = "",
                        type = "group",
                        inline = true,
                        order = 5,
                        args = {} -- Will be populated dynamically with messages
                    },
                    spacer2 = {
                        name = "",
                        type = "description",
                        order = 6,
                        width = "full"
                    },
                    rate = {
                        name = L["Rate (seconds)"] or "Rate (seconds)",
                        desc = L["Time between messages"] or "Time in seconds between each message (minimum 10 seconds)",
                        type = "range",
                        min = 10,
                        max = 600,
                        step = 5,
                        order = 7,
                        get = function() return self.db.profile.autoFlood.rate end,
                        set = function(_, value) self.db.profile.autoFlood.rate = value end
                    },
                    spacer3 = {
                        name = "",
                        type = "description",
                        order = 8,
                        width = "full"
                    },
                    status = {
                        name = L["Status"] or "Status",
                        type = "description",
                        order = 9,
                        width = "full",
                        fontSize = "medium",
                        get = function()
                            if addon.AutoFlood and addon.AutoFlood.GetStatus then
                                return addon.AutoFlood:GetStatus()
                            end
                            return "AutoFlood module not loaded"
                        end
                    },
                    toggleFlood = {
                        name = function()
                            if addon.AutoFlood and addon.AutoFlood.IsActive and addon.AutoFlood:IsActive() then
                                return L["Stop AutoFlood"] or "STOP AutoFlood"
                            else
                                return L["Start AutoFlood"] or "START AutoFlood"
                            end
                        end,
                        desc = L["Toggle AutoFlood"] or "Start or stop the automatic message flooding",
                        type = "execute",
                        order = 10,
                        width = "full",
                        func = function()
                            if addon.AutoFlood and addon.AutoFlood.Toggle then
                                addon.AutoFlood:Toggle()
                            else
                                print("AutoFlood module not available")
                            end
                        end
                    }
                }
            },
            history = {
                name = L["Match History"] or "Match History",
                type = "group",
                order = 6,
                args = {
                    description = {
                        name = L["History Description"] or "View all captured messages with timestamps. Use filters to search specific entries.",
                        type = "description",
                        order = 1,
                        width = "full",
                        fontSize = "medium"
                    },
                    statisticsHeader = {
                        name = L["Statistics"] or "Statistics",
                        type = "header",
                        order = 1.5
                    },
                    statistics = {
                        name = function()
                            local stats = self.db.profile.statistics
                            if not stats or not stats.filterMatches then
                                return "No statistics available"
                            end
                            
                            local text = "|cff00FFFFFilter Statistics|r\n\n"
                            local totalToday = 0
                            local totalWeek = 0
                            local totalAll = 0
                            
                            -- Calculate totals and find most active
                            local mostActive = {name = "None", count = 0}
                            for filterName, data in pairs(stats.filterMatches) do
                                totalToday = totalToday + (data.today or 0)
                                totalWeek = totalWeek + (data.week or 0)
                                totalAll = totalAll + (data.total or 0)
                                
                                if (data.total or 0) > mostActive.count then
                                    mostActive.name = filterName
                                    mostActive.count = data.total or 0
                                end
                            end
                            
                            text = text .. string.format("|cffFFD700Today:|r %d matches\n", totalToday)
                            text = text .. string.format("|cffFFD700This Week:|r %d matches\n", totalWeek)
                            text = text .. string.format("|cffFFD700All Time:|r %d matches\n\n", totalAll)
                            text = text .. string.format("|cffFFD700Most Active Filter:|r %s (%d matches)\n\n", mostActive.name, mostActive.count)
                            
                            text = text .. "|cff00FFFFPer Filter:|r\n"
                            for filterName, data in pairs(stats.filterMatches) do
                                text = text .. string.format("  • %s: Today=%d, Week=%d, Total=%d\n", 
                                    filterName, data.today or 0, data.week or 0, data.total or 0)
                            end
                            
                            return text
                        end,
                        type = "description",
                        order = 1.6,
                        width = "full",
                        fontSize = "medium"
                    },
                    resetStats = {
                        name = L["Reset Statistics"] or "|cffFF0000Reset Statistics|r",
                        desc = L["Reset all statistics"] or "Reset all statistics counters",
                        type = "execute",
                        order = 1.7,
                        confirm = function()
                            return "Are you sure you want to reset all statistics?"
                        end,
                        func = function()
                            self.db.profile.statistics.filterMatches = {}
                            self.db.profile.statistics.lastReset = time()
                            self.db.profile.statistics.lastWeekReset = time()
                            print("|cff00ff00ChatScanner PRO:|r Statistics reset")
                        end
                    },
                    spacer1 = {
                        name = "",
                        type = "description",
                        order = 2,
                        width = "full"
                    },
                    enabled = {
                        name = L["Enable History"] or "Enable History",
                        desc = L["Enable or disable history tracking"] or "Enable or disable history tracking",
                        type = "toggle",
                        order = 3,
                        get = function() return self.db.profile.history.enabled end,
                        set = function(_, value) self.db.profile.history.enabled = value end
                    },
                    maxEntries = {
                        name = L["Max Entries"] or "Max Entries",
                        desc = L["Maximum number of history entries"] or "Maximum number of history entries to keep",
                        type = "range",
                        min = 10,
                        max = 2000,
                        step = 10,
                        order = 4,
                        get = function() return self.db.profile.history.maxEntries end,
                        set = function(_, value) self.db.profile.history.maxEntries = value end
                    },
                    clearHistory = {
                        name = L["Clear History"] or "|cffFF0000Clear History|r",
                        desc = L["Clear all history entries"] or "Clear all history entries",
                        type = "execute",
                        order = 5,
                        confirm = function()
                            return "Are you sure you want to clear all history?"
                        end,
                        func = function()
                            self.db.profile.history.entries = {}
                            print("|cff00ff00ChatScanner PRO:|r History cleared")
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("ChatScanner")
                        end
                    },
                    fixHistory = {
                        name = "Fix Corrupted Entries",
                        desc = "Remove history entries with missing data",
                        type = "execute",
                        order = 5.5,
                        func = function()
                            local entries = self.db.profile.history.entries
                            local removed = 0
                            
                            for i = #entries, 1, -1 do
                                local entry = entries[i]
                                if not entry.playerName or not entry.message or not entry.filterName then
                                    table.remove(entries, i)
                                    removed = removed + 1
                                end
                            end
                            
                            print("|cff00ff00ChatScanner PRO:|r Removed " .. removed .. " corrupted entries")
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("ChatScanner")
                        end
                    },
                    spacer2 = {
                        name = "",
                        type = "description",
                        order = 6,
                        width = "full"
                    },
                    searchHeader = {
                        name = L["Search & Filter"] or "Search & Filter",
                        type = "header",
                        order = 7
                    },
                    searchPlayer = {
                        name = L["Search Player"] or "Search Player",
                        desc = L["Filter by player name"] or "Filter history by player name (leave empty for all)",
                        type = "input",
                        order = 8,
                        width = "full",
                        get = function() return self.db.profile.history.searchPlayer or "" end,
                        set = function(_, value) self.db.profile.history.searchPlayer = value end
                    },
                    searchFilter = {
                        name = L["Search Filter"] or "Search Filter",
                        desc = L["Filter by filter name"] or "Filter history by filter name",
                        type = "select",
                        order = 9,
                        values = function()
                            local filters = {[""] = "All Filters"}
                            for _, filter in ipairs(self.db.profile.filters or {}) do
                                filters[filter.name] = filter.name
                            end
                            return filters
                        end,
                        get = function() return self.db.profile.history.searchFilter or "" end,
                        set = function(_, value) self.db.profile.history.searchFilter = value end
                    },
                    searchChannel = {
                        name = L["Search Channel"] or "Search Channel",
                        desc = L["Filter by channel"] or "Filter history by channel",
                        type = "select",
                        order = 10,
                        values = {
                            [""] = "All Channels",
                            ["SAY"] = "Say",
                            ["GUILD"] = "Guild",
                            ["PARTY"] = "Party",
                            ["RAID"] = "Raid",
                            ["YELL"] = "Yell",
                            ["WHISPER"] = "Whisper",
                            ["CHANNEL"] = "Channel",
                            ["Trade"] = "Trade",
                            ["General"] = "General"
                        },
                        get = function() return self.db.profile.history.searchChannel or "" end,
                        set = function(_, value) self.db.profile.history.searchChannel = value end
                    },
                    spacer3 = {
                        name = "",
                        type = "description",
                        order = 11,
                        width = "full"
                    },
                    refreshHistory = {
                        name = L["Refresh"] or "Refresh Results",
                        desc = L["Refresh history display"] or "Click to refresh the history display",
                        type = "execute",
                        order = 11.5,
                        func = function()
                            -- Just refresh the interface
                            LibStub("AceConfigRegistry-3.0"):NotifyChange("ChatScanner")
                        end
                    },
                    historyList = {
                        name = function()
                            local title = L["Results"] or "Results"
                            title = title .. "\n" .. string.rep("-", 50) .. "\n\n"
                            local entries = self.db.profile.history.entries
                            if #entries == 0 then
                                return "No matches yet"
                            end
                            
                            -- Apply filters
                            local filtered = {}
                            local searchPlayer = self.db.profile.history.searchPlayer or ""
                            local searchFilter = self.db.profile.history.searchFilter or ""
                            local searchChannel = self.db.profile.history.searchChannel or ""
                            
                            for _, entry in ipairs(entries) do
                                local match = true
                                
                                -- Filter by player
                                if searchPlayer ~= "" then
                                    if not string.find(string.lower(entry.playerName), string.lower(searchPlayer)) then
                                        match = false
                                    end
                                end
                                
                                -- Filter by filter name
                                if searchFilter ~= "" then
                                    if entry.filterName ~= searchFilter then
                                        match = false
                                    end
                                end
                                
                                -- Filter by channel
                                if searchChannel ~= "" then
                                    if not string.find(entry.channel, searchChannel) then
                                        match = false
                                    end
                                end
                                
                                if match then
                                    table.insert(filtered, entry)
                                end
                            end
                            
                            if #filtered == 0 then
                                return title .. "|cffFF0000No results found|r\n\nTry adjusting your search filters."
                            end
                            
                            local text = title .. string.format("|cff00FFFF%d results found|r\n\n", #filtered)
                            for i = 1, math.min(20, #filtered) do
                                local entry = filtered[i]
                                local timeStr = date("%H:%M:%S", entry.timestamp or 0)
                                local playerName = entry.playerName or "Unknown"
                                local channel = entry.channel or "Unknown"
                                local filterName = entry.filterName or "Unknown"
                                local matchedKeyword = entry.matchedKeyword or "N/A"
                                local message = entry.message or ""
                                
                                text = text .. string.format("|cffFFD700[%s]|r |cff00FFFF%s|r in |cffFF6B6B%s|r\n", 
                                    timeStr, playerName, channel)
                                text = text .. string.format("  Filter: |cffFFFFFF%s|r | Keyword: |cff00ff00%s|r\n", 
                                    filterName, matchedKeyword)
                                text = text .. string.format("  Message: %s\n\n", message)
                            end
                            
                            if #filtered > 20 then
                                text = text .. string.format("... and %d more results (showing first 20)", #filtered - 20)
                            end
                            
                            return text
                        end,
                        type = "description",
                        order = 12,
                        width = "full",
                        fontSize = "medium"
                    }
                }
            },
            blacklist = {
                name = L["Blacklist"] or "Blacklist",
                type = "group",
                order = 7,
                args = {
                    description = {
                        name = L["Blacklist Description"] or "Manage ignored players. Blacklisted players will not trigger notifications.",
                        type = "description",
                        order = 1,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer1 = {
                        name = "",
                        type = "description",
                        order = 2,
                        width = "full"
                    },
                    clearBlacklist = {
                        name = L["Clear All"] or "|cffFF0000Clear All Blacklist|r",
                        desc = L["Remove all players from blacklist"] or "Remove all players from blacklist",
                        type = "execute",
                        order = 3,
                        confirm = function()
                            return "Are you sure you want to clear the entire blacklist?"
                        end,
                        func = function()
                            self.db.profile.blacklist.players = {}
                            print("|cff00ff00ChatScanner PRO:|r Blacklist cleared")
                        end
                    },
                    spacer2 = {
                        name = "",
                        type = "description",
                        order = 4,
                        width = "full"
                    },
                    blacklistList = {
                        name = function()
                            local players = self.db.profile.blacklist.players
                            if not players or #players == 0 then
                                return "No blacklisted players"
                            end
                            
                            local text = string.format("|cff00FFFF%d blacklisted players|r\n\n", #players)
                            local currentTime = time()
                            
                            for i, entry in ipairs(players) do
                                local timeStr = date("%Y-%m-%d %H:%M", entry.timestamp)
                                local status = ""
                                
                                if entry.duration == 0 then
                                    status = "|cffFF0000Forever|r"
                                else
                                    local expiresAt = entry.timestamp + entry.duration
                                    if currentTime >= expiresAt then
                                        status = "|cff888888Expired|r"
                                    else
                                        local remaining = expiresAt - currentTime
                                        local hours = math.floor(remaining / 3600)
                                        status = string.format("|cffFFFF00%dh remaining|r", hours)
                                    end
                                end
                                
                                text = text .. string.format("|cffFFD700%d.|r |cff00FFFF%s|r - %s\n", i, entry.name, status)
                                text = text .. string.format("   Added: %s | Reason: %s\n\n", timeStr, entry.reason or "No reason")
                            end
                            
                            return text
                        end,
                        type = "description",
                        order = 5,
                        width = "full",
                        fontSize = "medium"
                    }
                }
            },
            templates = {
                name = L["Quick Replies"] or "Quick Replies",
                type = "group",
                order = 8,
                args = {
                    collapseAll = {
                        name = L["Collapse All"] or "Collapse All",
                        desc = L["Collapse all templates"] or "Collapse all templates to see them at a glance",
                        type = "execute",
                        order = 0.5,
                        width = "normal",
                        func = function()
                            for _, template in ipairs(self.db.profile.templates) do
                                template.collapsed = true
                            end
                            self:UpdateTemplateOptions()
                        end
                    },
                    description = {
                        name = L["Templates Description"] or "Create predefined response templates. Use them to quickly reply to players.",
                        type = "description",
                        order = 1,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer1 = {
                        name = "",
                        type = "description",
                        order = 2,
                        width = "full"
                    },
                    addTemplate = {
                        name = L["Add New Template"] or "|cff00FF00+ Add New Template|r",
                        desc = L["Add a new response template"] or "Add a new response template",
                        type = "execute",
                        order = 3,
                        width = "full",
                        func = function()
                            -- Check if there's already an unconfigured template
                            for _, t in ipairs(self.db.profile.templates) do
                                if t.text == "Your response here" and not t.enabled then
                                    print("|cffFF6B6BChatScanner PRO:|r You already have an unconfigured template. Please configure it first!")
                                    return
                                end
                            end
                            
                            -- Find next available number for template name
                            local templateNum = 1
                            local nameExists = true
                            while nameExists do
                                nameExists = false
                                for _, t in ipairs(self.db.profile.templates) do
                                    if t.name == "New Template #" .. templateNum then
                                        nameExists = true
                                        templateNum = templateNum + 1
                                        break
                                    end
                                end
                            end
                            
                            table.insert(self.db.profile.templates, {
                                name = "New Template #" .. templateNum,
                                text = "Your response here",
                                enabled = false  -- Disabled by default until configured
                            })
                            self:UpdateTemplateOptions()
                            print("|cffFFD700ChatScanner PRO:|r New template created. Configure it and enable it when ready!")
                        end
                    },
                    templateList = {
                        name = "",
                        type = "group",
                        inline = true,
                        order = 4,
                        args = {} -- Will be populated dynamically
                    }
                }
            },
            help = {
                name = L["Help & Guide"] or "Help & Guide",
                type = "group",
                order = 9,
                args = {
                    welcome = {
                        name = L["Welcome"] or "Welcome to ChatScanner PRO!",
                        type = "description",
                        order = 1,
                        width = "full",
                        fontSize = "large"
                    },
                    intro = {
                        name = "ChatScanner PRO is a powerful addon for monitoring chat messages and automating responses. " ..
                               "It helps you catch important messages, reply quickly, and advertise your services automatically.",
                        type = "description",
                        order = 2,
                        width = "full",
                        fontSize = "medium",
                        image = "Interface\\Icons\\INV_Misc_Book_09",
                        imageWidth = 32,
                        imageHeight = 32
                    },
                    spacer1 = {
                        name = "\n",
                        type = "description",
                        order = 3,
                        width = "full"
                    },
                    gettingStarted = {
                        name = L["Getting Started"] or "Getting Started",
                        type = "header",
                        order = 4
                    },
                    gettingStartedText = {
                        name = "|cffFFD7001. Create a Filter|r\n" ..
                               "Go to the 'Keyword Filters' tab and click '+ Add New Filter'. Give it a name and add keywords.\n\n" ..
                               "|cffFFD7002. Configure Keywords|r\n" ..
                               "Use comma-separated keywords. Examples:\n" ..
                               "  - Standard: wts, vend (matches if ANY keyword is present)\n" ..
                               "  - Required: +wts+, +vend+ (matches if ALL keywords are present)\n" ..
                               "  - Group: &wts vend& (matches if all words in group are together)\n\n" ..
                               "|cffFFD7003. Choose a Color|r\n" ..
                               "Pick a color for your filter to easily identify notifications.\n\n" ..
                               "|cffFFD7004. Enable Channels|r\n" ..
                               "Go to 'Channels' tab and enable the chat channels you want to monitor.\n\n" ..
                               "|cffFFD7005. Test It!|r\n" ..
                               "Click 'Test Notification' in the 'Notifications' tab to see how it looks.",
                        type = "description",
                        order = 5,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer2 = {
                        name = "\n",
                        type = "description",
                        order = 6,
                        width = "full"
                    },
                    features = {
                        name = L["Features"] or "Features",
                        type = "header",
                        order = 7
                    },
                    featuresText = {
                        name = "|cff00FFFFKeyword Filters|r\n" ..
                               "Monitor multiple chat channels with smart keyword filtering. Get instant notifications when someone mentions your keywords. Auto-collapse system keeps your interface clean.\n\n" ..
                               "|cff00FFFFSmart Notifications|r\n" ..
                               "Notifications show player level, class icon with color, and guild name. 4 action buttons: Reply, Invite, Copy, Ignore. Up to 100 notifications on screen, duration up to 120 seconds.\n\n" ..
                               "|cff00FFFFQuick Replies|r\n" ..
                               "Create predefined response templates in the 'Quick Replies' tab. Perfect for pricing, availability, or common questions. Right-click Reply button to use them!\n\n" ..
                               "|cff00FFFFBlacklist System|r\n" ..
                               "Ignore annoying players! Click 'Ignore' on any notification and choose: 1 Hour, 24 Hours, or Forever. All notifications from blacklisted players are automatically closed and future messages are blocked.\n\n" ..
                               "|cff00FFFFMatch History & Statistics|r\n" ..
                               "View all captured messages with timestamps in the 'Match History' tab. Search by player name, filter, or channel. Track statistics: matches per filter (today/week/total), most active filter.\n\n" ..
                               "|cff00FFFFAuto Messages|r\n" ..
                               "Automatically send messages at regular intervals in the 'Auto Messages' tab. Use {name}, {level}, {class}, {zone}, {time}, {guild} variables! Supports multiple messages with rotation.\n\n" ..
                               "|cff00FFFFAnti-Spam Filter|r\n" ..
                               "Intelligent duplicate detection! Ignores identical messages from the same player within 5 seconds, even across different channels. No more spam!\n\n" ..
                               "|cff00FFFFDynamic Channel Detection|r\n" ..
                               "Automatically detects all joined channels (Trade, General, LocalDefense, etc.). Enable/disable specific channels individually or all at once.\n\n" ..
                               "|cff00FFFFMinimap Button|r\n" ..
                               "Quick access to toggle scanner, start/stop auto messages, test notifications, and more. Left-click to toggle, right-click for menu.\n\n" ..
                               "|cff00FFFFCustomization|r\n" ..
                               "Change colors, textures, fonts, sizes, and positions in 'Notifications' tab. Organize filters by categories. Make it look exactly how you want!",
                        type = "description",
                        order = 8,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer3 = {
                        name = "\n",
                        type = "description",
                        order = 9,
                        width = "full"
                    },
                    commands = {
                        name = L["Commands"] or "Commands & Access",
                        type = "header",
                        order = 10
                    },
                    commandsText = {
                        name = "|cffFFD700/cs|r or |cffFFD700/craftscan|r - Open ChatScanner PRO options\n\n" ..
                               "|cff00FFFFAccess Methods:|r\n" ..
                               "• Type |cffffffff/cs|r in chat\n" ..
                               "• Click the |cff00ff00Minimap Button|r (right-click for quick menu)\n" ..
                               "• Click the |cff00ff00Menu Button|r in center screen (can be hidden in Settings)\n" ..
                               "• Use the |cff00ff00LDB launcher|r if you have a DataBroker display addon\n\n" ..
                               "|cffFF6B6BTip:|r You can hide the center menu button in the Settings tab if you prefer using /cs or the minimap button!",
                        type = "description",
                        order = 11,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer4 = {
                        name = "\n",
                        type = "description",
                        order = 12,
                        width = "full"
                    },
                    tips = {
                        name = L["Tips & Tricks"] or "Tips & Tricks",
                        type = "header",
                        order = 13
                    },
                    tipsText = {
                        name = "|cff00FF00Tip 1:|r Use the auto-collapse feature! Only one filter/template/message expanded at a time keeps your interface clean.\n\n" ..
                               "|cff00FF00Tip 2:|r Enable 'Anti-Spam Filter' in Settings to avoid duplicate notifications across multiple channels.\n\n" ..
                               "|cff00FF00Tip 3:|r Click 'Enable All Channels' in the Channels tab to quickly monitor all joined channels (Trade, General, etc.).\n\n" ..
                               "|cff00FF00Tip 4:|r Use the Blacklist! Click 'Ignore' on any notification to block annoying players (1h/24h/Forever).\n\n" ..
                               "|cff00FF00Tip 5:|r Check Statistics in Match History to see which filters are most active and optimize your setup.\n\n" ..
                               "|cff00FF00Tip 6:|r Set notification duration to 120 seconds if you want them to stay until you click them.\n\n" ..
                               "|cff00FF00Tip 7:|r Use 'Pause in Combat' option to avoid distractions during fights.\n\n" ..
                               "|cff00FF00Tip 8:|r Create multiple Quick Replies templates for different situations (busy, available, pricing).\n\n" ..
                               "|cff00FF00Tip 9:|r Use different colors for different filter priorities (red = urgent, green = normal).\n\n" ..
                               "|cff00FF00Tip 10:|r New filters are created disabled by default - configure them first, then enable!",
                        type = "description",
                        order = 14,
                        width = "full",
                        fontSize = "medium"
                    },
                    spacer5 = {
                        name = "\n",
                        type = "description",
                        order = 15,
                        width = "full"
                    },
                    support = {
                        name = L["Support"] or "Support & Credits",
                        type = "header",
                        order = 16
                    },
                    supportText = {
                        name = "|cffFFD700ChatScanner PRO|r by |cff00FFFFSuperRsk|r\n\n" ..
                               "Version: 2.0.0\n\n" ..
                               "Special thanks to:\n" ..
                               "- AutoFlood addon by LenweSaralonde\n" ..
                               "- MessageQueue library\n" ..
                               "- Ace3 framework\n" ..
                               "- LibSharedMedia\n\n" ..
                               "Enjoy the addon! :)",
                        type = "description",
                        order = 17,
                        width = "full",
                        fontSize = "medium"
                    }
                }
            }
        }
    }
    
    return options
end

-- Update AutoFlood message options
function config:UpdateAutoFloodOptions()
    local messageOptions = self.options.args.autoFlood.args.messageList.args
    wipe(messageOptions)
    
    local messages = self.db.profile.autoFlood.messages
    for i, msg in ipairs(messages) do
        local key = "message" .. i
        
        -- Create collapsed state if it doesn't exist
        if msg.collapsed == nil then
            msg.collapsed = false
        end
        
        -- If collapsed, create a group with expand, toggle, and move buttons
        if msg.collapsed then
            messageOptions[key] = {
                name = "[+] Message #" .. i .. " - " .. (msg.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r") .. " (" .. (msg.channel or "say") .. ")",
                type = "group",
                inline = true,
                order = i + 10,
                args = {
                    expand = {
                        name = "Expand",
                        desc = "Click to expand this message",
                        type = "execute",
                        order = 1,
                        width = "half",
                        func = function()
                            -- Collapse all other messages first
                            for _, m in ipairs(messages) do
                                if m ~= msg then
                                    m.collapsed = true
                                end
                            end
                            -- Then expand this one
                            msg.collapsed = false
                            self:UpdateAutoFloodOptions()
                        end
                    },
                    toggle = {
                        name = "Enabled",
                        desc = "Enable or disable this message",
                        type = "toggle",
                        order = 1.5,
                        width = "half",
                        get = function() return msg.enabled end,
                        set = function(_, value) 
                            msg.enabled = value
                            self:UpdateAutoFloodOptions()
                        end
                    },
                    moveUp = {
                        name = "Up",
                        desc = "Move this message up",
                        type = "execute",
                        order = 2,
                        width = "half",
                        disabled = function() return i == 1 end,
                        func = function()
                            messages[i], messages[i-1] = messages[i-1], messages[i]
                            self:UpdateAutoFloodOptions()
                        end
                    },
                    moveDown = {
                        name = "Down",
                        desc = "Move this message down",
                        type = "execute",
                        order = 3,
                        width = "half",
                        disabled = function() return i == #messages end,
                        func = function()
                            messages[i], messages[i+1] = messages[i+1], messages[i]
                            self:UpdateAutoFloodOptions()
                        end
                    }
                }
            }
        else
            -- Expanded: show full group
            messageOptions[key] = {
                name = "[-] Message #" .. i,
                type = "group",
                order = i + 10,
                args = {
                    toggleCollapse = {
                        name = "Collapse",
                        desc = "Collapse this message to save space",
                        type = "execute",
                        order = 0,
                        width = "full",
                        func = function()
                            msg.collapsed = true
                            self:UpdateAutoFloodOptions()
                        end
                    },
                    spacerCollapse = {
                        name = "",
                        type = "description",
                        order = 0.5,
                        width = "full"
                    },
                text = {
                    name = L["Message Text"] or "Message Text",
                    desc = L["The message to send"] or "The message to send",
                    type = "input",
                    width = "full",
                    multiline = 3,
                    order = 1,
                    get = function() return msg.text end,
                    set = function(_, value) msg.text = value end
                },
                channel = {
                    name = L["Channel"] or "Channel",
                    desc = L["Channel to send to"] or "Channel where this message will be sent",
                    type = "select",
                    values = {
                        ["say"] = "Say",
                        ["guild"] = "Guild",
                        ["party"] = "Party",
                        ["raid"] = "Raid",
                        ["i"] = "Instance",
                        ["bg"] = "Battleground",
                        ["trade"] = "Trade",
                        ["general"] = "General",
                    },
                    order = 2,
                    get = function() return msg.channel end,
                    set = function(_, value) msg.channel = value end
                },
                enabled = {
                    name = L["Enabled"] or "Enabled",
                    desc = L["Enable or disable this message"] or "Enable or disable this message",
                    type = "toggle",
                    order = 3,
                    get = function() return msg.enabled end,
                    set = function(_, value) msg.enabled = value end
                },
                delete = {
                    name = L["Delete"] or "|cffFF0000Delete|r",
                    desc = L["Delete this message"] or "Delete this message",
                    type = "execute",
                    order = 4,
                    confirm = function()
                        return "Are you sure you want to delete Message #" .. i .. "?\n\nThis action cannot be undone."
                    end,
                    func = function()
                        table.remove(messages, i)
                        self:UpdateAutoFloodOptions()
                        print("|cff00ff00ChatScanner PRO:|r Message #" .. i .. " deleted")
                    end
                }
                }
            }
        end
    end
end

-- Update Template options
function config:UpdateTemplateOptions()
    local templateOptions = self.options.args.templates.args.templateList.args
    wipe(templateOptions)
    
    local templates = self.db.profile.templates
    for i, template in ipairs(templates) do
        local key = "template" .. i
        
        -- Create collapsed state if it doesn't exist
        if template.collapsed == nil then
            template.collapsed = false
        end
        
        -- If collapsed, create a group with expand, toggle, and move buttons
        if template.collapsed then
            templateOptions[key] = {
                name = "[+] " .. template.name .. " - " .. (template.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"),
                type = "group",
                inline = true,
                order = i + 10,
                args = {
                    expand = {
                        name = "Expand",
                        desc = "Click to expand this template",
                        type = "execute",
                        order = 1,
                        width = "half",
                        func = function()
                            -- Collapse all other templates first
                            for _, t in ipairs(templates) do
                                if t ~= template then
                                    t.collapsed = true
                                end
                            end
                            -- Then expand this one
                            template.collapsed = false
                            self:UpdateTemplateOptions()
                        end
                    },
                    toggle = {
                        name = "Enabled",
                        desc = "Enable or disable this template",
                        type = "toggle",
                        order = 1.5,
                        width = "half",
                        get = function() return template.enabled end,
                        set = function(_, value) 
                            template.enabled = value
                            self:UpdateTemplateOptions()
                        end
                    },
                    moveUp = {
                        name = "Up",
                        desc = "Move this template up",
                        type = "execute",
                        order = 2,
                        width = "half",
                        disabled = function() return i == 1 end,
                        func = function()
                            templates[i], templates[i-1] = templates[i-1], templates[i]
                            self:UpdateTemplateOptions()
                        end
                    },
                    moveDown = {
                        name = "Down",
                        desc = "Move this template down",
                        type = "execute",
                        order = 3,
                        width = "half",
                        disabled = function() return i == #templates end,
                        func = function()
                            templates[i], templates[i+1] = templates[i+1], templates[i]
                            self:UpdateTemplateOptions()
                        end
                    }
                }
            }
        else
            -- Expanded: show full group
            templateOptions[key] = {
                name = "[-] " .. template.name,
                type = "group",
                order = i + 10,
                args = {
                    toggleCollapse = {
                        name = "Collapse",
                        desc = "Collapse this template to save space",
                        type = "execute",
                        order = 0,
                        width = "full",
                        func = function()
                            template.collapsed = true
                            self:UpdateTemplateOptions()
                        end
                    },
                    spacerCollapse = {
                        name = "",
                        type = "description",
                        order = 0.5,
                        width = "full"
                    },
                name = {
                    name = L["Template Name"] or "Template Name",
                    desc = L["Name of this template"] or "Name of this template",
                    type = "input",
                    width = "full",
                    order = 1,
                    get = function() return template.name end,
                    set = function(_, value) template.name = value end
                },
                text = {
                    name = L["Response Text"] or "Response Text",
                    desc = L["The response message"] or "The response message to send",
                    type = "input",
                    width = "full",
                    multiline = 3,
                    order = 2,
                    get = function() return template.text end,
                    set = function(_, value) template.text = value end
                },
                enabled = {
                    name = L["Enabled"] or "Enabled",
                    desc = L["Enable or disable this template"] or "Enable or disable this template",
                    type = "toggle",
                    order = 3,
                    get = function() return template.enabled end,
                    set = function(_, value) template.enabled = value end
                },
                delete = {
                    name = L["Delete"] or "|cffFF0000Delete|r",
                    desc = L["Delete this template"] or "Delete this template",
                    type = "execute",
                    order = 4,
                    confirm = function()
                        return "Are you sure you want to delete the template '" .. template.name .. "'?\n\nThis action cannot be undone."
                    end,
                    func = function()
                        table.remove(templates, i)
                        self:UpdateTemplateOptions()
                        print("|cff00ff00ChatScanner PRO:|r Template '" .. template.name .. "' deleted")
                    end
                }
                }
            }
        end
    end
end

-- Update filter options
function config:UpdateFilterOptions()
    local filterOptions = self.options.args.filters.args.filterList.args
    wipe(filterOptions)
    
    local filters = self.db.profile.filters
    for i, filter in ipairs(filters) do
        local key = "filter" .. i
        
        -- Create collapsed state if it doesn't exist
        if filter.collapsed == nil then
            filter.collapsed = false
        end
        
        -- If collapsed, create a group with expand and move buttons
        if filter.collapsed then
            filterOptions[key] = {
                name = "[+] " .. filter.name .. " - " .. (filter.enabled and "|cff00ff00Enabled|r" or "|cffFF0000Disabled|r"),
                type = "group",
                inline = true,
                order = i + 10,
                args = {
                    expand = {
                        name = "Expand",
                        desc = "Click to expand this filter",
                        type = "execute",
                        order = 1,
                        width = "half",
                        func = function()
                            -- Collapse all other filters first
                            for _, f in ipairs(filters) do
                                if f ~= filter then
                                    f.collapsed = true
                                end
                            end
                            -- Then expand this one
                            filter.collapsed = false
                            self:UpdateFilterOptions()
                        end
                    },
                    toggle = {
                        name = "Enabled",
                        desc = "Enable or disable this filter",
                        type = "toggle",
                        order = 1.5,
                        width = "half",
                        get = function() return filter.enabled end,
                        set = function(_, value) 
                            filter.enabled = value
                            self:UpdateFilterOptions()
                        end
                    },
                    moveUp = {
                        name = "Up",
                        desc = "Move this filter up",
                        type = "execute",
                        order = 2,
                        width = "half",
                        disabled = function() return i == 1 end,
                        func = function()
                            filters[i], filters[i-1] = filters[i-1], filters[i]
                            self:UpdateFilterOptions()
                        end
                    },
                    moveDown = {
                        name = "Down",
                        desc = "Move this filter down",
                        type = "execute",
                        order = 3,
                        width = "half",
                        disabled = function() return i == #filters end,
                        func = function()
                            filters[i], filters[i+1] = filters[i+1], filters[i]
                            self:UpdateFilterOptions()
                        end
                    }
                }
            }
        else
            -- Expanded: show full group
            filterOptions[key] = {
                name = "[-] " .. filter.name,
                type = "group",
                order = i + 10,
                args = {
                    toggleCollapse = {
                        name = "Collapse",
                        desc = "Collapse this filter to save space",
                        type = "execute",
                        order = 0,
                        width = "full",
                        func = function()
                            filter.collapsed = true
                            self:UpdateFilterOptions()
                        end
                    },
                    spacerCollapse = {
                        name = "",
                        type = "description",
                        order = 0.5,
                        width = "full"
                    },
                name = {
                    name = L["Name"] or "Name",
                    desc = L["Filter name"] or "Filter name",
                    type = "input",
                    width = "full",
                    order = 1,
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.name end,
                    set = function(_, value) 
                        filter.name = value
                        self:UpdateFilterOptions()
                    end
                },
                category = {
                    name = L["Category"] or "Category",
                    desc = L["Filter category"] or "Organize filters by category",
                    type = "input",
                    width = "full",
                    order = 2,
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.category or "General" end,
                    set = function(_, value) filter.category = value end
                },
                keywordHelp = {
                    name = "",
                    type = "description",
                    order = 3,
                    hidden = function() return filter.collapsed end,
                    width = "full",
                    fontSize = "medium",
                    image = "Interface\\Icons\\INV_Misc_Note_01",
                    imageWidth = 16,
                    imageHeight = 16,
                    name = L["Keyword Syntax Help"] or "Keyword Syntax Help:",
                    desc = L["Keyword Syntax Help Description"] or "Click to see examples of keyword syntax"
                },
                keywords = {
                    name = L["Keywords"] or "Keywords",
                    desc = L["Keywords Syntax Description"] or "Types de mots-clés:\n- Standard: mot1, mot2 (un seul suffit)\n- Requis: +mot1+, +mot2+ (tous nécessaires)\n- Groupe: &mot1 mot2& (tous les mots du groupe nécessaires)\n\nExemples:\n- wts, vend (correspond si 'wts' OU 'vend' est présent)\n- +wts+, +vend+ (correspond si 'wts' ET 'vend' sont présents)\n- &wts vend& (correspond si 'wts' ET 'vend' sont présents ensemble)",
                    type = "input",
                    width = "full",
                    order = 4,
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.keywords end,
                    set = function(_, value) filter.keywords = value end
                },
                keywordHelp = {
                    name = "",
                    type = "group",
                    inline = true,
                    order = 4.5,
                    hidden = function() return filter.collapsed end,
                    args = {
                        helpText = {
                            name = "|cffFFD700Keyword Syntax:|r\n\n" ..
                                   "|cff00FF00Standard:|r word1, word2 (ANY match)\n" ..
                                   "  Example: wts, vend - Matches 'WTS item' OR 'vending'\n\n" ..
                                   "|cffFF8800Required:|r +word1+, +word2+ (ALL required)\n" ..
                                   "  Example: +wts+, +epic+ - Matches ONLY if BOTH present\n\n" ..
                                   "|cff00BFFFGroup:|r &word1 word2& (ALL together)\n" ..
                                   "  Example: &boost mara& - Matches 'boost mara' phrase",
                            type = "description",
                            order = 1,
                            width = "full",
                            fontSize = "medium"
                        }
                    }
                },
                keywordButtons = {
                    name = "",
                    type = "group",
                    inline = true,
                    order = 5,
                    hidden = function() return filter.collapsed end,
                    width = "full",
                    args = {
                        standardHelp = {
                            name = L["Add Standard"] or "+ Standard",
                            desc = L["Add standard keyword"] or "Add a standard keyword (matches if ANY keyword present)",
                            type = "execute",
                            width = "normal",
                            order = 1,
                            func = function()
                                filter.keywords = filter.keywords .. (filter.keywords ~= "" and ", " or "") .. "keyword"
                            end
                        },
                        requiredHelp = {
                            name = L["Add Required"] or "+ Required",
                            desc = L["Add required keyword"] or "Add a required keyword (ALL required keywords must be present)",
                            type = "execute",
                            width = "normal",
                            order = 2,
                            func = function()
                                filter.keywords = filter.keywords .. (filter.keywords ~= "" and ", " or "") .. "+keyword+"
                            end
                        },
                        groupHelp = {
                            name = L["Add Group"] or "+ Group",
                            desc = L["Add keyword group"] or "Add a keyword group (ALL words in group must be present together)",
                            type = "execute",
                            width = "normal",
                            order = 3,
                            func = function()
                                filter.keywords = filter.keywords .. (filter.keywords ~= "" and ", " or "") .. "&word1 word2&"
                            end
                        }
                    }
                },
                keywordPreview = {
                    name = "",
                    type = "group",
                    inline = true,
                    order = 5,
                    width = "full",
                    args = {
                        previewButton = {
                            name = L["Preview"] or "Aperçu",
                            desc = L["Preview keywords"] or "Prévisualiser les mots-clés",
                            type = "execute",
                            width = 0.5,
                            order = 1,
                            func = function()
                                if addon.KeywordPreview then
                                    addon.KeywordPreview:PreviewKeywords(filter.keywords)
                                else
                                    print("Module KeywordPreview non disponible")
                                end
                            end
                        },
                        testButton = {
                            name = L["Test"] or "Tester",
                            desc = L["Test keywords against a sample message"] or "Tester les mots-clés avec un message exemple",
                            type = "execute",
                            width = 0.5,
                            order = 2,
                            func = function()
                                -- Create test dialog
                                StaticPopupDialogs["RSKCHATSCANNER_TEST_KEYWORDS"] = {
                                    text = L["Enter a test message"] or "Entrez un message de test :",
                                    button1 = L["Test"] or "Tester",
                                    button2 = L["Cancel"] or "Annuler",
                                    hasEditBox = true,
                                    maxLetters = 255,
                                    OnAccept = function(self)
                                        local message = self.editBox:GetText()
                                        if addon.KeywordPreview then
                                            addon.KeywordPreview:TestKeywords(filter.keywords, message)
                                        else
                                            print("Module KeywordPreview non disponible")
                                        end
                                    end,
                                    EditBoxOnEnterPressed = function(self)
                                        local parent = self:GetParent()
                                        local message = parent.editBox:GetText()
                                        if addon.KeywordPreview then
                                            addon.KeywordPreview:TestKeywords(filter.keywords, message)
                                        else
                                            print("Module KeywordPreview non disponible")
                                        end
                                        parent:Hide()
                                    end,
                                    timeout = 0,
                                    whileDead = true,
                                    hideOnEscape = true,
                                    preferredIndex = 3
                                }
                                StaticPopup_Show("RSKCHATSCANNER_TEST_KEYWORDS")
                            end
                        }
                    }
                },
                enabled = {
                    name = L["Enabled"] or "Enabled",
                    desc = L["Enable or disable this filter"] or "Enable or disable this filter",
                    type = "toggle",
                    order = 6,
                    width = "normal",
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.enabled end,
                    set = function(_, value) filter.enabled = value end
                },
                playSound = {
                    name = L["Play Sound"] or "Play Sound",
                    desc = L["Play sound for this filter"] or "Play sound when this filter matches",
                    type = "toggle",
                    order = 6.5,
                    width = "normal",
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.playSound ~= false end, -- Default to true
                    set = function(_, value) filter.playSound = value end
                },
                color = {
                    name = L["Color"] or "Color",
                    desc = L["Color for this filter"] or "Color for this filter",
                    type = "color",
                    order = 7,
                    width = "normal",
                    hidden = function() return filter.collapsed end,
                    get = function() return filter.color.r, filter.color.g, filter.color.b end,
                    set = function(_, r, g, b) 
                        filter.color.r = r
                        filter.color.g = g
                        filter.color.b = b
                    end
                },
                iconPicker = {
                    name = function()
                        local iconPath = filter.icon or "Interface\\Icons\\INV_Misc_Note_01"
                        return "|T" .. iconPath .. ":16:16|t Select Icon"
                    end,
                    desc = L["Click to open icon picker"] or "Click to open icon picker and choose from a variety of icons",
                    type = "execute",
                    order = 7.2,
                    width = "normal",
                    hidden = function() return filter.collapsed end,
                    func = function()
                        if addon.IconPicker then
                            addon.IconPicker:Show(filter.icon or "Interface\\Icons\\INV_Misc_Note_01", function(selectedIcon)
                                filter.icon = selectedIcon
                                -- Force refresh of the config UI
                                local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
                                AceConfigRegistry:NotifyChange("ChatScanner")
                            end)
                        end
                    end
                },
                spacerActions = {
                    name = "",
                    type = "description",
                    order = 7.5,
                    width = "full",
                    hidden = function() return filter.collapsed end
                },
                testFilter = {
                    name = L["Test"] or "Test",
                    desc = L["Test this filter"] or "Show a test notification for this filter",
                    type = "execute",
                    order = 8,
                    width = "half",
                    hidden = function() return filter.collapsed end,
                    func = function()
                        if addon.core and addon.core.TestFilterNotification then
                            addon.core:TestFilterNotification(filter.name)
                        else
                            print("Test notification not available")
                        end
                    end
                },
                deleteFilter = {
                    name = L["Delete"] or "|cffFF0000Delete Filter|r",
                    desc = L["Delete this filter"] or "Delete this filter permanently",
                    type = "execute",
                    order = 9,
                    width = "half",
                    hidden = function() return filter.collapsed end,
                    confirm = function()
                        return "Are you sure you want to delete the filter '" .. filter.name .. "'?\n\nThis action cannot be undone."
                    end,
                    func = function()
                        table.remove(filters, i)
                        self:UpdateFilterOptions()
                        print("|cff00ff00ChatScanner PRO:|r Filter '" .. filter.name .. "' deleted")
                    end
                }
                }
            }
        end
    end
end

-- Initialize config
function config:Initialize()
    -- Initialize database
    self:InitDB()
    
    -- Create options
    self.options = self:GetOptions()
    
    -- Update filter options
    self:UpdateFilterOptions()
    
    -- Update AutoFlood options
    self:UpdateAutoFloodOptions()
    
    -- Update Template options
    self:UpdateTemplateOptions()
    
    -- Initialize Minimap Button
    if addon.MinimapButton then
        addon.MinimapButton:Initialize()
    end
    
    -- Register options
    AceConfig:RegisterOptionsTable("ChatScanner", self.options)
    
    -- Create options panel
    self.optionsFrame = AceConfigDialog:AddToBlizOptions("ChatScanner", "ChatScanner PRO")
    
    -- Create LDB launcher
    self.ldb = LDB:NewDataObject("ChatScanner", {
        type = "launcher",
        text = "ChatScanner PRO",
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        OnClick = function(_, button)
            if button == "LeftButton" then
                if AceConfigDialog.OpenFrames["ChatScanner"] then
                    AceConfigDialog:Close("ChatScanner")
                else
                    AceConfigDialog:Open("ChatScanner")
                end
            elseif button == "RightButton" then
                self.db.profile.enabled = not self.db.profile.enabled
                print("|cff00ff00ChatScanner PRO:|r " .. (self.db.profile.enabled and "Enabled" or "Disabled"))
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("SuperRsk ChatScanner PRO")
            tooltip:AddLine("Left-click to open options")
            tooltip:AddLine("Right-click to enable/disable")
        end
    })
    
    -- Register minimap icon
    LDBIcon:Register(addonName, self.ldb, self.db.profile.minimap)
    
    -- Show/hide minimap icon based on settings
    if self.db.profile.minimap.hide then
        LDBIcon:Hide(addonName)
    else
        LDBIcon:Show(addonName)
    end
end
