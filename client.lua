-- ==================== QR-SPAWN CLIENT ====================

-- Variables
local choosingSpawn = false
local currentCamera = nil
local currentCamera2 = nil
local isResourceStarting = true
local QRCore = exports['qr-core']:GetCoreObject()

-- Forward declarations
local ShowLocationPreviewMenu
local ShowSpawnMenu

-- Debug print function for client
local function DebugPrint(message, debugType)
    if not Config.Debug.enabled then return end
    
    debugType = debugType or 'general'
    
    if debugType == 'client' and not Config.Debug.client then return end
    if debugType == 'events' and not Config.Debug.events then return end
    if debugType == 'performance' and not Config.Debug.performance then return end
    
    local timestamp = os.date('%H:%M:%S')
    print(string.format("^6[SPAWN DEBUG %s] [%s] %s^0", debugType:upper(), timestamp, message))
end

-- Cleanup cameras
local function CleanupCameras()
    DebugPrint("Cleaning up cameras", 'client')
    
    if DoesCamExist(currentCamera) then
        DestroyCam(currentCamera, true)
        currentCamera = nil
    end
    
    if DoesCamExist(currentCamera2) then
        DestroyCam(currentCamera2, true)
        currentCamera2 = nil
    end
    
    -- Ensure script cams are disabled
    RenderScriptCams(false, true, 500, true, true)
    
    -- Clear any cam interpolation
    if currentCamera then
        StopCamShaking(currentCamera, true)
    end
    
    -- Additional cleanup for resource restart
    if isResourceStarting then
        SetGameplayCamRelativeHeading(0.0)
        SetGameplayCamRelativePitch(0.0, 1.0)
    end
end

-- Cache cleanup function
local function ClearAllCache()
    DebugPrint("Clearing all cache and resetting state", 'client')
    
    -- Reset all variables to initial state
    choosingSpawn = false
    currentCamera = nil
    currentCamera2 = nil
    isResourceStarting = true
    
    -- Force cleanup any existing cameras
    CleanupCameras()
    
    -- Hide any open contexts
    if lib then
        lib.hideContext()
    end
    
    -- Reset player state but keep HIDDEN by default
    local playerPed = PlayerPedId()
    if DoesEntityExist(playerPed) then
        FreezeEntityPosition(playerPed, false)
        SetEntityVisible(playerPed, false)  -- Keep hidden by default
        SetEntityAlpha(playerPed, 0, false)  -- Stay invisible
        SetPlayerInvincible(PlayerId(), false)
    end
    
    -- Force disable script cams
    RenderScriptCams(false, false, 0, true, true)
    
    DebugPrint("Cache cleared successfully - Player remains hidden", 'client')
end

-- ==================== DEBUG FUNCTIONS ====================



-- Performance monitoring function for client
local function DebugPerformance(functionName, startTime)
    if not Config.Debug.enabled or not Config.Debug.performance then return end
    
    local endTime = GetGameTimer()
    local executionTime = endTime - startTime
    DebugPrint(string.format("%s executed in %dms", functionName, executionTime), 'performance')
end

-- ==================== UTILITY FUNCTIONS ====================



-- Create initial overview camera
local function CreateOverviewCamera(playerPos)
    DebugPrint("Creating overview camera", 'client')
    
    CleanupCameras()
    
    -- Create a more cinematic overview camera
    currentCamera = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA", 
        playerPos.x + 15.0,  -- Better offset for overview
        playerPos.y + 15.0, 
        playerPos.z + 25.0,  -- Higher for better overview
        -45.0, 0.0, 225.0,   -- Cinematic angle
        Config.Camera.FOV, 
        false, 0
    )
    
    -- Point at player position for context
    PointCamAtCoord(currentCamera, playerPos.x, playerPos.y, playerPos.z)
    SetCamActive(currentCamera, true)
    RenderScriptCams(true, false, 1500, true, true)  -- Smoother transition
end

