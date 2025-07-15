-- ==================== QR-SPAWN SERVER ====================

-- Core Object
local QRCore = exports['qr-core']:GetCoreObject()

-- ==================== DEBUG FUNCTIONS ====================

-- Debug print function
local function DebugPrint(message, debugType)
    if not Config.Debug.enabled then return end
    
    debugType = debugType or 'general'
    
    if debugType == 'server' and not Config.Debug.server then return end
    if debugType == 'events' and not Config.Debug.events then return end
    if debugType == 'performance' and not Config.Debug.performance then return end
    
    local timestamp = os.date('%H:%M:%S')
    print(string.format("^3[SPAWN DEBUG %s] [%s] %s^0", debugType:upper(), timestamp, message))
end

-- Performance monitoring function
local function DebugPerformance(functionName, startTime)
    if not Config.Debug.enabled or not Config.Debug.performance then return end
    
    local endTime = GetGameTimer()
    local executionTime = endTime - startTime
    DebugPrint(string.format("%s executed in %dms", functionName, executionTime), 'performance')
end

-- ==================== ADMIN COMMANDS ====================

-- Debug toggle command for admins
QRCore.Commands.Add("spawndebug", "Toggle Spawn Debug Mode", {
    {name = "type", help = "Debug type: all, client, server, events, performance"}
}, false, function(source, args)
    local playerName = GetPlayerName(source)
    local debugType = args[1] and string.lower(args[1]) or "all"
    
    if debugType == "all" then
        Config.Debug.enabled = not Config.Debug.enabled
        Config.Debug.client = Config.Debug.enabled
        Config.Debug.server = Config.Debug.enabled
        Config.Debug.events = Config.Debug.enabled
        Config.Debug.performance = Config.Debug.enabled
        
        TriggerClientEvent('QRCore:Notify', source, 
            string.format("Spawn Debug %s", Config.Debug.enabled and "تم التفعيل" or "تم التعطيل"), 
            Config.Debug.enabled and "success" or "error")
            
    elseif debugType == "client" then
        Config.Debug.client = not Config.Debug.client
        TriggerClientEvent('QRCore:Notify', source, 
            string.format("Client Debug %s", Config.Debug.client and "تم التفعيل" or "تم التعطيل"), 
            Config.Debug.client and "success" or "error")
            
    elseif debugType == "server" then
        Config.Debug.server = not Config.Debug.server
        TriggerClientEvent('QRCore:Notify', source, 
            string.format("Server Debug %s", Config.Debug.server and "تم التفعيل" or "تم التعطيل"), 
            Config.Debug.server and "success" or "error")
            
    elseif debugType == "events" then
        Config.Debug.events = not Config.Debug.events
        TriggerClientEvent('QRCore:Notify', source, 
            string.format("Events Debug %s", Config.Debug.events and "تم التفعيل" or "تم التعطيل"), 
            Config.Debug.events and "success" or "error")
            
    elseif debugType == "performance" then
        Config.Debug.performance = not Config.Debug.performance
        TriggerClientEvent('QRCore:Notify', source, 
            string.format("Performance Debug %s", Config.Debug.performance and "تم التفعيل" or "تم التعطيل"), 
            Config.Debug.performance and "success" or "error")
    else
        TriggerClientEvent('QRCore:Notify', source, "استخدم: all, client, server, events, performance", "error")
        return
    end
    
    print(string.format("^3[qr-spawn] %s toggled debug mode: %s^0", playerName, debugType))
    DebugPrint(string.format("Debug toggled by %s - Type: %s", playerName, debugType), 'events')
end, 'admin')

-- ==================== EVENT HANDLERS ====================

-- Player ready event (triggered when player is fully loaded)
RegisterNetEvent('QRCore:Server:OnPlayerLoaded', function()
    local source = source
    local playerName = GetPlayerName(source)
    
    DebugPrint(string.format("Player %s finished loading", playerName), 'events')
end)

-- ==================== CALLBACKS ====================

-- Get owned houses for player (legacy support)
QRCore.Functions.CreateCallback('qr-spawn:server:getOwnedHouses', function(source, cb, citizenid)
    local playerName = GetPlayerName(source)
    DebugPrint(string.format("getOwnedHouses callback requested by %s for citizen %s", playerName, citizenid or "unknown"), 'events')
    
    -- For now, return empty since houses might not be implemented
    -- This can be extended when house system is added
    cb({})
end)

-- ==================== RESOURCE INITIALIZATION ====================

-- Initialize resource
CreateThread(function()
    print("^2[qr-spawn] Server initialized successfully^0")
    print("^2[qr-spawn] Version: 2.0.0 - ox_lib Integration^0")
    
    -- Display debug status
    if Config.Debug.enabled then
        print("^3[qr-spawn] Debug Mode: ENABLED^0")
        if Config.Debug.server then print("^3[qr-spawn] - Server Debug: ON^0") end
        if Config.Debug.events then print("^3[qr-spawn] - Events Debug: ON^0") end
        if Config.Debug.performance then print("^3[qr-spawn] - Performance Debug: ON^0") end
        print("^3[qr-spawn] Use /spawndebug command to toggle debug modes^0")
    else
        print("^3[qr-spawn] Debug Mode: DISABLED (use /spawndebug to enable)^0")
    end
    
    DebugPrint("QR-Spawn server initialized", 'server')
end)