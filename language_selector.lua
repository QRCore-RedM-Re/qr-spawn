-- ==================== LANGUAGE SELECTOR ====================
-- This script provides commands to change language for both qr-spawn and qr-multicharacter

-- Command to change language
RegisterCommand('setlang', function(source, args)
    if not args[1] then
        lib.notify({
            title = 'Language Selector',
            description = 'Usage: /setlang <language>\nAvailable: en, ar',
            type = 'info'
        })
        return
    end
    
    local newLang = args[1]:lower()
    local availableLanguages = {'en', 'ar'}
    
    -- Check if language is available
    local isValidLang = false
    for _, lang in ipairs(availableLanguages) do
        if lang == newLang then
            isValidLang = true
            break
        end
    end
    
    if not isValidLang then
        lib.notify({
            title = 'Invalid Language',
            description = 'Available languages: ' .. table.concat(availableLanguages, ', '),
            type = 'error'
        })
        return
    end
    
    -- Change language for both resources
    if ChangeLanguage then
        ChangeLanguage(newLang)
    end
    
    -- Notify user
    local langNames = {
        en = 'English',
        ar = 'العربية'
    }
    
    lib.notify({
        title = 'Language Changed',
        description = 'Language set to: ' .. (langNames[newLang] or newLang),
        type = 'success'
    })
    
    print(('[Language] Changed to: %s'):format(newLang))
end, false)

-- Command to show language menu
RegisterCommand('lang', function()
    local options = {
        {
            title = '🇺🇸 English',
            description = 'Change language to English',
            icon = 'language',
            iconColor = 'blue',
            onSelect = function()
                ExecuteCommand('setlang en')
            end
        },
        {
            title = '🇸🇦 العربية',
            description = 'تغيير اللغة إلى العربية',
            icon = 'language',
            iconColor = 'green',
            onSelect = function()
                ExecuteCommand('setlang ar')
            end
        },
        {
            title = 'ℹ️ Info',
            description = 'Current language: ' .. (GetCurrentLanguage and GetCurrentLanguage() or 'Unknown'),
            icon = 'info-circle',
            iconColor = 'gray',
            disabled = true
        }
    }
    
    lib.registerContext({
        id = 'language_selector',
        title = '🌐 Language Selection',
        options = options
    })
    
    lib.showContext('language_selector')
end, false)

-- Auto-detect browser language on first join (optional)
AddEventHandler('QRCore:Client:OnPlayerLoaded', function()
    -- This could be expanded to detect browser language
    -- For now, it uses the config default
end)