-- Create location preview camera and keep menu open
local function CreateLocationCamera(coords, locationId)
    local startTime = GetGameTimer()
    DebugPrint(string.format("Creating location camera at %s", tostring(coords)), 'client')
    
    DoScreenFadeOut(300)
    Wait(500)
    
    -- Move player to location but keep HIDDEN for preview
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
    SetEntityVisible(PlayerPedId(), false)  -- Keep player HIDDEN during preview
    SetEntityAlpha(PlayerPedId(), 0, false)  -- Make completely invisible
    Wait(200)
    
    -- Cleanup existing cameras
    CleanupCameras()
    
    -- Create cinematic preview camera with better positioning
    local cameraOffset = {
        x = coords.x + math.cos(math.rad(45)) * 8.0,
        y = coords.y + math.sin(math.rad(45)) * 8.0,
        z = coords.z + 3.5
    }
    
    currentCamera = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA", 
        cameraOffset.x,
        cameraOffset.y,
        cameraOffset.z,
        -20.0, 0.0, 225.0,  -- Better cinematic angle
        45.0,  -- Tighter FOV for better preview
        false, 0
    )
    
    -- Point camera at the spawn location (not player since player is hidden)
    PointCamAtCoord(currentCamera, coords.x, coords.y, coords.z + 1.5)
    SetCamActive(currentCamera, true)
    RenderScriptCams(true, true, 1500, true, true)  -- Smoother transition
    
    DoScreenFadeIn(800)
    
    -- Show location menu with preview options after camera settles
    Wait(1000)
    ShowLocationPreviewMenu(locationId)
    
    DebugPerformance("CreateLocationCamera", startTime)
end

-- Build spawn location menu
local function BuildSpawnMenu()
    local startTime = GetGameTimer()
    DebugPrint("Building spawn location menu", 'client')
    
    local options = {}
    
    -- Add current location option with enhanced styling
    local PlayerData = QRCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.position then
        options[#options + 1] = {
            title = '🏠 ' .. Locale('spawn_menu_saved_location'),
            description = Locale('spawn_menu_saved_description'),
            icon = 'home',
            iconColor = 'green',
            onSelect = function()
                SpawnAtLocation('current')
            end
        }
        
        -- Add separator
        options[#options + 1] = {
            title = '━━━━━━━ ' .. Locale('spawn_menu_available_locations') .. ' ━━━━━━━',
            description = '',
            disabled = true
        }
    end
    
    -- Add configured spawn locations with better formatting
    for locationId, locationData in pairs(Config.Spawns) do
        options[#options + 1] = {
            title = '🗺️ ' .. locationData.label,
            description = (locationData.description or Locale('location_preview_description')),
            icon = 'map-pin',
            iconColor = 'blue',
            onSelect = function()
                -- Player will be moved but remain HIDDEN during preview
                CreateLocationCamera(locationData.coords, locationId)
            end,
            metadata = {
                {label = Locale('location_label'), value = locationData.label},
                {label = Locale('location_status'), value = Locale('location_available')}
            }
        }
    end
    
    DebugPerformance("BuildSpawnMenu", startTime)
    return options
end

