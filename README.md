# QR-Spawn v2.0.0

## 🎬 **Latest Update: Multi-Language System**

Complete rewrite of the spawn system with modern ox_lib context menus, comprehensive multi-language support, and professional debugging capabilities.

### ✨ **New Features:**
- **🧹 No More NUI**: Complete removal of HTML/CSS/JS files
- **📋 ox_lib Context Menus**: Professional, consistent UI experience
- **🌐 Multi-Language System**: English, Arabic, and extensible to more languages
- **🎯 Simplified Workflow**: Direct spawn selection with live preview
- **🔧 Debug System**: Comprehensive debugging capabilities with language support
- **⚡ Enhanced Performance**: Optimized camera system and transitions
- **📐 Configurable Camera**: All camera settings moved to config.lua
- **🎨 Dynamic Language Switching**: Change language in real-time without restart

### 🌍 **Language Support:**
- **English (en)** - Default language
- **Arabic (ar)** - Full RTL support
- **Extensible** - Easy to add new languages
- **Commands**: 
  - `/lang` - Open language selection menu
  - `/setlang <code>` - Change language directly (e.g., `/setlang ar`)

### 🛠️ **Dependencies:**
- `ox_lib` - Required for context menus
- `qr-core` - Core framework

### 📋 **Spawn Process:**
1. **Initial Overview**: Aerial camera view of current location
2. **Location Selection**: Choose from configured spawn points
3. **Live Preview**: See selected location before confirming
4. **Confirm Spawn**: Final confirmation before spawning

## Features
- Ability to select spawn after selecting the character

## Installation
### Manual
- Download the script and put it in the `[qr]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure qr-core
ensure qr-spawn
ensure qr-appearance
ensure qr-clothes
```

## Configuration

### Language Configuration
```lua
Config.Locale = {
    language = 'en', -- Default language ('en' for English, 'ar' for Arabic)
    availableLanguages = {'en', 'ar'}, -- Available languages
    fallbackLanguage = 'en', -- Fallback language if translation not found
}
```

### Spawn Locations
An example to add spawn option:
```lua
Config.Spawns = {
    ["spawn1"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn1", -- Needs to be unique
        label = "Spawn 1 Name", -- This is the label which will show up in selection menu
        description = "Description of this spawn location" -- Optional description
    },
    ["spawn2"] = { -- Needs to be unique
        coords = vector4(1.1, -1.1, 1.1, 180.0), -- Coords player will be spawned
        location = "spawn2", -- Needs to be unique
        label = "Spawn 2 Name", -- This is the label which will show up in selection menu
        description = "Description of this spawn location" -- Optional description
    },
}
```

### Debug Configuration
```lua
Config.Debug = {
    enabled = false, -- Enable/disable general debug
    client = false,  -- Enable/disable client debug messages  
    server = false,  -- Enable/disable server debug messages
    events = false,  -- Enable/disable event tracking
    performance = false, -- Enable/disable performance monitoring
}
```

## Commands

### Language Commands
- `/lang` - Opens language selection menu
- `/setlang <language>` - Changes language directly
  - Example: `/setlang ar` for Arabic
  - Example: `/setlang en` for English

### Admin Commands
- `/spawndebug` - Toggle spawn debug mode (admin only)
- `/clearspawncache` - Clear spawn cache (admin only)

## Adding New Languages

1. Create a new file in `locales/[language_code].lua`
2. Copy the structure from `locales/en.lua`
3. Translate all text strings
4. Add the language code to `Config.Locale.availableLanguages`
5. Restart the resource

Example language file structure:
```lua
local Translations = {
    ['spawn_menu_title'] = 'Your Translation Here',
    ['spawn_here'] = 'Your Translation Here',
    -- ... more translations
}

return Translations
```

## Development

### File Structure
```
qr-spawn/
├── locales/          # Language files
│   ├── en.lua        # English translations
│   ├── ar.lua        # Arabic translations
│   └── es.lua        # Spanish example
├── config.lua        # Main configuration
├── locale.lua        # Locale system
├── client.lua        # Client-side logic
├── server.lua        # Server-side logic
└── language_selector.lua # Language commands
```

### API Functions
```lua
-- Get localized text
local text = Locale('key_name')

-- Get localized text with parameters
local text = Locale('welcome_msg', playerName)

-- Change language programmatically
local success = ChangeLanguage('ar')

-- Get current language
local currentLang = GetCurrentLanguage()
```
