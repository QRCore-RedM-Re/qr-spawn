-- ==================== QR-SPAWN CONFIG ====================
Config = {}

-- ==================== LOCALIZATION SETTINGS ====================
Config.Locale = {
    language = 'en', -- Default language ('en' for English, 'ar' for Arabic)
    availableLanguages = {'en', 'ar'}, -- Available languages
    fallbackLanguage = 'en', -- Fallback language if selected language is not available
}

-- ==================== DEBUG SETTINGS ====================
-- لتفعيل الديبوق: استخدم الأمر /spawndebug في اللعبة
-- أو قم بتغيير القيم هنا وإعادة تشغيل المورد
Config.Debug = {
    enabled = false, -- تفعيل/تعطيل الديبوق العام
    client = false,  -- تفعيل/تعطيل رسائل الديبوق للكلاينت
    server = false,  -- تفعيل/تعطيل رسائل الديبوق للسيرفر
    events = false,  -- تفعيل/تعطيل تتبع الأحداث
    performance = false, -- تفعيل/تعطيل مراقبة الأداء
}

-- ==================== GENERAL SETTINGS ====================
-- Enable spawning inside houses from the spawn selector
Config.EnableHouses = false

-- Enable spawning inside apartments from the spawn selector
Config.EnableApartments = false

-- ==================== CAMERA SETTINGS ====================
Config.Camera = {
    Height1 = 50,    -- First camera height (reasonable height)
    Height2 = 10,    -- Second camera height (close view)
    PointHeight1 = 5,    -- First point camera height
    PointHeight2 = 0,    -- Second point camera height
    TransitionTime1 = 500,  -- First transition time
    TransitionTime2 = 1000, -- Second transition time
    FOV = 50.0,      -- Field of view (good for preview)
}

-- ==================== SPAWN LOCATIONS ====================
Config.Spawns = {
    ["emerald"] = {
        coords = vector4(1417.818, 268.0298, 89.61942, 144.5),
        location = "emerald",
        label = "Emerald Ranch Fence",
        description = "موقع مزرعة إيمرالد"
    },
    ["rhodes"] = {
        coords = vector4(1247.5914, -1291.584, 74.944152, 301.54714),
        location = "rhodes",
        label = "Rhodes",
        description = "مدينة رودز"
    },
    ["saintdenis"] = {
        coords = vector4(2570.54, -1183.36, 53.90, 1.93),
        location = "saintdenis",
        label = "Saint Denis",
        description = "مدينة سانت دينيس"
    },
    ["valentine"] = {
        coords = vector4(-366.75, 725.43, 115.47, 351.991),
        location = "valentine",
        label = "Valentine",
        description = "مدينة فالنتين"
    }
}

-- Legacy support (will be removed in future versions)
QR = Config