-- Spawn player at selected location
function SpawnAtLocation(locationId)
    local startTime = GetGameTimer()
    DebugPrint(string.format("Spawning at location: %s", locationId), 'client')
    
    choosingSpawn = false
    lib.hideContext()
    
    DoScreenFadeOut(600)
    Wait(1200)
    
    -- Cleanup cameras first
    CleanupCameras()
    
    local PlayerData = QRCore.Functions.GetPlayerData()
    
    if locationId == 'current' and PlayerData and PlayerData.position then
        -- Spawn at last saved position
        SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
        SetEntityHeading(PlayerPedId(), PlayerData.position.w or 0.0)
        DebugPrint("Spawned at saved position", 'client')
    elseif Config.Spawns[locationId] then
        -- Spawn at configured location
        local coords = Config.Spawns[locationId].coords
        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
        SetEntityHeading(PlayerPedId(), coords.w or 0.0)
        DebugPrint(string.format("Spawned at %s", Config.Spawns[locationId].label), 'client')
    else
        DebugPrint(string.format("Unknown location: %s", locationId), 'client')
    end
    
    -- NOW show the player after successful spawn
    Wait(800)
    FreezeEntityPosition(PlayerPedId(), false)
    SetEntityVisible(PlayerPedId(), true)  -- NOW make player visible
    SetEntityAlpha(PlayerPedId(), 255, false)  -- Full opacity
    SetPlayerInvincible(PlayerId(), false)
    
    -- Trigger server events
    TriggerServerEvent('QRCore:Server:OnPlayerLoaded')
    TriggerEvent('QRCore:Client:OnPlayerLoaded')
    TriggerServerEvent("qr_appearance:LoadSkin")
    
    DoScreenFadeIn(800)
    
    -- Welcome message
    Wait(1000)
    lib.notify({
        title = 'مرحباً!',
        description = 'تم الرسبون بنجاح - أهلاً بك في اللعبة!',
        type = 'success',
        duration = 3000
    })
    
    DebugPerformance("SpawnAtLocation", startTime)
    DebugPrint("Spawn process completed successfully - Player is now visible", 'client')
end

-- Show spawn selection menu
ShowSpawnMenu = function()
    local startTime = GetGameTimer()
    DebugPrint("Showing spawn selection menu", 'client')
    
    lib.registerContext({
        id = 'qr_spawn_menu',
        title = '🌍 ' .. Locale('spawn_menu_title'),
        options = BuildSpawnMenu()
    })
    
    lib.showContext('qr_spawn_menu')
    DebugPerformance("ShowSpawnMenu", startTime)
end

-- Show location preview menu
ShowLocationPreviewMenu = function(selectedLocationId)
    local startTime = GetGameTimer()
    DebugPrint("Showing location preview menu", 'client')
    
    local locationData = Config.Spawns[selectedLocationId]
    local options = {}
    
    -- Main spawn option - prominently displayed
    options[#options + 1] = {
        title = '🏃‍♂️ ' .. Locale('spawn_here'),
        description = Locale('spawn_confirm_description', locationData and locationData.label or Locale('this_location')),
        icon = 'play-circle',
        iconColor = 'green',
        onSelect = function()
            SpawnAtLocation(selectedLocationId)
        end
    }
    
    -- Separator
    options[#options + 1] = {
        title = '━━━━━━━━━━━━━━━━━━━━━',
        description = '',
        disabled = true
    }
    
    -- Navigation options
    options[#options + 1] = {
        title = '🔙 ' .. Locale('spawn_back'),
        description = Locale('spawn_back_description'),
        icon = 'arrow-left',
        iconColor = 'blue',
        onSelect = function()
            -- Smooth transition back to overview
            DoScreenFadeOut(300)
            Wait(400)
            
            local PlayerData = QRCore.Functions.GetPlayerData()
            if PlayerData and PlayerData.position then
                -- Return to original position but KEEP PLAYER HIDDEN
                SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
                SetEntityVisible(PlayerPedId(), false)  -- Keep hidden
                SetEntityAlpha(PlayerPedId(), 0, false)  -- Stay invisible
                Wait(100)
                CreateOverviewCamera(PlayerData.position)
            end
            
            DoScreenFadeIn(600)
            Wait(700)
            ShowSpawnMenu()
        end
    }
    
    -- Quick current location spawn
    local PlayerData = QRCore.Functions.GetPlayerData()
    if PlayerData and PlayerData.position then
        options[#options + 1] = {
            title = '📍 الرسبون في الموقع المحفوظ',
            description = 'العودة إلى آخر موقع محفوظ وإظهار الشخصية',
            icon = 'bookmark',
            iconColor = 'orange',
            onSelect = function()
                SpawnAtLocation('current')
            end
        }
    end
    
    lib.registerContext({
        id = 'qr_spawn_preview',
        title = '📍 ' .. Locale('location_preview_title', locationData and locationData.label or Locale('unknown_location')),
        options = options
    })
    
    lib.showContext('qr_spawn_preview')
    DebugPerformance("ShowLocationPreviewMenu", startTime)
