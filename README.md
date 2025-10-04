# ChatScanner PRO

![WoW Version](https://img.shields.io/badge/WoW-Classic%20%7C%20Cata%20%7C%20MoP%20%7C%20Retail-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Advanced Chat Monitoring for World of Warcraft

**ChatScanner PRO** is a powerful chat monitoring addon for WoW Classic, Cataclysm, Mists of Pandaria, and Retail. Never miss a trade, group, or important message again with smart keyword filtering, real-time notifications, and advanced automation features.

---

## Features

### Smart Keyword Filtering
- **3 Filter Types**: Standard (ANY match), Required (ALL match), Groups (phrase match)
- **Custom Icons**: Choose from 170+ icons or use the visual icon picker
- **Color Coding**: Assign unique colors to each filter for instant recognition
- **Enable/Disable**: Toggle filters on the fly without deleting them
- **Reorder Filters**: Move filters up/down to prioritize them

### Real-Time Notifications
- **Player Info Display**: Level, class (with icon & color), guild name
- **4 Action Buttons**: Reply, Invite, Copy message, Ignore player
- **Customizable Appearance**: Font, size, opacity, fade animations
- **Pause on Hover**: Notifications pause when you hover over them
- **Smart Positioning**: Auto-stacks up to 100 notifications
- **Duration Control**: 5-120 seconds (or until clicked)

### Auto Messages
- **Automated Broadcasting**: Send messages at regular intervals
- **Message Rotation**: Multiple messages rotate automatically
- **Channel Selection**: Say, Yell, Party, Guild, Trade, LFG, General
- **Dynamic Variables**: {name}, {level}, {class}, {zone}, {time}, {guild}
- **Enable/Disable**: Control each message independently

### Quick Replies
- **Predefined Templates**: Create response templates for common questions
- **One-Click Replies**: Right-click Reply button to use templates
- **Variable Support**: Use dynamic variables in your templates
- **Organize & Reorder**: Manage templates with Up/Down buttons

### Match History & Statistics
- **Complete History**: Up to 2000 entries with timestamps
- **Search & Filter**: By player name, filter, or channel
- **Statistics Dashboard**: Matches per filter (today/week/total)
- **Most Active Filter**: See which filter catches the most
- **Direct Contact**: Whisper players directly from history

### Blacklist System
- **Temporary Ignore**: 1 hour, 24 hours, or forever
- **Auto-Close Notifications**: Blacklisted players' notifications close instantly
- **Future Blocking**: Prevents future messages from ignored players
- **Manage List**: View and remove blacklisted players anytime

### Additional Features
- **Anti-Spam Filter**: Ignores duplicate messages within 5 seconds
- **Dynamic Channel Detection**: Auto-detects Trade, LFG, General channels
- **Minimap Button**: Quick access to settings (draggable, hideable)
- **Quick Control Menu**: Portable modal for fast toggles
- **Multi-Version Support**: Works on Classic Era, Cata, MoP, and Retail
- **Fully Localized**: English and French support

---

## Installation

### Method 1: WowUp (Recommended)
1. Download and install [WowUp](https://wowup.io/)
2. Search for "ChatScanner PRO"
3. Click Install
4. Done!

### Method 2: Manual
1. Download the latest release from [Releases](https://github.com/GAMEBOOK/ChatScanner/releases)
2. Extract the `SuperRsk_ChatScanner` folder
3. Place it in `World of Warcraft\_retail_\Interface\AddOns\` (or `_classic_era_`, `_cata_`, `_mop_`)
4. Restart WoW or type `/reload`

---

## Quick Start Guide

### 1. Create Your First Filter
1. Type `/chatscanner` or `/cs` to open settings
2. Go to **Keyword Filters** tab
3. Click **+ Add New Filter**
4. Name it (e.g., "WTS Items")
5. Add keywords: `wts, selling, vend`
6. Choose a color (e.g., Gold)
7. Click **Select Icon** to choose an icon
8. Enable the filter
9. Done!

### 2. Configure Channels
1. Go to **Chat Channels** tab
2. Enable channels to monitor:
   - Trade Chat
   - LFG Channel
   - General Chat
   - Guild Chat
   - etc.

### 3. Test Your Filter
1. Expand your filter
2. Click **Test Filter**
3. Enter a test message: "WTS [Epic Mount]"
4. See if it matches!

### 4. Customize Notifications
1. Go to **Notification Settings** tab
2. Adjust:
   - Font & Size
   - Duration (5-120 seconds)
   - Opacity & Fade animations
   - Max notifications on screen
   - Sound alerts

---

## Keyword Syntax

ChatScanner PRO supports 3 types of keywords for precise filtering:

### Standard Keywords (ANY match)
```
wts, selling, vend
```
Matches if **ANY** keyword is present.

**Example:**
- Message: "WTS [Epic Mount]" → **MATCH** (contains "wts")
- Message: "Selling cheap mats" → **MATCH** (contains "selling")
- Message: "LF tank" → **NO MATCH**

### Required Keywords (ALL match)
```
+wts+, +epic+
```
Matches **ONLY** if **ALL** required keywords are present.

**Example:**
- Message: "WTS epic mount" → **MATCH** (both "wts" and "epic")
- Message: "WTS rare mount" → **NO MATCH** (missing "epic")
- Message: "epic mount for sale" → **NO MATCH** (missing "wts")

### Keyword Groups (phrase match)
```
&boost mara&
```
Matches if **ALL** words in the group are present together.

**Example:**
- Message: "boost mara 30-40" → **MATCH**
- Message: "mara boost ready" → **MATCH**
- Message: "boost available" → **NO MATCH** (missing "mara")
- Message: "mara run" → **NO MATCH** (missing "boost")

### Combining Syntaxes
```
+wts+, &epic mount&, rare
```
Matches if:
- "wts" is present **AND**
- "epic" **AND** "mount" are together **OR**
- "rare" is present

---

## Commands

| Command | Description |
|---------|-------------|
| `/chatscanner` or `/cs` | Open settings |
| `/cs toggle` | Enable/disable scanner |
| `/cs menu` | Open quick control menu |
| `/cs history` | Open match history |
| `/cs test` | Test notification |

---

## Auto Messages Variables

Use these variables in your auto messages and quick replies:

| Variable | Output |
|----------|--------|
| `{name}` | Your character name |
| `{level}` | Your level |
| `{class}` | Your class name |
| `{coloredclass}` | Your class name with color |
| `{zone}` | Current zone |
| `{time}` | Current game time |
| `{guild}` | Your guild name |

**Example:**
```
WTS services! Whisper {name} - Level {level} {coloredclass}
```
Output: `WTS services! Whisper Ragnar - Level 60 Warrior`

---

## Screenshots

### Main Settings
![Settings Overview](/.github/screenshots/settings.png)

### Keyword Filters
![Keyword Filters - Collapsed View](/.github/screenshots/keyword_filter_collapsed.png)
*Collapsed view with quick controls: Expand, Enable/Disable, Up/Down buttons*

![Keyword Filters - Expanded View](/.github/screenshots/keyword_filter_expand.png)
*Full filter configuration with icon picker, color selection, and keyword syntax*

### Real-Time Notifications
![Notification Bar](/.github/screenshots/bar.png)
*Smart notification with player info and action buttons*

![Notification Tooltip](/.github/screenshots/bar2.png)
*Hover tooltip showing full message and player details*

![Notification Settings](/.github/screenshots/notifications.png)
*Customize appearance, duration, and behavior*

### Auto Messages
![Auto Messages - Collapsed](/.github/screenshots/autoflood.png)
*Quick controls for auto messages*

![Auto Messages - Expanded](/.github/screenshots/autoflood_expand.png)
*Full configuration with channel selection and variables*

### Quick Replies
![Quick Reply Templates](/.github/screenshots/autoreply-template.png)
*Predefined response templates for common questions*

### Match History
![Match History & Statistics](/.github/screenshots/history.png)
*Complete history with search, filters, and statistics dashboard*

### Blacklist System
![Blacklist Management](/.github/screenshots/blacklist.png)
*Manage ignored players with temporary or permanent blocks*

### Chat Channels
![Channel Selection](/.github/screenshots/channels.png)
*Choose which channels to monitor*

### Help & Documentation
![In-Game Help](/.github/screenshots/help.png)
*Comprehensive in-game documentation and tips*

---

## FAQ

**Q: Does this work on all WoW versions?**
A: Yes! Classic Era, Cataclysm, Mists of Pandaria, and Retail are all supported.

**Q: Will I get banned for using this?**
A: No. This addon only reads chat and displays notifications. It doesn't automate gameplay.

**Q: Can I use this for boosting/trading?**
A: Absolutely! It's perfect for monitoring trade chat and LFG.

**Q: How many filters can I create?**
A: Unlimited! Create as many as you need.

**Q: Can I backup my settings?**
A: Yes! Your settings are saved in `WTF\Account\YourAccount\SavedVariables\SuperRsk_ChatScanner.lua`

---

## Support & Feedback

- **Issues**: [GitHub Issues](https://github.com/GAMEBOOK/ChatScanner/issues)
- **Suggestions**: Open an issue with the "enhancement" label
- **Discord**: [Join our Discord](https://discord.gg/rt385DXRUp)

---

## Changelog

### v1.0.0 (2025-01-04)
- Initial release
- Smart keyword filtering (Standard, Required, Groups)
- Real-time notifications with player info
- Auto messages with rotation
- Quick reply templates
- Match history (up to 2000 entries)
- Blacklist system
- Icon picker (170+ icons)
- Multi-version support (Classic, Cata, MoP, Retail)
- Full localization (EN/FR)

---

## Credits

- **Author**: SuperRsk
- **Libraries**: Ace3, LibSharedMedia-3.0, LibDBIcon-1.0
- **Inspired by**: WeakAuras, BigWigs

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

**Enjoy ChatScanner PRO!** If you find it useful, please star the repo and share it with your guild! ⭐
