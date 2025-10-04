-- ChatScanner PRO Icon Picker
local addonName, addon = ...

addon.IconPicker = {}
local iconPicker = addon.IconPicker

local AceGUI = LibStub("AceGUI-3.0")

-- Common WoW icons list (Classic doesn't have GetNumMacroIcons)
local iconList = {
    -- General & Misc
    "Interface\\Icons\\INV_Misc_Note_01",
    "Interface\\Icons\\INV_Misc_Note_02",
    "Interface\\Icons\\INV_Misc_Note_03",
    "Interface\\Icons\\INV_Misc_Note_04",
    "Interface\\Icons\\INV_Misc_QuestionMark",
    "Interface\\Icons\\Ability_Warrior_BattleShout",
    "Interface\\Icons\\INV_Misc_Coin_01",
    "Interface\\Icons\\INV_Misc_Coin_02",
    "Interface\\Icons\\INV_Misc_Coin_03",
    "Interface\\Icons\\INV_Misc_Coin_04",
    "Interface\\Icons\\INV_Misc_Coin_05",
    "Interface\\Icons\\INV_Misc_GroupLooking",
    "Interface\\Icons\\INV_Bannerpvp_02",
    "Interface\\Icons\\Achievement_Guild_ClassyRaid",
    "Interface\\Icons\\INV_Misc_Bell_01",
    "Interface\\Icons\\Spell_Holy_SealOfMight",
    "Interface\\Icons\\INV_Misc_Bag_08",
    "Interface\\Icons\\INV_Misc_Book_09",
    "Interface\\Icons\\INV_Misc_Map_01",
    "Interface\\Icons\\INV_Misc_Spyglass_02",
    "Interface\\Icons\\INV_Misc_PocketWatch_01",
    "Interface\\Icons\\INV_Misc_Rune_01",
    "Interface\\Icons\\Spell_Nature_Lightning",
    "Interface\\Icons\\Spell_Fire_FlameBolt",
    "Interface\\Icons\\Spell_Frost_FrostBolt02",
    "Interface\\Icons\\Spell_Shadow_ShadowBolt",
    "Interface\\Icons\\Spell_Holy_HolyBolt",
    "Interface\\Icons\\Spell_Arcane_ArcaneTorrent",
    
    -- Professions
    "Interface\\Icons\\Trade_Alchemy",
    "Interface\\Icons\\Trade_BlackSmithing",
    "Interface\\Icons\\Trade_Engineering",
    "Interface\\Icons\\Trade_Engraving",
    "Interface\\Icons\\INV_Misc_Gem_01",
    "Interface\\Icons\\INV_Misc_Gem_02",
    "Interface\\Icons\\INV_Misc_Gem_03",
    "Interface\\Icons\\Trade_LeatherWorking",
    "Interface\\Icons\\Trade_Tailoring",
    "Interface\\Icons\\Trade_Herbalism",
    "Interface\\Icons\\Trade_Mining",
    "Interface\\Icons\\INV_Misc_Food_15",
    "Interface\\Icons\\Trade_Fishing",
    "Interface\\Icons\\INV_Misc_ArmorKit_17",
    "Interface\\Icons\\Trade_BrewPoison",
    "Interface\\Icons\\INV_Misc_Herb_07",
    "Interface\\Icons\\INV_Ore_Mithril_01",
    "Interface\\Icons\\INV_Fabric_Silk_02",
    "Interface\\Icons\\INV_Misc_LeatherScrap_07",
    
    -- Weapons
    "Interface\\Icons\\INV_Sword_04",
    "Interface\\Icons\\INV_Sword_27",
    "Interface\\Icons\\INV_Sword_62",
    "Interface\\Icons\\INV_Axe_09",
    "Interface\\Icons\\INV_Hammer_05",
    "Interface\\Icons\\INV_Mace_01",
    "Interface\\Icons\\INV_Staff_13",
    "Interface\\Icons\\INV_Weapon_Bow_07",
    "Interface\\Icons\\INV_Weapon_Crossbow_07",
    "Interface\\Icons\\INV_Weapon_Rifle_07",
    "Interface\\Icons\\INV_ThrowingKnife_04",
    "Interface\\Icons\\INV_Wand_07",
    
    -- Armor
    "Interface\\Icons\\INV_Shield_06",
    "Interface\\Icons\\INV_Chest_Plate01",
    "Interface\\Icons\\INV_Helmet_03",
    "Interface\\Icons\\INV_Boots_Plate_01",
    "Interface\\Icons\\INV_Gauntlets_04",
    "Interface\\Icons\\INV_Pants_03",
    "Interface\\Icons\\INV_Shoulder_02",
    "Interface\\Icons\\INV_Belt_03",
    "Interface\\Icons\\INV_Bracer_07",
    "Interface\\Icons\\INV_Chest_Cloth_17",
    "Interface\\Icons\\INV_Chest_Leather_08",
    "Interface\\Icons\\INV_Chest_Chain_03",
    
    -- Consumables
    "Interface\\Icons\\INV_Potion_54",
    "Interface\\Icons\\INV_Potion_53",
    "Interface\\Icons\\INV_Potion_52",
    "Interface\\Icons\\INV_Potion_51",
    "Interface\\Icons\\INV_Scroll_03",
    "Interface\\Icons\\INV_Misc_Food_59",
    "Interface\\Icons\\INV_Drink_05",
    "Interface\\Icons\\INV_Misc_Food_19",
    "Interface\\Icons\\INV_Drink_10",
    "Interface\\Icons\\Spell_Holy_FlashHeal",
    "Interface\\Icons\\Spell_Frost_FrostArmor02",
    "Interface\\Icons\\Spell_Shadow_UnholyFrenzy",
    
    -- Gems & Enchants
    "Interface\\Icons\\INV_Misc_Gem_Variety_01",
    "Interface\\Icons\\INV_Enchant_EssenceAstralLarge",
    "Interface\\Icons\\INV_Enchant_EssenceEternalLarge",
    "Interface\\Icons\\INV_Enchant_EssenceMagicLarge",
    "Interface\\Icons\\INV_Enchant_EssenceMysticalLarge",
    "Interface\\Icons\\INV_Enchant_EssenceNetherLarge",
    "Interface\\Icons\\INV_Enchant_ShardBrilliantLarge",
    
    -- Activities & Dungeons
    "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01",
    "Interface\\Icons\\Achievement_Boss_Ragnaros",
    "Interface\\Icons\\Achievement_Boss_Onyxia",
    "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",
    "Interface\\Icons\\Achievement_Dungeon_GloryoftheRaider",
    "Interface\\Icons\\INV_Misc_Key_03",
    "Interface\\Icons\\INV_Misc_Key_06",
    "Interface\\Icons\\INV_Misc_Key_09",
    "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
    "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
    
    -- PvP
    "Interface\\Icons\\Achievement_BG_winAB",
    "Interface\\Icons\\Achievement_BG_winWSG",
    "Interface\\Icons\\Achievement_BG_winAV",
    "Interface\\Icons\\Achievement_Arena_2v2_1",
    "Interface\\Icons\\Achievement_Arena_3v3_1",
    "Interface\\Icons\\Achievement_Arena_5v5_1",
    "Interface\\Icons\\INV_BannerPVP_01",
    "Interface\\Icons\\INV_BannerPVP_03",
    "Interface\\Icons\\Ability_Warrior_WarCry",
    "Interface\\Icons\\Ability_Warrior_Challange",
    
    -- Quests & Achievements
    "Interface\\Icons\\INV_Misc_Map_01",
    "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
    "Interface\\Icons\\Achievement_Quests_Completed_08",
    "Interface\\Icons\\Achievement_Character_Human_Male",
    "Interface\\Icons\\Achievement_Character_Orc_Male",
    "Interface\\Icons\\Achievement_Character_Undead_Male",
    "Interface\\Icons\\Achievement_Character_Tauren_Male",
    "Interface\\Icons\\Achievement_Character_Troll_Male",
    "Interface\\Icons\\Achievement_Character_Gnome_Male",
    "Interface\\Icons\\Achievement_Character_Dwarf_Male",
    "Interface\\Icons\\Achievement_Character_Nightelf_Male",
    
    -- Class Icons
    "Interface\\Icons\\ClassIcon_Warrior",
    "Interface\\Icons\\ClassIcon_Paladin",
    "Interface\\Icons\\ClassIcon_Hunter",
    "Interface\\Icons\\ClassIcon_Rogue",
    "Interface\\Icons\\ClassIcon_Priest",
    "Interface\\Icons\\ClassIcon_Shaman",
    "Interface\\Icons\\ClassIcon_Mage",
    "Interface\\Icons\\ClassIcon_Warlock",
    "Interface\\Icons\\ClassIcon_Druid",
    
    -- Mounts & Pets
    "Interface\\Icons\\Ability_Mount_RidingHorse",
    "Interface\\Icons\\Ability_Mount_WhiteTiger",
    "Interface\\Icons\\Ability_Mount_Kodo_01",
    "Interface\\Icons\\Ability_Mount_Raptor",
    "Interface\\Icons\\Ability_Mount_Undeadhorse",
    "Interface\\Icons\\Ability_Mount_MechaStrider",
    "Interface\\Icons\\Ability_Mount_Gryphon_01",
    "Interface\\Icons\\Ability_Mount_Wyvern_01",
    "Interface\\Icons\\INV_Misc_Rabbit",
    "Interface\\Icons\\INV_Box_PetCarrier_01",
    
    -- Special
    "Interface\\Icons\\Spell_Nature_Polymorph",
    "Interface\\Icons\\Spell_Magic_PolymorphChicken",
    "Interface\\Icons\\Ability_Seal",
    "Interface\\Icons\\INV_Valentinescandy",
    "Interface\\Icons\\INV_Misc_Gift_01",
    "Interface\\Icons\\INV_Misc_Bomb_05",
    "Interface\\Icons\\INV_Misc_Bandage_20",
    "Interface\\Icons\\INV_Misc_Rope_01",
    "Interface\\Icons\\INV_Misc_Lantern_01",
    "Interface\\Icons\\INV_Misc_Toy_01",
}

-- Create icon picker frame
local pickerFrame = nil
local selectedIcon = nil
local callback = nil

function iconPicker:Show(currentIcon, callbackFunc)
    selectedIcon = currentIcon
    callback = callbackFunc
    
    if not pickerFrame then
        self:CreateFrame()
    else
        self:UpdateContent()
    end
    
    pickerFrame:Show()
end

function iconPicker:CreateFrame()
    -- Create AceGUI Frame
    local frame = AceGUI:Create("Frame")
    frame:SetTitle("|cffFFD700Select Icon|r (" .. #iconList .. " icons)")
    frame:SetWidth(600)
    frame:SetHeight(750) -- Increased height so bottom Close button is always visible
    frame:SetLayout("Flow")
    
    -- Disable the default close button (X)
    if frame.closebutton then
        frame.closebutton:Hide()
    end
    if frame.frame and frame.frame.closebutton then
        frame.frame.closebutton:Hide()
    end
    
    frame:SetCallback("OnClose", function(widget)
        -- Clean up custom buttons before releasing
        if frame.iconButtons then
            for _, btn in ipairs(frame.iconButtons) do
                if btn.Hide then 
                    btn:Hide()
                    btn:SetParent(nil)
                end
            end
            wipe(frame.iconButtons)
        end
        AceGUI:Release(widget)
        pickerFrame = nil
    end)
    
    -- Preview group
    local previewGroup = AceGUI:Create("SimpleGroup")
    previewGroup:SetFullWidth(true)
    previewGroup:SetLayout("Flow")
    frame:AddChild(previewGroup)
    
    -- Preview icon
    local preview = AceGUI:Create("Label")
    preview:SetText("|T" .. selectedIcon .. ":64:64|t")
    preview:SetFullWidth(true)
    previewGroup:AddChild(preview)
    frame.preview = preview
    
    -- Search box and close button group
    local searchGroup = AceGUI:Create("SimpleGroup")
    searchGroup:SetFullWidth(true)
    searchGroup:SetLayout("Flow")
    frame:AddChild(searchGroup)
    
    -- Search box
    local searchBox = AceGUI:Create("EditBox")
    searchBox:SetLabel("Search")
    searchBox:SetWidth(400)
    searchBox:SetCallback("OnTextChanged", function(widget, event, text)
        iconPicker:FilterIcons(frame, text)
    end)
    searchGroup:AddChild(searchBox)
    frame.searchBox = searchBox
    
    -- Close button
    local closeBtn = AceGUI:Create("Button")
    closeBtn:SetText("|cffFF0000Close|r")
    closeBtn:SetWidth(150)
    closeBtn:SetCallback("OnClick", function()
        frame:Hide()
    end)
    searchGroup:AddChild(closeBtn)
    
    -- Icon count label
    local countLabel = AceGUI:Create("Label")
    countLabel:SetText("Showing all icons")
    countLabel:SetFullWidth(true)
    frame:AddChild(countLabel)
    frame.countLabel = countLabel
    
    -- Custom scroll frame for icon grid
    local scrollContainer = AceGUI:Create("InlineGroup")
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetHeight(520)
    scrollContainer:SetLayout("Fill")
    frame:AddChild(scrollContainer)
    
    -- Create custom scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, scrollContainer.content, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, 0)
    scrollFrame:SetPoint("BOTTOMRIGHT", -20, 0)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(scrollFrame:GetWidth() or 550)
    
    frame.scrollFrame = scrollFrame
    frame.scrollChild = scrollChild
    frame.iconButtons = {}
    frame.iconsPerRow = 10
    
    pickerFrame = frame
    
    -- Load initial icons
    self:FilterIcons(frame, "")
end

function iconPicker:UpdateContent()
    if not pickerFrame then return end
    
    -- Update preview
    pickerFrame.preview:SetText("|T" .. selectedIcon .. ":64:64|t")
    pickerFrame.pathLabel:SetText(selectedIcon)
    
    self:UpdateSelection(pickerFrame)
end

function iconPicker:FilterIcons(frame, searchText)
    if not frame or not frame.scrollChild then return end
    
    -- Clear existing buttons properly
    for _, btn in ipairs(frame.iconButtons) do
        if btn.Hide then 
            btn:Hide()
            btn:SetParent(nil)
        end
    end
    wipe(frame.iconButtons)
    
    searchText = searchText and searchText:lower() or ""
    local count = 0
    local maxDisplay = 200
    
    local iconSize = 48
    local iconSpacing = 4
    local iconsPerRow = frame.iconsPerRow or 10
    local row = 0
    local col = 0
    
    -- Filter and display icons
    for _, iconPath in ipairs(iconList) do
        if count >= maxDisplay then break end
        
        -- Check if icon matches search
        if searchText == "" or iconPath:lower():find(searchText, 1, true) then
            -- Create button
            local btn = CreateFrame("Button", nil, frame.scrollChild)
            btn:SetSize(iconSize, iconSize)
            btn:SetPoint("TOPLEFT", frame.scrollChild, "TOPLEFT", 
                col * (iconSize + iconSpacing) + 5, 
                -row * (iconSize + iconSpacing) - 5)
            
            -- Background
            btn.bg = btn:CreateTexture(nil, "BACKGROUND")
            btn.bg:SetAllPoints()
            btn.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
            
            -- Icon texture
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetSize(iconSize - 4, iconSize - 4)
            btn.icon:SetPoint("CENTER")
            btn.icon:SetTexture(iconPath)
            
            btn.iconPath = iconPath
            
            btn:SetScript("OnEnter", function(self)
                self.bg:SetColorTexture(0.4, 0.4, 0.4, 1)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:AddLine(iconPath, 1, 1, 1)
                GameTooltip:AddLine("Click to select", 0.5, 1, 0.5)
                GameTooltip:Show()
            end)
            
            btn:SetScript("OnLeave", function(self)
                self.bg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
                GameTooltip:Hide()
            end)
            
            btn:SetScript("OnClick", function(self)
                selectedIcon = iconPath
                frame.preview:SetText("|T" .. iconPath .. ":64:64|t")
                
                -- Auto-save and close on icon click
                if callback then
                    callback(iconPath)
                end
                frame:Hide()
            end)
            
            table.insert(frame.iconButtons, btn)
            count = count + 1
            
            -- Update grid position
            col = col + 1
            if col >= iconsPerRow then
                col = 0
                row = row + 1
            end
        end
    end
    
    -- Set scroll child height based on rows
    local totalRows = math.ceil(count / iconsPerRow)
    frame.scrollChild:SetHeight(totalRows * (iconSize + iconSpacing) + 20)
    
    -- Update count label
    if searchText == "" then
        frame.countLabel:SetText("Showing " .. count .. " icons (max 200)")
    else
        frame.countLabel:SetText("Found " .. count .. " icons matching '" .. searchText .. "'")
    end
end

function iconPicker:UpdateSelection(frame)
    if not frame or not frame.iconButtons then return end
    
    -- AceGUI Icon widgets don't support SetHighlight
    -- Selection is shown in the preview instead
end
