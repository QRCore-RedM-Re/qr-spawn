-- ==================== QR-SPAWN LOCALE SYSTEM ====================
local Locales = {}
local CurrentLocale = {}

-- Load available translations
local function LoadTranslations()
    local availableLanguages = Config.Locale.availableLanguages or {'en'}
    
    for _, lang in ipairs(availableLanguages) do
        local success, translations = pcall(function()
            return require('locales.' .. lang)
        end)
        
        if success and translations then
            Locales[lang] = translations
            if Config.Debug.enabled then
                print(('[QR-Spawn] Loaded %d translations for language: %s'):format(
                    #table.keys(translations), lang
                ))
            end
        else
            print(('[QR-Spawn] Failed to load translations for language: %s'):format(lang))
        end
    end
end

-- Set current locale
local function SetLocale(language)
    local targetLanguage = language or Config.Locale.language or 'en'
    
    if Locales[targetLanguage] then
        CurrentLocale = Locales[targetLanguage]
        if Config.Debug.enabled then
            print(('[QR-Spawn] Locale set to: %s'):format(targetLanguage))
        end
    else
        -- Fallback to default language
        local fallback = Config.Locale.fallbackLanguage or 'en'
        if Locales[fallback] then
            CurrentLocale = Locales[fallback]
            print(('[QR-Spawn] Language %s not found, using fallback: %s'):format(targetLanguage, fallback))
        else
            print(('[QR-Spawn] ERROR: Neither target language %s nor fallback %s found!'):format(targetLanguage, fallback))
            CurrentLocale = {}
        end
    end
end

-- Get localized string with optional formatting
function Locale(key, ...)
    if not CurrentLocale or not CurrentLocale[key] then
        if Config.Debug.enabled then
            print(('[QR-Spawn] Missing translation for key: %s'):format(key))
        end
        return key -- Return the key itself if translation not found
    end
    
    local text = CurrentLocale[key]
    local args = {...}
    
    if #args > 0 then
        return text:format(table.unpack(args))
    else
        return text
    end
end

-- Get all available languages
function GetAvailableLanguages()
    return Config.Locale.availableLanguages or {'en'}
end

-- Get current language
function GetCurrentLanguage()
    return Config.Locale.language or 'en'
end

-- Change language dynamically
function ChangeLanguage(newLanguage)
    if not newLanguage then return false end
    
    if Locales[newLanguage] then
        Config.Locale.language = newLanguage
        SetLocale(newLanguage)
        return true
    else
        if Config.Debug.enabled then
            print(('[QR-Spawn] Language %s not available'):format(newLanguage))
        end
        return false
    end
end

-- Initialize locale system
CreateThread(function()
    Wait(100) -- Wait for config to load
    LoadTranslations()
    SetLocale(Config.Locale.language)
    
    if Config.Debug.enabled then
        print('[QR-Spawn] Locale system initialized')
        print(('Available languages: %s'):format(table.concat(GetAvailableLanguages(), ', ')))
        print(('Current language: %s'):format(GetCurrentLanguage()))
    end
end)

-- Helper function to get table keys count
function table.keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end
