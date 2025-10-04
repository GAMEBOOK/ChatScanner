-- RskChatScanner Media
local addonName, addon = ...

-- Initialize media
addon.Media = {}
local media = addon.Media

-- Register media with SharedMedia (with fallback if missing)
local LSM = LibStub("LibSharedMedia-3.0", true) or {}

-- Add fallback methods if library is missing
if not LSM.Register then
    LSM.Register = function() end
end

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

-- Register bar textures (using default WoW textures)
LSM:Register("statusbar", "RskChatScanner Smooth", [[Interface\TargetingFrame\UI-StatusBar]])
LSM:Register("statusbar", "RskChatScanner Glaze", [[Interface\Buttons\UI-Panel-Button-Up]])
LSM:Register("statusbar", "RskChatScanner Charcoal", [[Interface\DialogFrame\UI-DialogBox-Background]])

-- Register fonts (using default WoW fonts)
LSM:Register("font", "RskChatScanner Expressway", [[Fonts\FRIZQT__.TTF]])
LSM:Register("font", "RskChatScanner Friz Quadrata TT", [[Fonts\FRIZQT__.TTF]])

-- Register sounds (using default WoW sounds)
LSM:Register("sound", "RskChatScanner Ping", [[Sound\Interface\iTellMessage.ogg]])
LSM:Register("sound", "RskChatScanner Alert", [[Sound\Interface\RaidWarning.ogg]])
LSM:Register("sound", "RskChatScanner Info", [[Sound\Interface\ReadyCheck.ogg]])

-- Define default media
media.DefaultBarTexture = "RskChatScanner Smooth"
media.DefaultFont = "RskChatScanner Expressway"
media.DefaultSound = "RskChatScanner Ping"

-- Define colors
media.colors = {
    red = {1, 0.2, 0.2},
    green = {0.2, 1, 0.2},
    blue = {0.2, 0.6, 1},
    orange = {1, 0.6, 0},
    yellow = {1, 1, 0.2},
    purple = {0.8, 0.2, 1},
    cyan = {0, 1, 1},
    white = {1, 1, 1},
    gray = {0.7, 0.7, 0.7},
    darkGray = {0.3, 0.3, 0.3},
    black = {0, 0, 0}
}

-- Get color by name
function media:GetColor(name)
    return unpack(self.colors[name] or self.colors.white)
end

-- Get color as hex
function media:GetHexColor(name)
    local r, g, b = self:GetColor(name)
    return string.format("|cff%02x%02x%02x", r*255, g*255, b*255)
end