end

-- ==================== EVENT HANDLERS ====================

-- Open spawn UI
RegisterNetEvent('qr-spawn:client:openUI', function(value)
    local startTime = GetGameTimer()
    DebugPrint("Open spawn UI event received", 'events')
    
    if value then
        -- Ensure clean state before starting
        if isResourceStarting then
            ClearAllCache()
            Wait(500)
            isResourceStarting = false
        end
        
        choosingSpawn = true
        SetEntityVisible(PlayerPedId(), false)  -- Hide player from start
        SetEntityAlpha(PlayerPedId(), 0, false)  -- Make completely invisible
        
        DoScreenFadeOut(400)
        Wait(800)
        
        -- Get player data and create overview camera
        QRCore.Functions.GetPlayerData(function(PlayerData)
            if PlayerData and PlayerData.position then
                -- Move to position but keep hidden
                SetEntityCoords(PlayerPedId(), PlayerData.position.x, PlayerData.position.y, PlayerData.position.z)
                SetEntityVisible(PlayerPedId(), false)  -- Keep hidden
                SetEntityAlpha(PlayerPedId(), 0, false)  -- Stay invisible
                
                CreateOverviewCamera(PlayerData.position)
                
                -- Wait for camera to settle then show menu
                Wait(1000)
                DoScreenFadeIn(600)
                Wait(800)
                ShowSpawnMenu()
            end
        end)
        
        DebugPerformance("OpenSpawnUI", startTime)
    else
        choosingSpawn = false
        CleanupCameras()
        lib.hideContext()
        DebugPrint("Spawn UI closed", 'events')
    end
end)

-- Setup spawn UI (called from multicharacter)
RegisterNetEvent('qr-spawn:client:setupSpawnUI', function(characterData, isNewPlayer)
    DebugPrint(string.format("Setup spawn UI - New player: %s", tostring(isNewPlayer)), 'events')
    TriggerEvent('qr-spawn:client:openUI', true)
end)

-- ==================== EXPORTS ====================

-- Export functions for other resources
exports('openSpawnUI', function()
    TriggerEvent('qr-spawn:client:openUI', true)
end)

exports('isChoosingSpawn', function()
    return choosingSpawn
end)

exports('forceCleanup', function()
    CleanupCameras()
    choosingSpawn = false
    lib.hideContext()
end)

-- ==================== RESOURCE INITIALIZATION ====================

-- Disable controls while choosing spawn
CreateThread(function()
    while true do
        if choosingSpawn then
            DisableAllControlActions(0)
        else
            Wait(1000)
        end
        Wait(0)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("QR-Spawn stopping - performing full cleanup", 'client')
        ClearAllCache()
    end
end)

-- Cleanup on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DebugPrint("QR-Spawn starting - clearing any residual state", 'client')
        Wait(1000) -- Wait for other resources to load
        ClearAllCache()
        isResourceStarting = true
    end
end)

-- Clear cache command for admins
RegisterCommand('clearspawncache', function()
    if QRCore.Functions.GetPlayerData().job and QRCore.Functions.GetPlayerData().job.name == 'admin' then
        ClearAllCache()
        lib.notify({
            title = Locale('cache_cleared'),
            description = Locale('spawn_cache_success'),
            type = 'success'
        })
    end
end, false)

-- Initialize resource
CreateThread(function()
    -- Initial cleanup on resource start
    Wait(2000) -- Ensure everything is loaded
    ClearAllCache()
    isResourceStarting = true
    
    DebugPrint("QR-Spawn client initialized with clean state", 'client')
    print("^2[qr-spawn] Client initialized successfully^0")
    print("^2[qr-spawn] Version: 2.0.0 - ox_lib Integration^0")
    print("^2[qr-spawn] Cache cleared and ready for use^0")
end)
 