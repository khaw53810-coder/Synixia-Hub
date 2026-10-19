local _miss = {}
local getgenv = getgenv or function() table.insert(_miss, "getgenv") return _G end
local clonefunction = clonefunction or function(f) table.insert(_miss, "clonefunction") return f end
local replaceclosure = replaceclosure or function(a, b) table.insert(_miss, "replaceclosure") end
local checkcaller = checkcaller or function() table.insert(_miss, "checkcaller") return false end
local firesignal = firesignal or function() table.insert(_miss, "firesignal") end
local getconstants = getconstants or function() table.insert(_miss, "getconstants") return {} end
local getupvalue = getupvalue or function() table.insert(_miss, "getupvalue") return setmetatable({}, { __index = function() return {} end }) end
local setclipboard = setclipboard or function() table.insert(_miss, "setclipboard") end
if not game:IsLoaded() then
    game.Loaded:Wait()
end

if not (function()
    local API_URL = "https://synixipro.vercel.app/api/key-check"

    local PROJECT_SLUG = "YOUR_PROJECT_SLUG"
    local LICENSE_KEY = "PASTE_LICENSE_KEY_HERE"
    local HWID_OVERRIDE = ""

    local HttpService = game:GetService("HttpService")

    local envOk, env = pcall(getgenv)
    if envOk and type(env) == "table" then

        if type(env.Key) == "string" and env.Key ~= "" then
            LICENSE_KEY = env.Key
        elseif type(env.LICENSE_KEY) == "string" and env.LICENSE_KEY ~= "" then
            LICENSE_KEY = env.LICENSE_KEY
        end
        if type(env.PROJECT_SLUG) == "string" and env.PROJECT_SLUG ~= "" then
            PROJECT_SLUG = env.PROJECT_SLUG
        end
    end

    local function getHwid()
        if HWID_OVERRIDE ~= "" then
            return HWID_OVERRIDE
        end
        local okEnv, sharedEnv = pcall(function()
            if type(getgenv) == "function" then
                return getgenv()
            end
            return _G
        end)
        if okEnv and type(sharedEnv) == "table" and sharedEnv.HWID ~= nil then
            local configured = tostring(sharedEnv.HWID)
            if configured ~= "" then
                return configured
            end
        end
        local okClientId, clientId = pcall(function()
            return game:GetService("RbxAnalyticsService"):GetClientId()
        end)
        if okClientId and clientId ~= nil and tostring(clientId) ~= "" then
            return tostring(clientId)
        end
        error("หา HWID ไม่ได้: กำหนด HWID_OVERRIDE หรือ getgenv().HWID ก่อน")
    end

    local function findRequestFunction()
        if type(syn) == "table" and type(syn.request) == "function" then
            return syn.request
        end
        if type(http) == "table" and type(http.request) == "function" then
            return http.request
        end
        if type(http_request) == "function" then
            return http_request
        end
        if type(request) == "function" then
            return request
        end
        return nil
    end

    local function checkKey()
        if PROJECT_SLUG == "" or PROJECT_SLUG == "YOUR_PROJECT_SLUG" then
            return false, { valid = false, code = "CONFIG_PROJECT_SLUG" }
        end
        if LICENSE_KEY == "" or LICENSE_KEY == "PASTE_LICENSE_KEY_HERE" then
            return false, { valid = false, code = "CONFIG_LICENSE_KEY" }
        end

        local okHwid, hwidOrError = pcall(getHwid)
        if not okHwid then
            return false, { valid = false, code = "HWID_ERROR", message = tostring(hwidOrError) }
        end

        local payload = HttpService:JSONEncode({
            projectSlug = PROJECT_SLUG,
            key = LICENSE_KEY,
            hwid = hwidOrError,
        })
        local requestOptions = {
            Url = API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = payload,
        }

        local sendRequest = findRequestFunction()
        local okRequest, response = pcall(function()
            if sendRequest then
                return sendRequest(requestOptions)
            end
            return HttpService:RequestAsync(requestOptions)
        end)
        if not okRequest then
            return false, { valid = false, code = "NETWORK_ERROR", message = tostring(response) }
        end

        local responseBody
        if type(response) == "string" then
            responseBody = response
        elseif type(response) == "table" then
            responseBody = response.Body or response.body or response.ResponseBody or response.responseBody
        end
        if type(responseBody) ~= "string" or responseBody == "" then
            return false, { valid = false, code = "EMPTY_RESPONSE" }
        end

        local okDecode, result = pcall(function()
            return HttpService:JSONDecode(responseBody)
        end)
        if not okDecode or type(result) ~= "table" then
            return false, { valid = false, code = "INVALID_RESPONSE", message = tostring(responseBody):sub(1, 300) }
        end

        return result.valid == true, result
    end

    local valid, result = checkKey()
    if valid then
        print("[Wumi Key Check] VALID")
        if result.expiresAt then
            print("[Wumi Key Check] Expires at: " .. tostring(result.expiresAt))
        else
            print("[Wumi Key Check] Permanent key")
        end

        task.spawn(function()
            local INTERVAL = 300
            local softCodes = { NETWORK_ERROR = true, EMPTY_RESPONSE = true, INVALID_RESPONSE = true }
            while true do
                task.wait(INTERVAL + math.random(0, 30))
                local okCall, stillValid, res = pcall(checkKey)
                if okCall and stillValid ~= true and type(res) == "table" and not softCodes[res.code or ""] then
                    warn("[Wumi Key Check] Key revoked/invalid: " .. tostring(res.code or "UNKNOWN"))
                    pcall(function()
                        local g = getgenv()
                        for k, v in pairs(g) do
                            if v == true then g[k] = false end
                        end
                        g.StopTween = true
                    end)
                    pcall(function()
                        game:GetService("Players").LocalPlayer:Kick("[Key] License invalid or revoked: " .. tostring(res.code or "UNKNOWN"))
                    end)
                    break
                end
            end
        end)
        return true
    end

    warn("[Wumi Key Check] NOT VALID: " .. tostring(result.code or "UNKNOWN"))
    if result.message then
        warn("[Wumi Key Check] " .. tostring(result.message))
    end
    return false
end)() then
    return
end


local u135 = getgenv()
if not u135.LOADED then
    local new, new2, new3, new4, spawn, wait2, delay, cancel, floor, min, max, find, getupvalue, getconstants, HttpService2, PathfindingService, ReplicatedStorage, RunService2, UserInputService, Players, TeleportService, Lighting, Debris, PlaceId2, JobId2, LocalPlayer2, UserId, PlayerGui, u177, n14, t24, t25, t26, t27, u187, u188, u189, u190, u191, Items, Tiles, Terrain, Camera, Vehicles, CharacterCreator, SplashScreen, SteakhouseCook, DroppedItem, ItemUtils, Sprint, ATM, ProgressBar, ShelfStocking, StockTimes, JobData, SkillsList, Vehicle, Net, Char, Util, Tween, Data, u222, u223, u227, u228, u229, u230, u231, u232, send, get, tween, DeathScreenHolder, set, u240, u241, Backpack, u262, u263, u264, u265, elapsed, t34, t35, u282, u287, t47, u296, v297, v298, v299, v300, v301, v302, v303, v304, u306, u307
    do
        local fromOffset, ceil, SoundService, Map, DoorClient
        do
            local v193, v194
            do
                do
                    do
                        do
                            do
                                do
                                    do
                                        do
                                            do
                                                do
                                                    u135.LOADED = true
                                                    fromOffset = UDim2.fromOffset
                                                end
                                                new = Instance.new
                                                new2 = Vector2.new
                                                new3 = CFrame.new
                                            end
                                            new4 = Vector3.new
                                        end
                                    end
                                    spawn = task.spawn
                                    wait2 = task.wait
                                    delay = task.delay
                                    cancel = task.cancel
                                end
                                floor = math.floor
                                min = math.min
                                max = math.max
                                ceil = math.ceil
                            end
                        end
                        find = string.find
                        getupvalue = debug.getupvalue
                    end
                    getconstants = debug.getconstants
                end
                if not clonefunction then
                    clonefunction = function(p47) return p47 end
                end
                if not replaceclosure then
                    replaceclosure = hookfunction
                end
                HttpService2 = game:GetService("HttpService")
                PathfindingService = game:GetService("PathfindingService")
                ReplicatedStorage = game:GetService("ReplicatedStorage")
                RunService2 = game:GetService("RunService")
                UserInputService = game:GetService("UserInputService")
                Players = game:GetService("Players")
                TeleportService = game:GetService("TeleportService")
                Lighting = game:GetService("Lighting")
                SoundService = game:GetService("SoundService")
                Debris = game:GetService("Debris")
                PlaceId2 = game.PlaceId
                JobId2 = game.JobId
                LocalPlayer2 = Players.LocalPlayer
                UserId = LocalPlayer2.UserId
                LocalPlayer2:WaitForChild("Backpack")
                PlayerGui = LocalPlayer2:WaitForChild("PlayerGui")
                u177 = nil
                n14 = 1
                t24 = {
                    JumpDown = false,
                    SavedHistoryCFrame = nil,
                    TargetAim = nil,
                    TargetHistory = {},
                    AllATM = {},
                    AllDrawing = {
                        AllPlayerDrawing = {},
                        AllDroppedItemDrawing = {},
                        AllDrawingObject = {}
                    },
                    HackChip = nil,
                    MovementSpoof = false,
                    StaminaFarm = false,
                    SnapSuccess = false,
                    Panic = false,
                    HackToolChip = "Smart Select",
                    EncodedTable = {},
                    ConstantsToFind = { getfenv = false, identifyexecutor = false },
                    Blacklisted_Network_Calls = {
                        replicate_billboard_gui = true,
                        replicate_stamina_bar = true,
                        invalid_entry = true
                    },
                    Anticheat_Detection_Types = {
                        ["Teleport detected"] = true,
                        ["Anti noclip triggered"] = true,
                        ["Fly detected"] = true
                    },
                    RarityColors = {
                        Common = Color3.fromRGB(255, 255, 255),
                        Uncommon = Color3.fromRGB(99, 255, 52),
                        Rare = Color3.fromRGB(51, 170, 255),
                        Epic = Color3.fromRGB(237, 44, 255),
                        Legendary = Color3.fromRGB(255, 150, 0),
                        Omega = Color3.fromRGB(255, 20, 51)
                    },
                    BestPosOfATM = {
                        new3(114.510314941410002, 254.193786621089998, 463.861450195309999),
                        new3(999.558776855470001, 254.245147705080001, -639.6962890625),
                        new3(178.983795166020002, 254.343780517580001, -238.212112426760001),
                        new3(-225.106323242190001, 254.193786621089998, 486.381042480470001),
                        new3(-595.686462402339998, 257.043762207029999, -160.084503173830001),
                        new3(-508.29281616211, 255.500610351559999, 187.788665771479998),
                        new3(-131.892761230470001, 254.151245117190001, 102.139976501459998),
                        new3(99.604286193847997, 254.243774414059999, -572.444274902339998),
                        new3(-200.45555114746, 254.293823242190001, -568.751281738279999),
                        new3(-156.497467041020002, 254.126159667970001, 438.128021240229998),
                        new3(-198.167709350590002, 254.34375, -250.771911621089998),
                        new3(452.832336425779999, 254.793762207029999, 34.578086853027003),
                        new3(834.473571777339998, 254.242126464839998, -163.430130004879999),
                        new3(85.536895751952997, 254.343780517580001, 166.733291625980002)
                    },
                    BlockedNodePositions = {
                        { Size = new4(3.062, 10.603, 2.066), Position = new4(-206.167, 256.606, -513.868) },
                        { Size = new4(3.062, 10.603, 3.066), Position = new4(-216.601, 256.606, -513.368) },
                        { Size = new4(3.787, 23.93, 13.992), Position = new4(-245.512, 263.305, -437.676) },
                        { Size = new4(16.923, 10.274, 2.507), Position = new4(935.625, 256.137, -552.628) },
                        { Size = new4(0.808, 10.961, 6.401), Position = new4(-138.623, 256.612, 188.294) },
                        { Size = new4(14.904, 24.004, 20.496), Position = new4(-95.403, 262.777, 530.404) },
                        { Size = new4(15, 9.693, 15.285), Position = new4(65.543, 255.097, 397.31) },
                        { Size = new4(7.111, 16.594, 29.929), Position = new4(855.223, 259.297, -169.371) },
                        { Size = new4(2, 40, 150), Position = new4(-502.861, 251.052, 160.236) },
                        { Size = new4(2, 40, 150), Position = new4(-563, 257, 129) },
                        { Size = new4(21.61, 29.176, 16.516), Position = new4(-186.702, 265.445, -239.501) },
                        { Size = new4(10.461, 23.671, 28.489), Position = new4(-134.682, 259.237, 322.806) },
                        { Size = new4(11.007, 25.039, 7.443), Position = new4(87.996, 263.573, 160.548) },
                        { Size = new4(25.706, 14.869, 7.542), Position = new4(-482.11, 259.728, 147.729) },
                        { Size = new4(7.706, 14.869, 7.542), Position = new4(-489.09, 259.728, 159.865) },
                        { Size = new4(7.706, 14.869, 6.542), Position = new4(-496.319, 259.728, 172.435) },
                        { Size = new4(7.706, 14.869, 5.542), Position = new4(-503.548, 259.728, 185.004) },
                        { Size = new4(10.125, 3.089, 9.516), Position = new4(53.69, 256.475, -505.232) },
                        { Size = new4(10.125, 3.089, 53.639), Position = new4(53.69, 256.475, -543.525) },
                        { Size = new4(10.125, 2.089, 10.386), Position = new4(175.985, 256.475, -505.805) },
                        { Size = new4(10.125, 2.089, 52.413), Position = new4(175.985, 256.475, -543.795) }
                    },
                    JobPositions = {
                        Steak1 = new4(-228.423171999999994, 255.251801, 330.278656000000012),
                        Steak2 = new4(-230.680832000000009, 256.501099000000011, 330.690674000000001),
                        Steak3 = new4(-279.599639892580001, 256.349029541020002, 342.250610351559999),
                        ShelfStockApply = new4(133.074203000000011, 255.315063000000009, 208.376404900000011),
                        ShelfStock2 = new4(96.049629199999998, 255.467148000000009, 207.029494999999997),
                        JanitorApply = new4(111.83196258545, 255.359588623050001, -310.617767333979998)
                    },
                    HackToolList = {
                        { Tool = "HackToolBasic", Skill = "HackTool_Basic" },
                        { Tool = "HackToolPro", Skill = "HackTool_Pro" },
                        { Tool = "HackToolUltimate", Skill = "HackTool_Ultimate" },
                        { Tool = "HackToolQuantum", Skill = "HackTool_Quantum" }
                    },
                    ToolHashes = {},
                    AutoShotFiring = false
                }
                t25 = {}
                t26 = {}
                t27 = {}
                local v183 = workspace:GetAttribute("HashKey") or "default"
                for _, v in next, {
                    "damage","speed","range","cone_angle","ragdoll_chance","destructive","knockback_force","weapon_type","durability_mod","damage_type","Description","ImageId","RarityName","RarityPrice","Durability","DisplayName","Locked","CanCrouch","DisableInVehicle","ItemGUID","fire_rate","accuracy","MagSize","AmmoType","reload_time","automatic","Recoil","Multishot","SingleLoad","ReloadMultiplierOffset","KnockbackForce","RagdollChance","BulletSpeed","Zoom","SniperScope","throw_speed","Destructive","Weak","Explodes","explode_damage","ExplodeRadius","ExplodeDelay","ExplodeKnockback","AreaDamage","AreaDamageRadius","AreaDamageAmount","AreaDamageLength","Bounces","CanPour","LeavesProp","ThrowDebounceTime","HealthRestoreAmount","StaminaRestoreAmount","EffectDuration","SpeedMultiplier","StaminaConsumeMultiplier","DamageTakenMultiplier","HealthRegenMultiplier","MopCashPercentageIncrease","MopSpeedPercentageIncrease","FishingItem","FishRewardBias","Power","MaxDistance","MaxFresh","MinFresh","MaxWeight","MinWeight","FarmItem","IsCookable","Health","PedalingEnabled","PreRigged","DoesWheelie","SpeedometerEnabled","JumpPower","IgnoreDisableTools","BlastProtection","cosmetic_type","cosmetic_folder_origin_name","OptionColor","ImageColor","DoNotReplicateChildren","JobTool","UnequipWhenRagdolling"
                } do
                    local v186 = v183 .. (function(p49)
                        local n15 = 5381
                        for i = 1, #p49 do
                            n15 = (n15 * 5 + n15 + string.byte(p49, i)) % 4294967295
                        end
                        return tostring(n15)
                    end)(v)
                    t24.EncodedTable[v] = v186
                end
                u187 = nil
                u188 = nil
                u189 = nil
                u190 = nil
                u191 = nil
                local Modules = ReplicatedStorage:FindFirstChild("Modules")
                v193 = Modules and Modules:FindFirstChild("Game")
                v194 = Modules and Modules:FindFirstChild("Core")
            end
            Items = ReplicatedStorage:FindFirstChild("Items")
            Map = workspace:FindFirstChild("Map")
            Tiles = Map:WaitForChild("Tiles")
            Terrain = workspace:FindFirstChild("Terrain")
            Camera = workspace:FindFirstChild("Camera")
            Vehicles = workspace:FindFirstChild("Vehicles")
            require(v193.ItemCustomization.UpdateCosmetics)
            require(v193.ItemCustomization.ValidCosmeticTypes)
            CharacterCreator = require(v193.CharacterCreator.CharacterCreator)
            SplashScreen = require(v193.SplashScreen)
            SteakhouseCook = require(v193.Jobs.SteakhouseCook)
            require(v193.Inventory.Recovery)
            DroppedItem = require(v193.DroppedItem)
            require(v193.UI.BuyPromptUI)
            ItemUtils = require(v193.Inventory.ItemUtils)
            local Hotbar = require(v193.Inventory.Hotbar)
            Sprint = require(v193.Sprint)
            ATM = require(v193.ATM.ATM)
            DoorClient = require(v193.DoorClient)
            local Ragdoll = require(v193.Ragdoll)
            ProgressBar = require(v193.UI.ProgressBar)
            local SliderMinigame = require(v193.Minigames.SliderMinigame)
            local FishingRodModule = nil
            pcall(function() FishingRodModule = require(v193.ItemTypes.FishingRod) end)
            ShelfStocking = require(v193.Jobs.ShelfStocking)
            StockTimes = require(v193.StockTimes)
            JobData = require(v193.Jobs.JobData)
            SkillsList = require(v193.Skills.SkillsList)
            require(v193.Home.Home)
            Vehicle = require(v193.VehicleSystem.Vehicle)
            Net = require(v194.Net)
            Char = require(v194.Char)
            Util = require(v194.Util)
            Tween = require(v194.Tween)
            Data = require(v194.Data)
            u222 = new("BindableEvent")
            u223 = false
            local TopRightHud = PlayerGui:WaitForChild("TopRightHud")
            if TopRightHud then
                TopRightHud:WaitForChild("Holder")
            end
            for _, v in next, getconnections(LocalPlayer2.Idled) do
                if not v.Disable then
                    if v.Disconnect then v:Disconnect() end
                else
                    v:Disable()
                end
            end
            t24.WaitForPing = function()
                local NetworkPing = LocalPlayer2:GetNetworkPing()
                return wait2(max(0.2, NetworkPing * 2))
            end
            t24.Connect = function(p50, p51) return (p50:Connect(p51)) end
            t24.AddThread = function(p52, p53)
                if p52 then
                    return function()
                        while wait2(p53) do
                            xpcall(p52, warn)
                        end
                    end
                end
            end
            t24.IsAlive = function(p54)
                if p54 then
                    local Humanoid = p54:FindFirstChildOfClass("Humanoid")
                    if Humanoid then return Humanoid.Health > 0 end
                    return
                end
            end
            t24.IsBehindWall = function(p55, p56)
                if p55 and p56 then
                    local t29 = {}
                    if u189 then table.insert(t29, u189) end
                    local TargetAim = t24.TargetAim
                    if TargetAim then table.insert(t29, TargetAim) end
                    local raycastParams = RaycastParams.new()
                    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                    raycastParams.FilterDescendantsInstances = t29
                    return workspace:Raycast(p55, p56 - p55, raycastParams) ~= nil
                end
            end
            t24.GetDistanceRoot = function(p57)
                if typeof(p57) ~= "Instance" then
                    if typeof(p57) ~= "Vector3" then
                        if typeof(p57) ~= "CFrame" then return 0 end
                        return (p57.Position - u190.Position).Magnitude
                    end
                    return (p57 - u190.Position).Magnitude
                end
                if not p57:IsA("BasePart") then
                    if not p57:IsA("Model") then return 0 end
                    return (p57:GetPivot().Position - u190.Position).Magnitude
                end
                return (p57.Position - u190.Position).Magnitude
            end
            t24.GetDistanceStart = function(p58, p59)
                if typeof(p58) ~= "Vector3" or typeof(p59) ~= "Vector3" then
                    if typeof(p58) ~= "Vector2" or typeof(p59) ~= "Vector2" then return math.huge end
                    return (p58 - p59).Magnitude
                end
                return (p58 - p59).Magnitude
            end
            t24.FindClosest = function(p60, p61, p62, p63)
                if p60 and p61 and p62 then
                    if typeof(p60) == "table" then
                        local v577 = nil
                        local huge = math.huge
                        for _, v in next, p60 do
                            local vPosition = nil
                            local v582 = typeof(v)
                            if v582 ~= "Instance" then
                                if v582 ~= "CFrame" then
                                    if v582 ~= "Vector3" then
                                        if v582 == "table" and v.Position then vPosition = v.Position end
                                    else vPosition = v end
                                else vPosition = v.Position end
                            elseif not v:IsA("BasePart") then
                                if not v:IsA("Model") then
                                    local u583 = v:FindFirstAncestorOfClass("Model") or v:FindFirstAncestorOfClass("BasePart")
                                    if u583 then
                                        if not u583:IsA("BasePart") then
                                            local ok, result = pcall(function() return u583:GetPivot().Position end)
                                            if ok then vPosition = result end
                                        else vPosition = u583.Position end
                                    end
                                else
                                    local ok, result = pcall(function() return v:GetPivot().Position end)
                                    if ok then vPosition = result end
                                end
                            else vPosition = v.Position end
                            if vPosition and p61(v) then
                                local Magnitude = (vPosition - p62).Magnitude
                                if Magnitude < (typeof(p63) == "number" and p63 or huge) then
                                    huge = Magnitude
                                    v577 = v
                                end
                            end
                        end
                        return v577
                    end
                    return
                end
            end
            t24.WorldToScreen = function(p64)
                local v590 = typeof(p64) == "Instance" and p64.Position or p64
                return Camera:WorldToViewportPoint(v590)
            end
            t24.HopServer = function(p65)
                local u592 = p65 or 1
                local t30 = {}
                local s10 = ""
                local hour = os.date("!*t").hour
                if not pcall(function()
                    t30 = HttpService2:JSONDecode(readfile("YenixHopServer.json"))
                end) then
                    table.insert(t30, hour)
                    writefile("YenixHopServer.json", HttpService2:JSONEncode(t30))
                end
                local function u596()
                    local data
                    if s10 ~= "" then
                        data = HttpService2:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId2 .. "/servers/Public?sortOrder=Asc&limit=100&cursor=" .. s10))
                    else
                        data = HttpService2:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceId2 .. "/servers/Public?sortOrder=Asc&limit=100"))
                    end
                    local s11 = ""
                    if data.nextPageCursor and data.nextPageCursor ~= "null" and data.nextPageCursor ~= nil then
                        s10 = data.nextPageCursor
                    end
                    local n16 = 0
                    for _, v in pairs(data.data) do
                        local v1164 = true
                        s11 = tostring(v.id)
                        if u592 ~= 1 then
                            if tonumber(v.players) < 5 then
                                for _, v4 in pairs(t30) do
                                    if n16 == 0 then
                                        if tonumber(hour) ~= tonumber(v4) then
                                            pcall(function()
                                                delfile("YenixHopServer.json")
                                                t30 = {}
                                                table.insert(t30, hour)
                                            end)
                                        end
                                    elseif s11 == tostring(v4) then v1164 = false end
                                    n16 = n16 + 1
                                end
                                if v1164 == true then
                                    table.insert(t30, s11)
                                    wait2()
                                    pcall(function()
                                        writefile("YenixHopServer.json", HttpService2:JSONEncode(t30))
                                        wait2()
                                        TeleportService:TeleportToPlaceInstance(PlaceId2, s11, game.Players.LocalPlayer)
                                    end)
                                    wait2(4)
                                end
                            end
                        elseif tonumber(v.maxPlayers) > tonumber(v.playing) then
                            for _, v5 in pairs(t30) do
                                if n16 == 0 then
                                    if tonumber(hour) ~= tonumber(v5) then
                                        pcall(function()
                                            delfile("YenixHopServer.json")
                                            t30 = {}
                                            table.insert(t30, hour)
                                        end)
                                    end
                                elseif s11 == tostring(v5) then v1164 = false end
                                n16 = n16 + 1
                            end
                            if v1164 == true then
                                table.insert(t30, s11)
                                wait2()
                                pcall(function()
                                    writefile("YenixHopServer.json", HttpService2:JSONEncode(t30))
                                    wait()
                                    TeleportService:TeleportToPlaceInstance(PlaceId2, s11, game.Players.LocalPlayer)
                                end)
                                wait2(4)
                            end
                        end
                    end
                end
                while wait2() do
                    pcall(function()
                        u596()
                        if s10 ~= "" then u596() end
                    end)
                end
            end
            t24.GetItemRarity = function(p66)
                local v598 = Items:FindFirstChild(p66:GetAttribute("item_type"))
                if v598 then
                    local p66Name = v598:FindFirstChild(p66.Name)
                    if p66Name then
                        return p66Name:GetAttribute("RarityName") or "Common"
                    end
                    return "Common"
                end
                return "Common"
            end
            t24.GetAttributeSafe = function(p67, p68)
                local p68_2 = p67:GetAttribute(p68)
                if p68_2 == nil then
                    local v603 = t24.EncodedTable[p68]
                    if not v603 then return nil end
                    return p67:GetAttribute(v603)
                end
                return p68_2
            end
            t24.DrawObject = function(p69, p70)
                local drawing = Drawing.new(p69)
                if drawing then
                    t24.AllDrawing.AllDrawingObject[drawing] = true
                    for k, v in pairs(p70) do drawing[k] = v end
                    return drawing
                end
            end
            t24.FindVehicle = function()
                for _, v in next, Vehicles:GetChildren() do
                    if v:GetAttribute("OwnerUserId") == UserId then return v end
                end
            end
            t24.GetATMStatus = function(p71)
                local v612 = ATM.class.objects[p71]
                if v612 then return (v612.states.disabled.get()) end
            end
            u227 = new("Part", workspace)
            u227.Size = new4(2, 2, 2)
            u227.CFrame = new3(0, 1500000, 0)
            u227.Anchored = true
            spawn(function()
                if not shared.SecurityBreakdown then
                    local v613 = (function()
                        local ok, result = pcall(getupvalue, Net.send, 2)
                        if not ok or not result or typeof(result) ~= "function" then return end
                        for k, _ in next, t24.ConstantsToFind do
                            local v1173 = false
                            for _, v in next, getconstants(result) do
                                if v == k then v1173 = true break end
                            end
                            if not v1173 then return nil end
                            t24.ConstantsToFind[k] = true
                        end
                        if t24.ConstantsToFind.getfenv and t24.ConstantsToFind.identifyexecutor then return result end
                        return nil
                    end)()
                    if not v613 then
                        if not shared.SecurityBreakdown then shared.SecurityBreakdown = false return end
                        return
                    end
                    replaceclosure(v613, function(p72, p73, p74, p75, ...)
                        return p72(p73, p74, p75, ...)
                    end)
                    u187 = { Send1 = clonefunction(Net.send), Get2 = clonefunction(Net.get) }
                    u187.send = function(...)
                        local v1180 = select(1, ...)
                        if u135.NoCrashActive and type(v1180) == "string" and (string.find(string.lower(v1180), "crash") or string.find(string.lower(v1180), "damage") or string.find(string.lower(v1180), "wreck") or string.find(string.lower(v1180), "collid")) then
                            warn("[NoCrash] blocked: " .. v1180)
                            return
                        end
                        if typeof(v1180) == "string" and t24.Blacklisted_Network_Calls[v1180] then
                        end
                        return u187.Send1(...)
                    end
                    u187.get = function(...)
                        local v1181 = select(1, ...)
                        if typeof(v1181) == "string" and t24.Blacklisted_Network_Calls[v1181] then
                        end
                        return u187.Get2(...)
                    end
                    shared.SecurityBreakdown = true
                end
            end)
            repeat wait2() until u187 and (u187.send or u187.get) or shared.SecurityBreakdown
            u228 = function(p76, p77, p78)
                local v617 = p77 ^ 2 - 4 * p76 * p78
                if v617 >= 0 then
                    local v618 = math.sqrt(v617)
                    return (-p77 - v618) / (2 * p76), (-p77 + v618) / (2 * p76)
                end
                return nil, nil
            end
            u229 = function(p79, p80, p81)
                local v622, v623 = u228(p80:Dot(p80) / 4, p80:Dot(p79) - p81 ^ 2, p79:Dot(p79))
                if v622 and v623 then
                    if v622 > 0 and v622 < v623 then return math.sqrt(v622) end
                    if v623 > 0 and v623 < v622 then return math.sqrt(v623) end
                end
                return 0
            end
            u230 = function(p82, p83) return 0.01 * p82 * p83 ^ 2 end
            u231 = function(_, p85, p86, p87, p88) return p85 + p86 * p87 + u230(p88, p87) end
            u232 = function(p89, p90, p91)
                local v634 = t24.TargetHistory[p89]
                if v634 and #v634 >= 1 then
                    if #v634 ~= 1 then
                        if #v634 ~= 2 then
                            if #v634 < 3 then return Vector3.zero end
                            local v635 = v634[#v634 - 2]
                            local v636 = v634[#v634 - 1]
                            local v637 = v634[#v634]
                            local v638 = math.max(v636.time - v635.time, 0.000001)
                            local v639 = math.max(v637.time - v636.time, 0.000001)
                            local v640 = (v636.pos - v635.pos) / v638
                            local v641 = (v637.pos - v636.pos) / v639
                            local v642 = math.max(v638 + v639, 0.000001)
                            local v643 = (v641 - v640) / v642
                            if v643.Magnitude <= 500 then
                                local v644 = v639 / v642
                                return v641 * v644 + v640 * (1 - v644) + v643 * v639 * 0.5
                            end
                            return (v640 + v641) / 2
                        end
                        local v645 = v634[1]
                        local v646 = v634[2]
                        local v647 = math.max(v646.time - v645.time, 0.000001)
                        return (v646.pos - v645.pos) / v647
                    end
                    local v648 = v634[1]
                    local v649 = math.max(p91 - v648.time, 0.000001)
                    return (p90 - v648.pos) / v649
                end
                return Vector3.zero
            end
            send = Net.send
            Net.send = function(...)
                local t31 = { ... }
                if u135.NoCrashActive and type(t31[1]) == "string" and (string.find(string.lower(t31[1]), "crash") or string.find(string.lower(t31[1]), "damage") or string.find(string.lower(t31[1]), "wreck") or string.find(string.lower(t31[1]), "collid")) then
                    warn("[NoCrash] blocked: " .. t31[1])
                    return
                end
                if t31[1] ~= "leave_character_creator" or u188 ~= "GodMode" then
                    if t31[1] == "shoot_gun" and (u135.AimAssist or u135.AutoShot) and t24.TargetAim and u189 and u190 and u191 and t24.IsAlive(u189) then
                        local TargetAim = t24.TargetAim
                        if TargetAim then
                            local v652 = TargetAim:FindFirstChild(u135.SelectPart or "Head") or (TargetAim:FindFirstChild("Head") or TargetAim:FindFirstChildWhichIsA("BasePart"))
                            if v652 then
                                local Position = u189:GetPivot().Position
                                local Position2 = v652:GetPivot().Position
                                local v655 = Position2 - Position
                                local v656 = new4(0, -workspace.Gravity, 0)
                                local NetworkPing = LocalPlayer2:GetNetworkPing()
                                local v658 = u229(v655, v656, 1000)
                                local v659 = u232(TargetAim, Position, tick())
                                local v660 = u231(Position, Position2, v659, v658 + NetworkPing, v656)
                                local v661 = Char.get_tool()
                                local v662 = v661 and v661:GetAttribute("AmmoType") == "shotgun"
                                local v663 = u135.WallBang and (v661 and (v661:GetAttribute("AmmoType") ~= "shotgun" and t24.IsBehindWall(Position, v660)))
                                t31[3] = v662 and new3(Position, v660) or (v663 and new3(math.huge, math.huge, math.huge) or new3(Position, v660))
                                for _, v in pairs(t31[4]) do
                                    for _, v6 in pairs(v) do
                                        v6.Normal = new4(0, 1, 0)
                                        v6.Position = v660
                                        v6.Instance = v652
                                    end
                                end
                                if u135.MultiShot then send(table.unpack(t31)) end
                                local Magnitude = (Position2 - Position).Magnitude
                                if Magnitude > 0.1 then
                                    local Part = Instance.new("Part", workspace)
                                    Part.Size = new4(0.02, 0.02, Magnitude)
                                    Part.CFrame = new3(Position, Position2) * new3(0, 0, -Magnitude / 2)
                                    Part.Material = Enum.Material.Neon
                                    Part.CanCollide = false
                                    Part.Anchored = true
                                    Debris:AddItem(Part, 0.4)
                                end
                            end
                        end
                    end
                    return send(unpack(t31))
                end
            end
            get = Net.get
            Net.get = function(...)
                local t32 = { ... }
                if t32[1] ~= "pickup_dropped_item" or not u135.AutoPickDroppedItem or not u135.BlacklistPickDroppedItem then
                    return get(unpack(t32))
                end
                local v671 = t32[2]
                if v671.Name ~= "Money" then
                    if not table.find(u135.BlacklistPickDroppedItem, t24.GetItemRarity(v671) or "Common") then
                        return
                    end
                    return get(...)
                end
                return get(...)
            end
            tween = Util.tween
            Util.tween = function(p92, p93, p94)
                if p92 and p92:IsA("NumberValue") and p94 and p94.Value ~= nil then
                    p92.Value = p94.Value
                end
                return tween(p92, p93, p94)
            end
            DeathScreenHolder = PlayerGui.DeathScreen.DeathScreenHolder
            t24.Connect(DeathScreenHolder.Frame.RespawnButtonFrame.RespawnButton.TextLabel:GetPropertyChangedSignal("Text"), function()
                if u135.AutoRespawn and DeathScreenHolder.Visible and DeathScreenHolder.Frame.RespawnButtonFrame.RespawnButton.TextLabel.Text == "Respawn" then
                    u187.send("death_screen_request_respawn")
                end
            end)
            set = Ragdoll.is_ragdolling.set
            Ragdoll.is_ragdolling.set = function(p95)
                if not p95 or not u135.AntiRagdoll then return set(p95) end
                u187.send("end_ragdoll_early")
                u187.send("clear_ragdoll")
                return nil
            end
            getfenv(Hotbar.loaded).get_max_items = function(_, ...) return 10 end
            local sprint_bar = getupvalue(Sprint.consume_stamina, 2).sprint_bar
            if sprint_bar then
                local update = sprint_bar.update
                sprint_bar.update = function(...)
                    if not u135.InfiniteStamina then return update(...) end
                    return update(function() return 1 end)
                end
            end
        end
        u240 = nil
        u240 = hookmetamethod(game, "__index", function(p97, p98)
            if not u135.AntiAimbot or checkcaller() or p98 ~= "CFrame" or p97 ~= u190 or not t24.IsAlive(u189) or Char.get_hum():GetAttribute("HasBeenDowned") or not t24.SavedHistoryCFrame then
                return u240(p97, p98)
            end
            return t24.SavedHistoryCFrame
        end)
        u241 = new("BindableEvent")
        if PlayerGui:FindFirstChild("CharacterCreator") and PlayerGui:FindFirstChild("CharacterCreator").Enabled or LocalPlayer2:GetAttribute("InSplashScreen") then
            if LocalPlayer2:GetAttribute("InSplashScreen") then
                local SplashScreenGui = PlayerGui:FindFirstChild("SplashScreenGui")
                if SplashScreenGui then SplashScreenGui.Enabled = false end
                local Sound = SoundService:FindFirstChild("Sound")
                if Sound then Sound:Destroy() end
                local v244 = new("ScreenGui")
                local v245 = new("Frame")
                local v246 = new("UICorner")
                local v247 = new("ImageLabel")
                local v248 = new("TextButton")
                local v249 = new("UICorner")
                local v250 = new("TextLabel")
                local v251 = new("TextButton")
                local v252 = new("UICorner")
                local v253 = new("TextLabel")
                local v254 = new("ImageLabel")
                local v255 = new("UICorner")
                local v256 = new("TextLabel")
                local v257 = new("TextLabel")
                local v258 = new("ImageLabel")
                local v259 = new("Frame")
                v244.Name = "SQ SAMA"
                v244.Parent = gethui and gethui() or PlayerGui
                v244.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                v244.IgnoreGuiInset = true
                v245.Parent = v244
                v245.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                v245.BackgroundTransparency = 0.45
                v245.BorderColor3 = Color3.fromRGB(0, 0, 0)
                v245.BorderSizePixel = 0
                v245.AnchorPoint = new2(0.5, 0.5)
                v245.Position = UDim2.new(0.5, 0, 0.5, 0)
                v245.Size = UDim2.new(0.353056401, 0, 0.399934381, 0)
                v246.CornerRadius = UDim.new(0, 6)
                v246.Parent = v245
                v247.Name = "FrameShadow"
                v247.Parent = v245
                v247.AnchorPoint = new2(0.5, 0.5)
                v247.BackgroundTransparency = 1
                v247.Position = UDim2.new(0.5, 0, 0.5, 2)
                v247.Size = UDim2.new(1, 142, 1, 142)
                v247.ZIndex = 0
                v247.Image = "rbxassetid://12817494724"
                v247.ImageTransparency = 0.5
                v247.ScaleType = Enum.ScaleType.Slice
                v247.SliceCenter = Rect.new(85, 85, 427, 427)
                v248.Parent = v245
                v248.BackgroundColor3 = Color3.fromRGB(97, 97, 97)
                v248.BackgroundTransparency = 0.7
                v248.BorderSizePixel = 0
                v248.Position = UDim2.new(0.5, 0, 0.55, 0)
                v248.AnchorPoint = new2(0.5, 0)
                v248.Size = UDim2.new(0.531045794, 0, 0.123188406, 0)
                v248.Font = Enum.Font.SourceSans
                v248.Text = ""
                v249.CornerRadius = UDim.new(0, 6)
                v249.Parent = v248
                v250.Parent = v248
                v250.AnchorPoint = new2(0.5, 0.5)
                v250.Position = UDim2.new(0.5, 0, 0.5, 0)
                v250.Size = UDim2.new(1, 0, 1, 0)
                v250.Font = Enum.Font.SourceSansSemibold
                v250.Text = "Normal Mode"
                v250.TextColor3 = Color3.fromRGB(205, 214, 244)
                v250.TextSize = 14
                v250.BackgroundTransparency = 1
                v251.Parent = v245
                v251.BackgroundColor3 = Color3.fromRGB(97, 97, 97)
                v251.BackgroundTransparency = 0.7
                v251.BorderSizePixel = 0
                v251.Position = UDim2.new(0.5, 0, 0.7, 0)
                v251.AnchorPoint = new2(0.5, 0)
                v251.Size = UDim2.new(0.531, 0, 0.133869573, 0)
                v251.Font = Enum.Font.SourceSans
                v251.Text = ""
                v252.CornerRadius = UDim.new(0, 6)
                v252.Parent = v251
                v253.Parent = v251
                v253.AnchorPoint = new2(0.5, 0.5)
                v253.Position = UDim2.new(0.5, 0, 0.5, 0)
                v253.Size = UDim2.new(1, 0, 1, 0)
                v253.Font = Enum.Font.SourceSansSemibold
                v253.Text = "God Mode"
                v253.TextColor3 = Color3.fromRGB(205, 214, 244)
                v253.TextSize = 14
                v253.BackgroundTransparency = 1
                v254.Parent = v245
                v254.BackgroundTransparency = 1
                v254.Position = UDim2.new(-0.00235841633, 0, 0, 0)
                v254.Size = UDim2.new(1.00235844, 0, 1, 0)
                v254.Image = "rbxassetid://74772367796358"
                v254.ImageColor3 = Color3.fromRGB(38, 38, 38)
                v254.ImageTransparency = 0.62
                v255.CornerRadius = UDim.new(0, 6)
                v255.Parent = v254
                v256.Parent = v245
                v256.AnchorPoint = new2(0.5, 0.5)
                v256.Position = UDim2.new(0.5, 0, 0.36, 0)
                v256.Size = UDim2.new(0.9, 0, 0, 37)
                v256.Font = Enum.Font.SourceSansSemibold
                v256.Text = "Synixia Hub"
                v256.TextColor3 = Color3.fromRGB(255, 60, 60)
                v256.TextScaled = true
                v256.BackgroundTransparency = 1
                v257.Parent = v245
                v257.AnchorPoint = new2(0.5, 0.5)
                v257.Position = UDim2.new(0.5, 0, 0.48, 0)
                v257.Size = UDim2.new(0.85, 0, 0, 22)
                v257.Font = Enum.Font.SourceSansSemibold
                v257.Text = "Select the mode you want to use."
                v257.TextColor3 = Color3.fromRGB(205, 214, 244)
                v257.TextSize = 14
                v257.TextWrapped = true
                v257.TextYAlignment = Enum.TextYAlignment.Top
                v257.BackgroundTransparency = 1
                v258.Parent = v245
                v258.BackgroundTransparency = 1
                v258.Position = UDim2.new(0.5, 0, 0.06, 0)
                v258.AnchorPoint = new2(0.5, 0)
                v258.Size = UDim2.new(0.148523644, 0, 0.25891304, 0)
                v258.Image = "rbxassetid://102698274674617"
                v259.Parent = v245
                v259.BackgroundColor3 = Color3.fromRGB(72, 72, 72)
                v259.BorderSizePixel = 0
                v259.Position = UDim2.new(0.5, 0, 0.685, 0)
                v259.AnchorPoint = new2(0.5, 0)
                v259.Size = UDim2.new(0.7, 0, 0, 1)
                v251.MouseButton1Click:Connect(function() u188 = "GodMode" end)
                v248.MouseButton1Click:Connect(function() u188 = "Normal" end)
                local elapsed2 = os.clock()
                repeat wait2() until u188 or os.clock() - elapsed2 > 10
                if not u188 then u188 = "Normal" end
                v244:Destroy()
            end
            spawn(function()
                pcall(SplashScreen.in_loading_screen.set, false)
                wait2(1.5)
                pcall(CharacterCreator.finish)
                u241:Fire()
            end)
            u241.Event:Wait()
            u241:Destroy()
            if u188 == "GodMode" then
                replicatesignal(LocalPlayer2.Kill)
                wait2(5)
                u187.send("death_screen_request_respawn")
            end
        end
        repeat wait2() until not LocalPlayer2:GetAttribute("InSplashScreen") and PlayerGui:WaitForChild("Hotbar"):WaitForChild("HotbarHolder"):FindFirstChild("List").Visible
        u189 = LocalPlayer2.Character or LocalPlayer2.CharacterAdded:Wait()
        u191 = u189:WaitForChild("Humanoid")
        u190 = u189:WaitForChild("HumanoidRootPart")
        Backpack = LocalPlayer2:WaitForChild("Backpack")
        t24.Connect(LocalPlayer2.CharacterAdded, function(p99)
            u189 = p99
            u191 = p99:WaitForChild("Humanoid")
            u190 = p99:WaitForChild("HumanoidRootPart")
        end)
        t24.Connect(u191.StateChanged, function(_, p101)
            if p101 == Enum.HumanoidStateType.FallingDown then
                u191:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
        u135.AutoFish = u135.AutoFish or false
        spawn(function()
            local function FindWaterPosition()
                local HRP = u190
                if not HRP then
                    pcall(function() HRP = Char.get_hrp() end)
                end
                if not HRP then return nil end
                local SearchOrigin = HRP.Position + (HRP.CFrame.LookVector * 20)
                local Params = RaycastParams.new()
                Params.FilterType = Enum.RaycastFilterType.Exclude
                Params.FilterDescendantsInstances = { u189 }
                local Result = workspace:Raycast(SearchOrigin, Vector3.new(0, -100, 0), Params)
                if Result and Result.Material == Enum.Material.Water and (Result.Position - HRP.Position).Magnitude < 60 then
                    return Result.Position
                end
                return nil
            end
            pcall(function()
                if SliderMinigame and SliderMinigame.enabled and type(SliderMinigame.enabled.hook) == "function" then
                    SliderMinigame.enabled.hook(function(IsEnabled)
                        if u135.AutoFish and IsEnabled then
                            local CurrentRod = nil
                            pcall(function()
                                if FishingRodModule and FishingRodModule.equipped_rod then
                                    CurrentRod = FishingRodModule.equipped_rod.get()
                                end
                            end)
                            if CurrentRod and u187 then
                                pcall(function() u187.send("reel_ended", CurrentRod, true) end)
                            end
                        end
                    end)
                end
            end)
            while wait2(1) do
                if not u135.AutoFish then
                    continue
                end
                pcall(function()
                    local CurrentRod = nil
                    pcall(function()
                        if FishingRodModule and FishingRodModule.equipped_rod then
                            CurrentRod = FishingRodModule.equipped_rod.get()
                        end
                    end)
                    if not CurrentRod then
                        return
                    end
                    local ItemGUID = CurrentRod:GetAttribute("ItemGUID")
                    if not ItemGUID then
                        return
                    end
                    local ItemInfo = nil
                    pcall(function()
                        if ItemUtils and Data then
                            ItemInfo = ItemUtils.get_item_info(Data, ItemGUID)
                        end
                    end)
                    if not ItemInfo then
                        return
                    end
                    if not (ItemInfo.ammo_amount and ItemInfo.ammo_amount > 0) then
                        pcall(function() CurrentRod:Activate() end)
                        wait2(0.5)
                        return
                    end
                    if not CurrentRod:FindFirstChild("Bobber") then
                        local WaterPosition = FindWaterPosition()
                        if WaterPosition and u187 then
                            pcall(function() u187.get("throw_rod", CurrentRod, WaterPosition) end)
                        end
                    end
                end)
            end
        end)
        u262 = t24.DrawObject("Circle", { Visible = false, Color = Color3.fromRGB(255, 255, 255), Radius = 200, Thickness = 1, Filled = false })
        u263 = t24.DrawObject("Line", { Visible = false, Color = Color3.fromRGB(125, 21, 19), Thickness = 1 })
        Util.hook_players(function(p102)
            if p102 ~= LocalPlayer2 then
                t24.AllDrawing.AllPlayerDrawing[p102] = {
                    Box = t24.DrawObject("Square", { Visible = false, Color = Color3.fromRGB(255, 0, 0), Thickness = 0.7, Transparency = 1, Filled = false }),
                    HpBar = t24.DrawObject("Line", { Visible = false, Color = Color3.new(0, 1, 0), Thickness = 2 }),
                    Name = t24.DrawObject("Text", { Visible = false, Color = Color3.new(1, 1, 1), Size = 15, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Text = p102.Name }),
                    Distance = t24.DrawObject("Text", { Visible = false, Color = Color3.new(1, 1, 1), Size = 15, Center = true, Outline = true, OutlineColor = Color3.new(0, 0, 0), Text = "" })
                }
                wait2()
            end
        end)
        t24.Connect(Players.PlayerRemoving, function(p103)
            if t24.AllDrawing.AllPlayerDrawing[p103] then
                for _, v in next, t24.AllDrawing.AllPlayerDrawing[p103] do
                    if v.Remove then v:Remove() wait2() end
                end
                t24.AllDrawing.AllPlayerDrawing[p103] = nil
            end
        end)
        u264 = function(p104)
            t24.SavedHistoryCFrame = p104.CFrame
            p104.CFrame = new3(p104.Position + new4(1, 1, 1))
            RunService2.RenderStepped:Wait()
            p104.CFrame = t24.SavedHistoryCFrame
        end
        u265 = function(p105)
            local p105Velocity = p105.Velocity
            local AssemblyLinearVelocity = p105.AssemblyLinearVelocity
            local AssemblyAngularVelocity = p105.AssemblyAngularVelocity
            local RotVelocity = p105.RotVelocity
            local v694 = math.random(-999999999, 999999999)
            local v695 = math.random(-999999999, 999999999)
            local v696 = math.random(-999999999, 999999999)
            p105.Velocity = new4(v694, v695, v696)
            p105.AssemblyLinearVelocity = new4(v694, v695, v696)
            p105.AssemblyAngularVelocity = new4(v694, v695, v696)
            p105.RotVelocity = new4(v694, v695, v696)
            RunService2.RenderStepped:Wait()
            p105.Velocity = p105Velocity
            p105.AssemblyLinearVelocity = AssemblyLinearVelocity
            p105.AssemblyAngularVelocity = AssemblyAngularVelocity
            p105.RotVelocity = RotVelocity
        end
        t24.Connect(RunService2.Heartbeat, function()
            if u135.AntiAimbot then
                if not u189:WaitForChild("Head"):WaitForChild("Downed") or not u189:WaitForChild("Head"):WaitForChild("Downed").Enabled then
                    local v697 = Char.get_hrp()
                    u265(v697)
                    u264(v697)
                end
                return
            end
        end)
        t24.Connect(RunService2.Heartbeat, function()
            if u135.AimAssist then
                if t24.TargetAim then
                    for _, v in pairs(Char.get_all()) do
                        if v.Name == t24.TargetAim.Name and t24.IsAlive(v) then
                            local v700 = v:FindFirstChild(u135.SelectPart or "Head") or (v:FindFirstChild("Head") or v:FindFirstChildWhichIsA("BasePart"))
                            if v700 then
                                local timestamp = tick()
                                local Position = v700:GetPivot().Position
                                t24.TargetHistory[v] = t24.TargetHistory[v] or {}
                                local v703 = t24.TargetHistory[v]
                                if #v703 >= 3 then table.remove(v703, 1) end
                                table.insert(v703, { pos = Position, time = timestamp })
                            end
                        end
                    end
                    return
                end
                return
            end
        end)
        t24.Connect(u222.Event, function(p106)
            if p106 then u223 = true end
        end)
        t24.Connect(ReplicatedStorage.Remotes.Send.OnClientEvent, function(...)
            local t33 = { ... }
            if t33[1] == "notification" and t24.Anticheat_Detection_Types[t33[3]] then
                u222:Fire(true)
            end
        end)
        local TouchGui = PlayerGui:WaitForChild("TouchGui", 1)
        local v267 = TouchGui and TouchGui:FindFirstChild("TouchControlFrame")
        local v268 = v267 and v267:FindFirstChild("JumpButton")
        task.spawn(function()
            while task.wait(0.25) do
                local currentTouchGui = PlayerGui:FindFirstChild("TouchGui")
                local controlFrame = currentTouchGui and currentTouchGui:FindFirstChild("TouchControlFrame")
                local jumpButton = controlFrame and controlFrame:FindFirstChild("JumpButton")
                if jumpButton and jumpButton:IsA("GuiObject") then
                    jumpButton.Visible = true
                    jumpButton.Active = true
                end
            end
        end)
        t24.Connect(UserInputService.InputBegan, function(p107, p108)
            if not p108 then
                if u135.FlyJump then
                    if p107.UserInputType == Enum.UserInputType.Keyboard and p107.KeyCode == Enum.KeyCode.Space then
                        t24.JumpDown = true
                    end
                    return
                end
                return
            end
        end)
        t24.Connect(UserInputService.InputEnded, function(p109, p110)
            if not p110 then
                if p109.UserInputType == Enum.UserInputType.Keyboard and p109.KeyCode == Enum.KeyCode.Space then
                    t24.JumpDown = false
                end
                return
            end
        end)
        if v268 then
            t24.Connect(v268.InputBegan, function(p111, p112)
                if not p112 then
                    if u135.FlyJump then
                        if p111.UserInputType == Enum.UserInputType.Touch then t24.JumpDown = true end
                        return
                    end
                    return
                end
            end)
            t24.Connect(v268.InputEnded, function(p113, p114)
                if not p114 then
                    if p113.UserInputType == Enum.UserInputType.Touch then t24.JumpDown = false end
                    return
                end
            end)
        end
        elapsed = os.clock()
        t24.Connect(RunService2.PreRender, function()
            if os.clock() - elapsed >= 0.1 then
                elapsed = os.clock()
                local v714 = u191.MoveDirection.Magnitude > 0.1
                if v714 and (u135.CustomSpeed or Sprint.sprinting.get()) then
                    u187.send("set_sprinting_1", true)
                end
                if v714 and u135.CustomSpeed then
                    u190.CFrame = u190.CFrame + u191.MoveDirection.Unit * ((u135.CustomSpeedValue or 1) / 145.5)
                end
                if t24.JumpDown and u135.FlyJump then
                    if not u191 or u191.FloorMaterial ~= Enum.Material.Air then return end
                    for _, v in next, u189:GetDescendants() do
                        if v:IsA("BasePart") and v.AssemblyLinearVelocity.Y < 50 then
                            v:ApplyImpulse(Vector3.yAxis * 5.8333333333333)
                        end
                    end
                end
                return
            end
        end)
        if workspace:FindFirstChild("Map"):FindFirstChild("VehicleBlockers") then
            workspace:FindFirstChild("Map"):FindFirstChild("VehicleBlockers"):Destroy()
        end
        for k in next, DoorClient.class.objects do
            if typeof(k) == "Instance" then pcall(k.Destroy, k) end
        end
        for _, v in next, ATM.class.objects do
            local instance = v.instance
            if instance and instance:IsDescendantOf(workspace) then
                if not instance:FindFirstChild("BestPos") then
                    local v274 = new("Part")
                    v274.Parent = instance
                    v274.Size = new4(1, 1, 1)
                    v274.CanCollide = false
                    v274.Anchored = true
                    v274.Transparency = 1
                    v274.Name = "BestPos"
                    local v275 = t24.FindClosest(t24.BestPosOfATM, function(p115) return typeof(p115) == "CFrame" end, instance:GetPivot().Position)
                    if v275 then v274.CFrame = v275 end
                end
                table.insert(t24.AllATM, instance)
            end
        end
        for _, v in next, t24.BlockedNodePositions do
            local v278 = new("Part", Map)
            v278.Name = "BlockedNode"
            v278.Anchored = true
            v278.CanCollide = false
            v278.Size = v.Size
            v278.CFrame = new3(v.Position)
            v278.Transparency = 1
            local v279 = new("PathfindingModifier")
            v279.Parent = v278
            v279.PassThrough = false
            v279.Label = "BlockedNode"
        end
        t34 = {}
        t34.__index = t34
        t35 = {
            Normal = {
                AgentCanJump = true,
                AgentMaxSlope = 70,
                WaypointSpacing = 3,
                AgentJumpRadius = 50,
                AgentJumpHeight = 10,
                AgentRadius = ceil(2 * u191:FindFirstChild("BodyWidthScale").Value),
                AgentHeight = ceil(5 * u191:FindFirstChild("BodyHeightScale").Value),
                Costs = { DoorArea = 0, BlockedNode = math.huge }
            },
            Vehicle = {}
        }
        t25.GetInventory = function()
            local t36 = {}
            for k, v in pairs(Data.items or {}) do
                for _, v7 in pairs(v) do
                    for _, v8 in ipairs(v7) do
                        table.insert(t36, {
                            Type = k, Name = v8.name, Guid = v8.guid,
                            Location = v8.location or "hand", Amount = v8.amount or 1,
                            Durability = v8.durability, Health = v8.health,
                            Class = v8.class and v8.class.name or nil, Destroyed = v8.destroyed
                        })
                    end
                end
            end
            return t36
        end
        t25.GetItemsByName = function(p116)
            local t37 = {}
            for _, v in ipairs(t25.GetInventory()) do
                if p116 == v.Name then table.insert(t37, v) end
            end
            return t37
        end
        t25.GetItemsByType = function(p117)
            local t38 = {}
            for k, v in pairs(Data.items or {}) do
                if k == p117 then
                    for k2, v9 in pairs(v) do t38[k2] = v9 end
                end
            end
            return t38
        end
        t25.FilterByLocation = function(p118, p119)
            local t39 = {}
            for _, v in ipairs(p118) do
                if p119 == v.Location then table.insert(t39, v) end
            end
            return t39
        end
        t25.FindItemByName = function(p122)
            for _, v in next, ReplicatedStorage.Items:GetChildren() do
                for _, v10 in next, v:GetChildren() do
                    if p122 == v10.Name or p122 == t24.GetAttributeSafe(v10, "DisplayName") then
                        return {
                            Name = v10.Name,
                            Description = t24.GetAttributeSafe(v10, "Description"),
                            Rarity = t24.GetAttributeSafe(v10, "RarityName"),
                            ImageId = t24.GetAttributeSafe(v10, "ImageId"),
                            Price = t24.GetAttributeSafe(v10, "RarityPrice")
                        }
                    end
                end
            end
            return nil
        end
        t25.FindItemByNamePattern = function(p123, p124)
            for _, v in next, ReplicatedStorage.Items:GetChildren() do
                if not p124 or p124 == v.Name then
                    for _, v11 in next, v:GetChildren() do
                        if v11.Name:lower():find(p123:lower()) then
                            return {
                                Name = v11.Name,
                                Description = t24.GetAttributeSafe(v11, "Description"),
                                Rarity = t24.GetAttributeSafe(v11, "RarityName"),
                                ImageId = t24.GetAttributeSafe(v11, "ImageId"),
                                Price = t24.GetAttributeSafe(v11, "RarityPrice")
                            }
                        end
                    end
                end
            end
            return nil
        end
        t25.GenerateHash = function(p131)
            local t41 = {}
            for _, v in next, p131:GetDescendants() do
                if not v:IsA("MeshPart") then
                    if v:IsA("SpecialMesh") then
                        local MeshId = v.MeshId
                        if MeshId and MeshId ~= "" then table.insert(t41, MeshId) end
                        if v.TextureId and v.TextureId ~= "" then table.insert(t41, v.TextureId) end
                        if v.Parent and v.Parent:IsA("BasePart") then table.insert(t41, v.Parent.Material.Name) end
                    end
                else
                    local MeshId = v.MeshId
                    if MeshId and MeshId ~= "" then table.insert(t41, MeshId) end
                    if v.TextureID and v.TextureID ~= "" then table.insert(t41, v.TextureID) end
                    table.insert(t41, v.Material.Name)
                end
            end
            table.sort(t41, function(p132, p133)
                local num = tonumber(p132:match("%d+"))
                local num2 = tonumber(p133:match("%d+"))
                if not num or not num2 then return p132 < p133 end
                return num < num2
            end)
            local v827 = table.concat(t41, ",")
            local n19 = 0
            for i = 1, #v827 do
                n19 = (n19 * 31 + v827:byte(i)) % 4294967296
            end
            return n19
        end
        t25.ResolveHash = function(p134)
            local v831 = t25.GenerateHash(p134)
            local v832 = t24.ToolHashes[v831]
            local t42 = { gun = true, melee = true, accessory = true, consumable = true, throwable = true }
            if not v832 then
                for _, v in next, ReplicatedStorage.Items:GetChildren() do
                    if t42[v.Name] then
                        for _, v19 in next, v:GetChildren() do
                            local v838 = t25.GenerateHash(v19)
                            t24.ToolHashes[v838] = v19
                            if v838 == v831 then v832 = v19 break end
                        end
                    end
                end
            end
            if not v832 then return t25.GuessItem(p134) end
            return {
                Name = v832.Name,
                Description = v832:GetAttribute("Description"),
                Rarity = v832:GetAttribute("RarityName"),
                ImageId = v832:GetAttribute("ImageId"),
                Price = v832:GetAttribute("RarityPrice")
            }
        end
        t26.GetMoney = function()
            return { hand = Data.money.hand, bank = Data.money.bank }
        end
        t26.GetSkill = function(p135)
            local SkillsScrollingFrame = PlayerGui:FindFirstChild("Skills"):FindFirstChild("SkillsHolder").SkillsScrollingFrame
            for _, v in next, SkillsScrollingFrame:GetChildren() do
                if v.Name == "SkillOptionTemplate" and find(v:FindFirstChild("SkillTitle").Text, p135) then
                    return tonumber(v:FindFirstChild("SkillTitle").Text:match("%d+"))
                end
            end
        end
        t26.VerifyTool = function(p136)
            local v844 = p136:lower()
            for _, v in next, { u189:GetChildren(), Backpack:GetChildren() } do
                for _, v20 in next, v do
                    if find(v20.Name:lower(), v844, 1, true) then return v20 end
                end
            end
            return nil
        end
        t27.Teleport = function(p137, p138, p139, p140)
            if p137 then
                if not u135.StopTween then
                    if not u223 then
                        local g873 = nil
                        if u191:GetAttribute("IsDead") then
                            repeat wait2(1) until u191 and u191:GetAttribute("IsDead") == nil or u135.StopTween
                        end
                        local Position = u189:GetPivot().Position
                        local u856 = typeof(p137) == "CFrame" and p137.Position or p137
                        local u857 = PathfindingService:CreatePath(p139 == 1 and t35.Normal or t35.Vehicle)
                        local ok, _ = pcall(function() u857:ComputeAsync(Position, u856) end)
                        if ok then
                            local Waypoints = u857:GetWaypoints()
                            local v861 = false
                            local v862 = false
                            for _, v in pairs(Waypoints) do
                                if v861 then break end
                                local v865 = v.Action == Enum.PathWaypointAction.Jump and 12 or 2.5
                                local v866 = v.Position + new4(0, v865, 0)
                                local Position3 = u189:GetPivot().Position
                                local Unit = (v866 - Position3).Unit
                                local Magnitude = (v866 - Position3).Magnitude
                                local n20 = 0
                                local v871 = u135.TweenSpeed or 35
                                t24.StaminaFarm = true
                                repeat
                                    local g872 = false
                                    if n20 >= Magnitude then g873 = true end
                                    if g873 then break end
                                    local v874 = RunService2.PreSimulation:Wait()
                                    n20 = min(n20 + v871 * v874, Magnitude)
                                    if not u135.StopTween and t24.IsAlive(u189) and not u223 then
                                        if not p140 or not t24.GetATMStatus(p140) then
                                            if u191.Sit then u191.Sit = false end
                                            local v875 = Position3 + Unit * n20
                                            u187.send("set_sprinting_1", true)
                                            p138:PivotTo(new3(v875))
                                            g872 = true
                                        end
                                        if not g872 then v861 = true end
                                    else
                                        v861 = true
                                        v862 = true
                                    end
                                until not g872
                                g873 = false
                            end
                            if v861 then
                                if v862 and u191.Sit then u191.Sit = false end
                                wait2(2)
                            end
                            u223 = false
                            t24.StaminaFarm = false
                            return
                        end
                        return
                    end
                    if u191.Sit then u191.Sit = false end
                    wait2(2)
                    u223 = false
                    return
                end
                return
            end
        end
        t27.ForceStop = function()
            u135.StopTween = true
            wait2()
            u135.StopTween = false
            t24.StaminaFarm = false
        end
        t27.LockPosition = function(p141)
            local u877 = typeof(p141) == "Vector3" and new3(p141) or p141
            local u878 = t24.Connect(RunService2.Heartbeat, function() u190.CFrame = u877 end)
            delay(30, function() if u878 and u878.Connected then u878:Disconnect() end end)
            return u878
        end
        t27.Deposit = function()
            local v879 = t24.FindClosest(t24.AllATM, function(p142) return not t24.GetATMStatus(p142) end, u190.Position)
            if not v879 then return end
            local Position = v879.BestPos:GetPivot().Position
            t27.Teleport(Position, u189, 1, v879)
            wait2()
            u187.get("transfer_funds", "hand", "bank", t26.GetMoney().hand)
        end
        t24.Gate = { aim = false, esp = false, drop = false, atm = false, inv = false, atmT = 0, invT = 0, melee = 0, nc = 0 }
        t24.Connect(RunService2.PostSimulation, function()
            local G = t24.Gate
            if u135.AimAssist then
            G.aim = true
            local MouseLocation = UserInputService:GetMouseLocation()
            local v882 = u135.SelectPositionFov == "Cursor" and new2(MouseLocation.X, MouseLocation.Y) or u135.SelectPositionFov == "Screen" and new2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            u262.Visible = u135.AimAssist or false
            u262.Radius = u135.FOVRadius or 200
            u262.Position = u135.AimAssist and v882 or new2(0, 0)
            u263.Visible = false
            local v883 = nil
            local huge = math.huge
            for _, v in next, Char.get_all() do
                if v ~= u189 and t24.IsAlive(v) then
                    local player = Players:GetPlayerFromCharacter(v)
                    if player and not player:GetAttribute("InMenuCharacterCreator") and not player:GetAttribute("InSplashScreen") and not player:GetAttribute("IsSafeZoneProtected") and not player:GetAttribute("IsSpawnProtected") then
                        local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
                        if HumanoidRootPart then
                            local v889, v890 = t24.WorldToScreen(HumanoidRootPart)
                            if v890 then
                                local v891 = t24.GetDistanceStart(new2(v889.X, v889.Y), v882)
                                if v891 <= u262.Radius and v891 < huge then
                                    huge = v891
                                    v883 = v
                                end
                            end
                        end
                    end
                end
            end
            t24.TargetAim = v883
            if v883 and Players:GetPlayerFromCharacter(v883) then
                local v892, v893 = t24.WorldToScreen(v883:FindFirstChild(u135.SelectPart or "Head") or (v883:FindFirstChild("Head") or v883:FindFirstChildWhichIsA("BasePart")))
                if v892 then
                    u263.Visible = u135.AimAssist and v893 or false
                    u263.From = v882
                    u263.To = new2(v892.X, v892.Y)
                end
            end
            elseif G.aim then
                G.aim = false
                u262.Visible = false
                u263.Visible = false
                if not u135.AutoShot then t24.TargetAim = nil end
            end
            local espOn = u135.Box or u135.Hpbar or u135.Name or u135.Distance
            if espOn then G.esp = true end
            if G.esp then
            for k, v in next, t24.AllDrawing.AllPlayerDrawing do
                local Character = k.Character
                if not Character or not t24.IsAlive(Character) then
                    for _, v21 in next, v do v21.Visible = false end
                else
                    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                    local Head = Character:FindFirstChild("Head")
                    if HumanoidRootPart and Head then
                        local v902, v903 = t24.WorldToScreen(HumanoidRootPart)
                        if not v903 then
                            for _, v22 in next, v do v22.Visible = false end
                        else
                            local v906 = t24.WorldToScreen(Head.Position + new4(0, 0.5, 0))
                            local v907 = t24.WorldToScreen(HumanoidRootPart.Position - new4(0, 3, 0))
                            local v908 = Humanoid.Health / Humanoid.MaxHealth
                            local v909 = new2(1000 / v902.Z, v906.Y - v907.Y)
                            local v910 = new2(v902.X - v909.X / 2, v902.Y - v909.Y / 2)
                            v.Box.Visible = u135.Box or false
                            v.Box.Size = v909
                            v.Box.Position = v910
                            v.Box.Color = u135.IgnoreFriend and (k:IsFriendsWith(UserId) and Color3.fromRGB(4, 43, 150)) or (k:GetAttribute("IsSafeZoneProtected") and Color3.fromRGB(7, 255, 44) or (Character:GetAttribute("IsSpawnProtected") and Color3.fromRGB(3, 41, 255) or Color3.fromRGB(168, 72, 50)))
                            v.HpBar.From = new2(v910.X + v909.X + 3, v910.Y + v909.Y * (1 - v908))
                            v.HpBar.To = new2(v910.X + v909.X + 3, v910.Y + v909.Y)
                            v.HpBar.Color = Color3.new(1 - v908, v908, 0)
                            v.HpBar.Visible = u135.Hpbar or false
                            v.Name.Position = new2(v906.X, v906.Y - 20)
                            v.Name.Visible = u135.Name or false
                            if u135.Name then
                                v.Name.Text = k.Name
                                v.Name.Color = Color3.fromRGB(255, 255, 255)
                            end
                            v.Distance.Position = new2(v906.X, v907.Y + 5)
                            v.Distance.Text = "(" .. floor(t24.GetDistanceRoot(Character)) .. ")"
                            v.Distance.Visible = u135.Distance or false
                        end
                    end
                end
            end
            if not espOn then G.esp = false end
            end
            if u135.DroppedItemVisual then G.drop = true end
            if G.drop then
            for k, v in next, t24.AllDrawing.AllDroppedItemDrawing do
                if not k or not k.Parent then
                    if v.Box then v.Box:Remove() end
                    if v.Name then v.Name:Remove() end
                    if v.Amout then v.Amout:Remove() end
                    t24.AllDrawing.AllDroppedItemDrawing[k] = nil
                end
            end
            local color3 = Color3.fromRGB(255, 255, 255)
            for _, v in next, DroppedItem.class.objects do
                local instance = v.instance
                if instance:IsA("Model") and instance:FindFirstChild("PickUpZone") and not instance:GetAttribute("Locked") then
                    local v917 = t24.AllDrawing.AllDroppedItemDrawing[instance]
                    if not v917 then
                        v917 = {
                            Box = t24.DrawObject("Square", { Color = color3, Thickness = 1, Filled = false }),
                            Name = t24.DrawObject("Text", { Color = color3, Outline = true, Center = true, Text = instance.Name, Size = 13 }),
                            Amout = t24.DrawObject("Text", { Color = color3, Outline = true, Center = true, Size = 11 })
                        }
                        t24.AllDrawing.AllDroppedItemDrawing[instance] = v917
                    end
                    local v918, v919 = t24.WorldToScreen(instance.PickUpZone.Position)
                    local v920 = t24.GetItemRarity(instance) or "Common"
                    if not v919 then
                        for _, v23 in next, v917 do v23.Visible = false end
                    else
                        local v923 = u135.DroppedItemVisual and (not u135.BlacklistItemRarity or not table.find(u135.RarityVisualBlacklist or {}, v920)) or false
                        v917.Box.Size = new2(15, 15)
                        v917.Box.Position = new2(v918.X - 7.5, v918.Y - 7.5)
                        v917.Box.Color = t24.RarityColors[v920]
                        v917.Box.Visible = v923
                        v917.Name.Position = new2(v918.X, v918.Y - 17.5)
                        v917.Name.Visible = v923
                        v917.Amout.Text = tostring(v.states.amount.get() or 1) .. "x"
                        v917.Amout.Position = new2(v918.X, v918.Y + 11.5)
                        v917.Amout.Visible = v923
                    end
                end
            end
            if not u135.DroppedItemVisual then G.drop = false end
            end
            local now = os.clock()
            if (u135.ATMViewer or G.atm) and now - G.atmT >= 0.25 then
            G.atmT = now
            G.atm = u135.ATMViewer and true or false
            for _, v in next, ATM.class.objects do
                local instance = v.instance
                if instance and instance:IsDescendantOf(workspace) then
                    local Highlight = instance:FindFirstChild("Highlight")
                    if not Highlight then
                        Highlight = Instance.new("Highlight")
                        Highlight.Name = "Highlight"
                        Highlight.FillTransparency = 0.8
                        Highlight.OutlineTransparency = 0
                        Highlight.Parent = instance
                    end
                    Highlight.OutlineColor = v.states.disabled.get() and Color3.fromRGB(99, 0, 2) or Color3.fromRGB(17, 99, 2)
                    Highlight.Enabled = u135.ATMViewer or false
                end
            end
            end
            if (u135.InventoryViewer or G.inv) and now - G.invT >= 0.2 then
            G.invT = now
            G.inv = u135.InventoryViewer and true or false
            for _, v in next, Char.get_all() do
                if v ~= u189 and t24.IsAlive(v) then
                    local player = Players:GetPlayerFromCharacter(v)
                    local HumanoidRootPart = v:FindFirstChild("HumanoidRootPart")
                    if HumanoidRootPart then
                        if u135.InventoryViewer and not HumanoidRootPart:FindFirstChild("IvViewer") then
                            local BillboardGui = Instance.new("BillboardGui")
                            BillboardGui.Name = "IvViewer"
                            BillboardGui.AlwaysOnTop = true
                            BillboardGui.Adornee = HumanoidRootPart
                            BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                            BillboardGui.Size = UDim2.new(0, 200, 0, 30)
                            BillboardGui.StudsOffset = new4(0, -3.5, 0)
                            BillboardGui.ExtentsOffset = new4(0, -1, 0)
                            BillboardGui.Parent = HumanoidRootPart
                            local Frame = Instance.new("Frame")
                            Frame.Name = "BackgroundFrame"
                            Frame.BackgroundTransparency = 1
                            Frame.Size = UDim2.new(1, 0, 1, 0)
                            Frame.AnchorPoint = new2(0.5, 0.5)
                            Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                            Frame.Parent = BillboardGui
                            local UIListLayout = Instance.new("UIListLayout")
                            UIListLayout.FillDirection = Enum.FillDirection.Horizontal
                            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                            UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                            UIListLayout.Padding = UDim.new(0, 5)
                            UIListLayout.Parent = Frame
                        end
                        local IvViewer = HumanoidRootPart:FindFirstChild("IvViewer")
                        local v936 = IvViewer and IvViewer:FindFirstChild("BackgroundFrame")
                        if v936 then
                            local t43 = {}
                            for _, v24 in pairs(u135.InventoryViewer and { player.Backpack, v } or {}) do
                                if v24 then
                                    for _, child in pairs(v24:GetChildren()) do
                                        if child:IsA("Tool") and not child:GetAttribute("JobTool") and not child:GetAttribute("Locked") then
                                            local v942 = t25.ResolveHash(child)
                                            if v942 and v942.ImageId then
                                                t43[v942.Name] = true
                                                if not v936:FindFirstChild(v942.Name) then
                                                    local v943 = new("ImageLabel")
                                                    v943.Name = v942.Name
                                                    v943.Image = "rbxassetid://137066731814190"
                                                    v943.BackgroundTransparency = 1
                                                    v943.BorderSizePixel = 0
                                                    v943.ImageColor3 = t24.RarityColors[v942.Rarity] or Color3.fromRGB(0, 150, 255)
                                                    v943.Size = UDim2.new(0, 25, 0, 25)
                                                    v943.Parent = v936
                                                    local v944 = new("ImageLabel")
                                                    v944.Name = "IconBase"
                                                    v944.Image = v942.ImageId
                                                    v944.BackgroundTransparency = 1
                                                    v944.BorderSizePixel = 0
                                                    v944.Size = UDim2.new(0.9, 0, 0.9, 0)
                                                    v944.AnchorPoint = Vector2.new(0.5, 0.5)
                                                    v944.Position = UDim2.new(0.5, 0, 0.5, 0)
                                                    v944.Parent = v943
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            IvViewer.Enabled = u135.InventoryViewer or false
                            for _, child in pairs(v936:GetChildren()) do
                                if child:IsA("ImageLabel") and not t43[child.Name] then child:Destroy() end
                            end
                        end
                    end
                end
            end
            end
        end)
        spawn(function()
            while wait2(0.25) do
                pcall(function()
                    local v1188 = LocalPlayer2:GetAttribute("SprintBar") or 0
                    t24.MovementSpoof = t24.StaminaFarm and v1188 > 0.01
                    if u135.HackToolChip ~= "Smart Select" then
                        t24.HackChip = u135.HackToolChip or "HackToolBasic"
                    else
                        for _, v in ipairs(t24.HackToolList) do
                            if SkillsList.has_skill(Data, "atm_hacker", v.Skill) then
                                t24.HackChip = v.Tool
                            end
                        end
                    end
                end)
            end
        end)
        spawn(function()
            local n21 = 1
            while RunService2.PreSimulation:Wait() do
                if not t24.MovementSpoof then
                    wait2(0.2)
                elseif t24.MovementSpoof then
                    n21 = n21 * -1
                    wait2()
                    sethiddenproperty(u191, "MoveDirectionInternal", Vector3.zAxis / 2 * n21)
                end
            end
        end)
        spawn(function()
            while RunService2.Heartbeat:Wait() do
                if not (u135.AutoJob or u135.AutoATM) then
                    wait2(0.2)
                elseif os.clock() - t24.Gate.melee < 0.2 then
                else
                t24.Gate.melee = os.clock()
                pcall(function()
                    if u135.AutoJob or u135.AutoATM then
                        for _, v in next, Char.get_all() do
                            if v ~= u189 and v:FindFirstChild("HumanoidRootPart") and t24.GetDistanceRoot(v) <= 10 then
                                local t44 = {}
                                local player = Players:GetPlayerFromCharacter(v)
                                table.insert(t44, player)
                                if #t44 > 0 then
                                    if u189:FindFirstChild("Fists") then
                                        local Fists = u189:FindFirstChild("Fists")
                                        Fists:Activate()
                                        local v1196 = 25.879345730429208
                                        local v1197 = LocalPlayer2:GetAttribute("SpeedMultiplier") or 1
                                        u187.send("melee_attack", Fists, t44, u190.CFrame, v1196 * v1197)
                                    else
                                        Backpack:FindFirstChild("Fists").Parent = u189
                                    end
                                end
                            end
                        end
                    end
                end)
                end
            end
        end)
        t34.AutoRejoin = t24.AddThread(function()
            if u135.AutoRejoin then
                local v948 = u135.RejoinTime or 3
                local _ = 1
                if v948 < v948 * 60 * 60 then wait2(1) return end
                TeleportService:TeleportToPlaceInstance(PlaceId2, JobId2, LocalPlayer2)
                return
            end
        end, 1)
        t34.AutoJob = t24.AddThread(function()
            if u135.AutoJob then
                if t26.GetMoney().hand <= (tonumber(u135.MoneyDespoit) or 250) then
                    if u135.SelectJob ~= "Steak" then
                        if u135.SelectJob ~= "Shelf Stock" then
                            if u135.SelectJob ~= "Janitor" then
                                if u135.SelectJob == "Plant" then end
                            elseif LocalPlayer2:GetAttribute("Job") == "janitor" then
                                local v950 = t26.VerifyTool("Mop")
                                if not v950 then u187.send("leave_job") return end
                                if not Char.get_tool() then u191:EquipTool(v950) end
                                local u951 = t26.GetSkill("Janitor")
                                local v952 = t24.FindClosest(Tiles:WaitForChild("BurgerPlaceTile").BurgerPlace.Interior:FindFirstChild("Puddles"):GetChildren(), function(p143)
                                    return p143:IsA("BasePart") and (p143.Size.Magnitude > 0.001 and (p143.Transparency < 1 and (p143.Name == "LargePuddle" and u951 >= 5 or (p143.Name == "OilPuddle" and u951 >= 35 or (p143.Name == "ToxicPuddle" and u951 >= 50 or p143.Name == "NastyPuddle" and u951 >= 20)))))
                                end, u190.Position)
                                if v952 then
                                    local v953 = new4(15, 10, 15)
                                    if v953 ~= v952.Size then v952.Size = v953 end
                                    t27.Teleport(v952.Position, u189, 1)
                                end
                            else
                                if t24.GetDistanceRoot(t24.JobPositions.JanitorApply) <= 5 then
                                    u187.send("apply_for_job", workspace:WaitForChild("BurgePlaceBeacon"))
                                else
                                    t27.Teleport(t24.JobPositions.JanitorApply, u189, 1)
                                end
                            end
                        else
                            local Interior = Tiles:WaitForChild("GasStationTile"):WaitForChild("Quick11"):WaitForChild("Interior")
                            local Quick11Beacon = Interior:WaitForChild("Quick11Beacon")
                            local ShelfStockApply = t24.JobPositions.ShelfStockApply
                            if LocalPlayer2:GetAttribute("Job") == "shelf_stocker" then
                                local v957 = t26.VerifyTool("BoxTool")
                                if v957 then
                                    local v958 = Char.get_tool()
                                    local Shelves = Interior:WaitForChild("ShelfStockingJob"):WaitForChild("Shelves")
                                    local v960 = t24.FindClosest(Shelves:GetChildren(), function(p144) return p144:IsA("BasePart") and p144.Name == "Shelf" end, Quick11Beacon:GetPivot().Position)
                                    if v958 then v958.Parent = Backpack end
                                    t27.Teleport(v960:GetPivot().Position, u189, 1)
                                    local n22 = 0
                                    for _, v in pairs(v957:GetAttributes()) do
                                        if typeof(v) == "string" and v:match("Box") then n22 = n22 + 1 end
                                    end
                                    local n23 = 1
                                    for _, v in next, SkillsList.list.shelf_stocker do
                                        if SkillsList.has_skill(Data, "shelf_stocker", v.name) and v.reward_info and v.reward_info.speed_percentage_increase then
                                            n23 = n23 + v.reward_info.speed_percentage_increase / 100
                                        end
                                    end
                                    local v967 = JobData.job_info.shelf_stocker.stock_shelf_length / n23 + 0.05
                                    for _ = 1, n22 do
                                        if not v957 or not t26.VerifyTool("BoxTool") then break end
                                        u187.send("player_started_stocking_shelf", v960)
                                        wait2(v967 + 0.05)
                                        u187.send("player_stocked_shelf", v960)
                                    end
                                    delay(0.1, function()
                                        for _, v in next, workspace:GetChildren() do
                                            if v.Name == "Beacon" then v:Destroy() end
                                        end
                                    end)
                                else
                                    local v969 = nil
                                    for k, v in next, ShelfStocking.box_pickup_class.objects do
                                        if k.Name ~= "NormalBox" then
                                            local v972 = require(k:WaitForChild("AccessCheck")).can_access(Data)
                                            local v973 = v.states.stock_key.get()
                                            local v974 = v.states.stock_refresh_seconds.get()
                                            local v975 = v.states.stock_max_stock.get()
                                            if v973 ~= "" and v974 ~= -1 and v975 ~= -1 and v975 > StockTimes.get_consumed_amount(v973, v974) and v972 then
                                                v969 = k
                                                break
                                            else v969 = k end
                                        else v969 = k end
                                    end
                                    local ProximityPrompt = v969:WaitForChild("ProximityPrompt")
                                    local v977 = Char.get()
                                    if v969.Name == "NormalBox" then
                                        if t24.GetDistanceRoot(ShelfStockApply) > 3 then t27.Teleport(ShelfStockApply, u189, 1) end
                                    else
                                        t27.Teleport(t24.JobPositions.ShelfStock2, u189, 1)
                                        t24.WaitForPing()
                                        v977:PivotTo(v977:GetPivot() * new3(0, -15, 0))
                                        t24.WaitForPing()
                                        t27.Teleport(v969.Position, u189, 1)
                                        t24.WaitForPing()
                                    end
                                    local v978 = Char.get_tool()
                                    if v978 then v978.Parent = Backpack end
                                    for _ = 1, 5 do
                                        fireproximityprompt(ProximityPrompt)
                                        wait2()
                                    end
                                    if v969.Name ~= "NormalBox" then
                                        t24.WaitForPing()
                                        v977:PivotTo(v977:GetPivot() * new3(0, 25, 0))
                                    end
                                end
                            else
                                if t24.GetDistanceRoot(ShelfStockApply) <= 5 then
                                    u187.send("apply_for_job", Quick11Beacon)
                                else
                                    t27.Teleport(ShelfStockApply, u189, 1)
                                end
                            end
                        end
                    elseif LocalPlayer2:GetAttribute("Job") == "steakhouse_cook" then
                        local v980 = Char.get_tool()
                        if v980 and v980:GetAttribute("IsCookable") == true then
                            local v981 = u187.get("get_random_free_grill")
                            if v981 then
                                local v982 = SteakhouseCook.grill_class.get(v981)
                                local v983 = v982 and v982.instance
                                if v982 and v983 then
                                    local Pivot = v983.GrillArea:GetPivot()
                                    repeat
                                        if t24.GetDistanceRoot(Pivot) <= 5 then
                                            local elapsed3 = os.clock()
                                            u187.send("start_grilling_2", v983)
                                            repeat wait2(0.015) until ProgressBar.bar_enabled.get() or os.clock() - elapsed3 > 1.5
                                            if ProgressBar.bar_enabled.get() then
                                                repeat wait2(0.05) until ProgressBar.get_status_from_ui() == "Perfect" or not ProgressBar.bar_enabled.get() or not u135.AutoJob
                                                firesignal(PlayerGui.ProgressBar.ProgressBarFrame.InputFrame.FinishBar.MouseButton1Click)
                                            end
                                            return
                                        end
                                        t27.Teleport(Pivot, u189, 1)
                                        wait2(0.1)
                                    until not ProgressBar.bar_enabled.get() and (not u189:FindFirstChildWhichIsA("Tool") or u189:FindFirstChildWhichIsA("Tool"):GetAttribute("IsCookable") ~= true) or not u135.AutoJob
                                end
                            end
                        else
                            if t24.GetDistanceRoot(t24.JobPositions.Steak3) <= 5 then
                                local Fridge = Tiles.ShoppingTile.SteakHouse.Interior.Fridge
                                for _, child in pairs(Fridge:GetChildren()) do
                                    if child.Name == "Base" and child:FindFirstChildOfClass("Attachment") then
                                        fireproximityprompt(child:FindFirstChildOfClass("Attachment"):FindFirstChildOfClass("ProximityPrompt"))
                                    end
                                end
                            else
                                t27.Teleport(t24.JobPositions.Steak3, u189, 1)
                            end
                        end
                    else
                        local v989 = t24.GetDistanceRoot(t24.JobPositions.Steak2)
                        if v989 >= 2 then
                            if v989 >= 5 then
                                t27.Teleport(t24.JobPositions.Steak1, u189, 1)
                            else
                                u189:PivotTo(new3(t24.JobPositions.Steak2))
                            end
                        else
                            u187.send("apply_for_job", Tiles:WaitForChild("ShoppingTile"):WaitForChild("SteakHouse"):WaitForChild("Interior"):WaitForChild("SteakHouseBeacon"))
                        end
                    end
                else
                    t27.Deposit()
                end
                return
            end
            t27.ForceStop()
        end, 0.2)
        t34.AutoPickDroppedItem = t24.AddThread(function()
            if u135.AutoPickDroppedItem then
                for k, _ in pairs(DroppedItem.class.objects) do
                    if t24.GetDistanceRoot(k) >= 30 then return end
                    if k.Name ~= "Money" and u135.BlacklistPickDroppedItem then
                        local RarityName = ItemUtils.get_item_instance(k.Name):GetAttribute("RarityName")
                        if table.find(u135.RarityPickBlacklist or {}, RarityName) then return end
                    end
                    u187.get("pickup_dropped_item", k)
                end
                return
            end
        end, 0.2)
        u282 = function(p145, p146, p147)
            pcall(function() u191:ChangeState(Enum.HumanoidStateType.Swimming) end)
            local v997 = p146 * -1
            for _, v in next, u189:GetChildren() do
                if v:IsA("BasePart") then
                    v.AssemblyLinearVelocity = Vector3.yAxis * -1000 * v997 + Vector3.zAxis * -1000 * v997
                    v.RotVelocity = Vector3.yAxis * -1000 * v997 + Vector3.zAxis * -1000 * v997
                    v.AssemblyAngularVelocity = Vector3.zero
                    v.CanCollide = false
                    v.Anchored = false
                end
            end
            u189:PivotTo(p147 - Vector3.yAxis * (p145 and 16 or 18) + Vector3.xAxis * (math.sin(os.clock() * 4.5 * 100) * 7.5) + Vector3.zAxis * (-math.sin(os.clock() * 4.5 * 100) * 7.5))
            for _, v in next, u189:GetChildren() do
                if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                    v.CFrame = p147 + new4(64, 1000, 64)
                end
            end
        end
        t34.AntiKill = t24.AddThread(function()
            repeat
                local v1003
                repeat
                    if not RunService2.PostSimulation:Wait() then return end
                    if not u135.AntiKill then return end
                    local Head = u189:FindFirstChild("Head")
                    if not Head then return end
                    v1003 = Head:FindFirstChild("Downed") or Head:WaitForChild("Downed", 3)
                    if not v1003 then return end
                until v1003 and v1003.Enabled
                u135.Downed = true
                local Pivot = u189:GetPivot()
                if Pivot.Position.Y <= 266 then Pivot = new3(Pivot.Position.X, 255, Pivot.Position.Z) end
                local elapsed4 = os.clock()
                local elapsed5 = nil
                local n24 = 1
                local elapsed6 = os.clock()
                if os.clock() - elapsed4 > 25 then t24.Panic = false return end
                local v1009 = os.clock() - elapsed6
                local v1010 = v1009 >= 0.3
                if v1009 >= 1.8 then os.clock() end
                if u191.Health < 29 then
                    u282(v1010, n24, Pivot)
                else
                    if not elapsed5 then elapsed5 = os.clock() end
                    if os.clock() - elapsed5 <= 0.7 then
                        u282(v1010, n24, Pivot)
                    else
                        for _, v in next, u189:GetChildren() do
                            if v:IsA("BasePart") then
                                v.CFrame = Pivot
                                v.AssemblyLinearVelocity = Vector3.zero
                                v.AssemblyAngularVelocity = Vector3.zero
                            end
                        end
                        u189:PivotTo(Pivot)
                    end
                end
            until not v1003.Enabled
            u135.Downed = false
        end, 0.1)
        t34.AutoLock = t24.AddThread(function()
            local v1013 = Vehicle.get_car_player_is_in()
            if u135.AutoLock and v1013 and u191.Sit then
                if v1013:GetAttribute("OwnerUserId") == UserId then
                    local v1014 = Vehicle.class.objects[v1013]
                    if v1014 then
                        if not v1014.states.locked.get() then u187.send("lock_vehicle", v1013, true) end
                        return
                    end
                    return
                end
                return
            end
        end, 0.75)
        t34.BumpAura = t24.AddThread(function()
            if u135.BumpAura and Vehicle.get_car_player_is_in() and u191.Sit then
                for _, v in next, Char.get_all() do
                    if v ~= u189 and t24.IsAlive(v) and t24.GetDistanceRoot(v) < 100 then
                        u187.send("run_over", Vehicle.get_car_player_is_in(), v, new4(80, 80, 80))
                    end
                end
                return
            end
        end, 0.2)
        t34.Snap = t24.AddThread(function()
            if u135.Snap and t24.IsAlive(u189) then
                local v1017 = u135.YOffsetSnap or 1
                if v1017 ~= n14 then n14 = v1017 end
                local PositionY = u190.Position.Y
                local v1019 = u177.Y - v1017 - PositionY
                u189:PivotTo(u190.CFrame * CFrame.new(0, v1019, 0))
                return
            end
        end)
        t34.VehicleNoclip = t24.AddThread(function()
            if u135.VehicleNoclip and t24.IsAlive(u189) then
                local car = t24.FindVehicle()
                if car then
                    local saved = u135.VehicleNoclipParts
                    if not saved then
                        saved = {}
                        for _, d in pairs(car:GetDescendants()) do
                            if d:IsA("BasePart") then saved[d] = d.CanCollide end
                        end
                        u135.VehicleNoclipParts = saved
                    end
                    local bbCF, bbSize = car:GetBoundingBox()
                    local bottom = bbCF.Position.Y - bbSize.Y / 2
                    for d, orig in pairs(saved) do
                        if d.Parent then
                            local nearGround = (d.Position.Y - d.Size.Y / 2) < bottom + 1.5
                            d.CanCollide = nearGround and orig or false
                        end
                    end
                    return
                end
            end
            local saved = u135.VehicleNoclipParts
            if saved then
                for d, c in pairs(saved) do
                    if d.Parent then d.CanCollide = c end
                end
                u135.VehicleNoclipParts = nil
            end
        end, 0.2)
        t34.CustomSpeed = t24.AddThread(function()
            if u135.CustomSpeed then
                if u191:GetAttribute("TargetWalkSpeed") ~= 30 and u191.WalkSpeed ~= 30 then
                    u191.WalkSpeed = 30
                    u191:SetAttribute("TargetWalkSpeed", 30)
                end
                return
            end
        end, 0.25)
        t34.CustomJumpPower = t24.AddThread(function()
            if u135.CustomJumpPower then
                local v1020 = u135.CustomJumpPowerValue or 7.2
                if v1020 ~= u191.JumpHeight then u191.JumpHeight = v1020 end
                return
            end
        end, 0.25)

        local function AutoShot_GetTool()
            local tool = Char.get_tool()
            if tool and (tool:HasTag("Gun") or tool:GetAttribute("AmmoType") ~= nil) then
                return tool
            end
            return nil
        end

        local function AutoShot_IsReloading(pTool)
            for _, name in ipairs({ "Reloading", "IsReloading", "Reload" }) do
                if pTool:GetAttribute(name) == true then return true end
            end
            return false
        end

        local function AutoShot_HasAmmo(pTool)
            for _, name in ipairs({ "Ammo", "CurrentAmmo", "AmmoCount", "MagAmmo", "LoadedAmmo", "ClipAmmo", "Bullets" }) do
                local v = pTool:GetAttribute(name)
                if type(v) == "number" then return v > 0 end
            end
            return true
        end

        local function AutoShot_FindTarget(range)
            local myPos = u190.Position
            local closest, closestPart = nil, nil
            local closestDist = range
            for _, v in next, Char.get_all() do
                if v ~= u189 and t24.IsAlive(v) then
                    local player = Players:GetPlayerFromCharacter(v)
                    if player
                        and not player:GetAttribute("InMenuCharacterCreator")
                        and not player:GetAttribute("InSplashScreen")
                        and not player:GetAttribute("IsSafeZoneProtected")
                        and not player:GetAttribute("IsSpawnProtected")
                        and not (u135.IgnoreFriend and player:IsFriendsWith(UserId)) then
                        local part = v:FindFirstChild(u135.SelectPart or "Head")
                            or v:FindFirstChild("Head")
                            or v:FindFirstChildWhichIsA("BasePart")
                        if part then
                            local d = (part.Position - myPos).Magnitude
                            if d <= closestDist then
                                closest = v
                                closestPart = part
                                closestDist = d
                            end
                        end
                    end
                end
            end
            return closest, closestPart
        end

        local function AutoShot_SegmentHitsBox(a, b, cf, size)
            local la = cf:PointToObjectSpace(a)
            local lb = cf:PointToObjectSpace(b)
            local d = lb - la
            local half = size / 2
            local tmin, tmax = 0, 1
            for _, axis in ipairs({ "X", "Y", "Z" }) do
                local o = la[axis]
                local dir = d[axis]
                local h = half[axis]
                if math.abs(dir) < 1e-6 then
                    if o < -h or o > h then return false end
                else
                    local t1 = (-h - o) / dir
                    local t2 = (h - o) / dir
                    if t1 > t2 then t1, t2 = t2, t1 end
                    tmin = math.max(tmin, t1)
                    tmax = math.min(tmax, t2)
                    if tmin > tmax then return false end
                end
            end
            return true
        end

        local function AutoShot_CarBlocks(from, to)
            local folder = workspace:FindFirstChild("Vehicles")
            if not folder then return false end
            local own = t24.FindVehicle()
            for _, car in ipairs(folder:GetChildren()) do
                if car:IsA("Model") and car ~= own then
                    local cf, size = car:GetBoundingBox()
                    if AutoShot_SegmentHitsBox(from, to, cf, size) then return true end
                end
            end
            return false
        end

        local function AutoShot_Tracer(fromPos, toPos)
            local function makeAnchor(pos)
                local part = new("Part")
                part.Size = Vector3.new(0.1, 0.1, 0.1)
                part.Transparency = 1
                part.Anchored = true
                part.CanCollide = false
                part.CanQuery = false
                part.CanTouch = false
                part.CastShadow = false
                part.Position = pos
                part.Parent = workspace
                local att = new("Attachment")
                att.Parent = part
                return part, att
            end
            local partA, attA = makeAnchor(fromPos)
            local partB, attB = makeAnchor(toPos)
            local beam = new("Beam")
            beam.Attachment0 = attA
            beam.Attachment1 = attB
            beam.Width0 = 0.08
            beam.Width1 = 0.08
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 220, 80))
            beam.LightEmission = 1
            beam.FaceCamera = true
            beam.Parent = partA
            Debris:AddItem(partA, 0.15)
            Debris:AddItem(partB, 0.15)
        end

        t34.AutoShot = function()
            while u135.AutoShot do
                pcall(function()
                    if not u189 or not u190 or not u191 or not t24.IsAlive(u189) then return end
                    local tool = AutoShot_GetTool()
                    if not tool then return end
                    if AutoShot_IsReloading(tool) or not AutoShot_HasAmmo(tool) then return end
                    local target, part = AutoShot_FindTarget(u135.AutoShotRange or 100)
                    if not target or not part then return end
                    t24.TargetAim = target
                    if not u135.WallBang then
                        if t24.IsBehindWall(u190.Position, part.Position) or AutoShot_CarBlocks(u190.Position, part.Position) then
                            t24.TargetAim = nil
                            return
                        end
                    end
                    local handle = tool:FindFirstChild("Handle")
                    local muzzle = handle and handle.Position or u190.Position
                    tool:Activate()
                    AutoShot_Tracer(muzzle, part.Position)
                end)
                wait2(u135.AutoShotInterval or 0.15)
            end
        end

        local js = {
            gui = nil, bg = nil, thumb = nil,
            active = nil, dir = Vector2.zero,
            inCar = false
        }

        local function js_GetMode()
            return u135.VehicleControlMode or "PC"
        end

        local function js_ShouldShow()
            if not u135.VehicleJoystick then return false end
            return js_GetMode() == "Mobile"
        end

        local function js_BuildUI()
            if js.gui then return end
            if not js_ShouldShow() then return end

            local gui = new("ScreenGui")
            gui.Name = "VehicleJoystick"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.DisplayOrder = 100
            gui.Parent = gethui and gethui() or PlayerGui
            js.gui = gui

            local bg = new("Frame")
            bg.Name = "Background"
            bg.Size = UDim2.fromOffset(160, 160)
            bg.Position = UDim2.new(0, 40, 1, -200)
            bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            bg.BackgroundTransparency = 0.4
            bg.BorderSizePixel = 0
            bg.Active = true
            bg.Parent = gui
            js.bg = bg
            new("UICorner", bg).CornerRadius = UDim.new(1, 0)

            local thumb = new("Frame")
            thumb.Name = "Thumb"
            thumb.Size = UDim2.fromOffset(65, 65)
            thumb.AnchorPoint = new2(0.5, 0.5)
            thumb.Position = UDim2.fromScale(0.5, 0.5)
            thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            thumb.BackgroundTransparency = 0.1
            thumb.BorderSizePixel = 0
            thumb.Parent = bg
            js.thumb = thumb
            new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

            bg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Touch
                    or i.UserInputType == Enum.UserInputType.MouseButton1 then
                    js.active = i
                    js_MoveThumb(i.Position)
                end
            end)
        end

        local function js_DestroyUI()
            if js.gui then
                js.gui:Destroy()
                js.gui, js.bg, js.thumb = nil, nil, nil
                js.dir = Vector2.zero
                js.active = nil
            end
        end

        function js_MoveThumb(pos)
            if not js.bg or not js.bg.Parent or not js.thumb or not js.thumb.Parent then return end
            local center = js.bg.AbsolutePosition + (js.bg.AbsoluteSize / 2)
            local off = Vector2.new(pos.X - center.X, pos.Y - center.Y)
            local radius = u135.VehicleJoystickRadius or 55
            local dead = 8
            local dist = math.min(off.Magnitude, radius)
            if dist > dead then
                local d = off.Unit
                js.thumb.Position = UDim2.fromScale(0.5, 0.5) + UDim2.fromOffset(d.X * dist, d.Y * dist)
                js.dir = Vector2.new(d.X, d.Y)
            else
                js.dir = Vector2.zero
                js.thumb.Position = UDim2.fromScale(0.5, 0.5)
            end
        end

        UserInputService.InputChanged:Connect(function(i)
            if js.active and (i == js.active or i.UserInputType == Enum.UserInputType.MouseMovement) then
                js_MoveThumb(i.Position)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if js.active and i == js.active then
                if js.thumb then js.thumb.Position = UDim2.fromScale(0.5, 0.5) end
                js.dir = Vector2.zero
                js.active = nil
            end
        end)

        spawn(function()
            while wait2(0.2) do
                pcall(function()
                    if not u135.VehicleJoystick and not js.gui and not js.inCar then return end
                    local car = Vehicle.get_car_player_is_in()
                    local hasCar = car ~= nil

                    if hasCar and not js.inCar then
                        js.inCar = true
                    elseif not hasCar and js.inCar then
                        js.inCar = false
                        js_DestroyUI()
                        if u190 then
                            u190.AssemblyLinearVelocity = Vector3.zero
                            u190.AssemblyAngularVelocity = Vector3.zero
                        end
                    end

                    if js.inCar and js_ShouldShow() then
                        if not js.gui then js_BuildUI() end
                    elseif js.gui then
                        js_DestroyUI()
                    end
                end)
            end
        end)

        RunService2.Heartbeat:Connect(function(dt)
            if not u135.VehicleJoystick or not js.inCar then return end
            if js_GetMode() ~= "Mobile" then return end

            local car = Vehicle.get_car_player_is_in()
            if not car then return end

            local chassis = car.PrimaryPart
            if not chassis then return end

            if js.dir.Magnitude < 0.05 then
                local lv = chassis.AssemblyLinearVelocity
                chassis.AssemblyLinearVelocity = new4(0, lv.Y, 0)
                chassis.AssemblyAngularVelocity = Vector3.zero
                return
            end

            pcall(function()
                local speed = u135.VehicleJoystickSpeed or 35
                local turn = u135.VehicleJoystickTurn or 14
                local cur = chassis.CFrame
                local forward = Vector3.new(cur.LookVector.X, 0, cur.LookVector.Z)
                if forward.Magnitude < 0.01 then return end
                forward = forward.Unit
                local throttle = math.clamp(-js.dir.Y, -1, 1)
                local steer = math.clamp(js.dir.X, -1, 1)
                local right = Vector3.new(cur.RightVector.X, 0, cur.RightVector.Z).Unit
                chassis.AssemblyAngularVelocity = Vector3.new(0, -steer * math.min(turn, 6), 0)
                local lv = chassis.AssemblyLinearVelocity
                local lvH = Vector3.new(lv.X, 0, lv.Z)
                local fwdSpd = lvH:Dot(forward)
                local sideSpd = lvH:Dot(right)
                fwdSpd = fwdSpd + (throttle * speed - fwdSpd) * math.min(dt * 6, 1)
                sideSpd = sideSpd * (1 - math.min(dt * 10, 1))
                local nv = forward * fwdSpd + right * sideSpd
                chassis.AssemblyLinearVelocity = new4(nv.X, lv.Y, nv.Z)
            end)
        end)

        -- ============================================================
        -- ESP Rarity Module (embedded)
        -- ============================================================
        do
            local ESP_Rarity = {}

            ESP_Rarity.RarityColors = {
                Common    = Color3.fromRGB(255, 255, 255),
                Uncommon  = Color3.fromRGB(99, 255, 52),
                Rare      = Color3.fromRGB(51, 170, 255),
                Epic      = Color3.fromRGB(237, 44, 255),
                Legendary = Color3.fromRGB(255, 150, 0),
                Omega     = Color3.fromRGB(255, 20, 51),
            }

            ESP_Rarity.Config = {
                ScanInterval        = 0.5,
                FillTransparency    = 0.6,
                OutlineTransparency = 0,
                IncludeSelf         = false,
                ShowInBackpack      = true,
                ShowHeldOnly        = false,
            }

            local ItemHighlightCache = {}

            local function GetRarity(itemModel)
                return itemModel:GetAttribute("RarityName") or "Common"
            end

            local function ApplyItemHighlight(itemModel)
                if not itemModel then return end
                if not u135.ESP_Rarity_Enable then return end
                if not (itemModel:IsA("Tool") or itemModel:IsA("Model")) then return end

                local rarity = GetRarity(itemModel)
                local color  = ESP_Rarity.RarityColors[rarity] or Color3.fromRGB(255, 255, 255)

                local highlight = ItemHighlightCache[itemModel]
                if not highlight or not highlight.Parent then
                    highlight = Instance.new("Highlight")
                    highlight.Name                = "RarityHighlight_Test"
                    highlight.Adornee             = itemModel
                    highlight.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillTransparency    = ESP_Rarity.Config.FillTransparency
                    highlight.OutlineTransparency = ESP_Rarity.Config.OutlineTransparency
                    highlight.FillColor           = color
                    highlight.OutlineColor        = color
                    highlight.Parent              = itemModel
                    ItemHighlightCache[itemModel] = highlight
                else
                    highlight.FillColor    = color
                    highlight.OutlineColor = color
                    highlight.Adornee      = itemModel
                end
            end

            local function CleanupItemHighlight(itemModel)
                local hl = ItemHighlightCache[itemModel]
                if hl then hl:Destroy() ItemHighlightCache[itemModel] = nil end
            end

            local function ScanPlayerItems(player)
                if player == Players.LocalPlayer and not ESP_Rarity.Config.IncludeSelf then return end
                local character = player.Character
                if not character then return end
                for _, child in ipairs(character:GetChildren()) do
                    if child:IsA("Tool") or child:IsA("Model") then ApplyItemHighlight(child) end
                end
                if ESP_Rarity.Config.ShowInBackpack and not ESP_Rarity.Config.ShowHeldOnly then
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        for _, child in ipairs(backpack:GetChildren()) do
                            if child:IsA("Tool") or child:IsA("Model") then ApplyItemHighlight(child) end
                        end
                    end
                end
            end

            local function ScanAllPlayers()
                for model, hl in pairs(ItemHighlightCache) do
                    if not model.Parent or not hl.Parent then
                        if hl then hl:Destroy() end
                        ItemHighlightCache[model] = nil
                    end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    pcall(ScanPlayerItems, player)
                end
            end

            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function()
                    task.wait(1); pcall(ScanPlayerItems, player)
                end)
            end)

            Players.LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(1)
                char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") or child:IsA("Model") then ApplyItemHighlight(child) end
                end)
                char.ChildRemoved:Connect(CleanupItemHighlight)
            end)

            if Players.LocalPlayer.Character then
                Players.LocalPlayer.Character.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") or child:IsA("Model") then ApplyItemHighlight(child) end
                end)
                Players.LocalPlayer.Character.ChildRemoved:Connect(CleanupItemHighlight)
            end

            task.spawn(function()
                while task.wait(ESP_Rarity.Config.ScanInterval) do
                    if u135.ESP_Rarity_Enable then
                        pcall(ScanAllPlayers)
                    end
                end
            end)

            ESP_Rarity.Scan     = ScanAllPlayers
            ESP_Rarity.ClearAll = function()
                for model, hl in pairs(ItemHighlightCache) do
                    if hl then hl:Destroy() end
                    ItemHighlightCache[model] = nil
                end
            end
            ESP_Rarity.List = function()
                for model, hl in pairs(ItemHighlightCache) do
                    print(hl.FillColor, "|", model:GetFullName())
                end
            end
            ESP_Rarity.SpawnTestItem = function(rarity, position)
                rarity   = rarity or "Legendary"
                position = position or (Players.LocalPlayer.Character
                    and Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8).Position)
                if not position then return end
                local model = Instance.new("Model"); model.Name = "TestItem_" .. rarity
                local part = Instance.new("Part")
                part.Size = Vector3.new(1, 1, 1); part.Position = position; part.Anchored = true
                part.Color = ESP_Rarity.RarityColors[rarity] or Color3.new(1, 1, 1)
                part.Material = Enum.Material.Neon; part.Parent = model
                model:SetAttribute("RarityName", rarity)
                model.PrimaryPart = part; model.Parent = workspace
                ApplyItemHighlight(model)
                task.delay(10, function()
                    if model and model.Parent then CleanupItemHighlight(model) model:Destroy() end
                end)
                return model
            end
            ESP_Rarity.SetRarityColor = function(rarity, color)
                ESP_Rarity.RarityColors[rarity] = color
            end

            getgenv().ESP_Rarity        = ESP_Rarity
            getgenv().ItemHighlightTest = ESP_Rarity
        end

        local function PlayIntro()
            local gui = Instance.new("ScreenGui")
            gui.Name = "SunixiaIntro"
            gui.ResetOnSpawn = false
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.DisplayOrder = 2147483646
            gui.IgnoreGuiInset = true
            gui.Parent = gethui and gethui() or PlayerGui

            local bg = Instance.new("Frame")
            bg.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            bg.BackgroundTransparency = 1
            bg.BorderSizePixel = 0
            bg.Size = UDim2.fromScale(1, 1)
            bg.Parent = gui

            local title = Instance.new("TextLabel")
            title.AnchorPoint = Vector2.new(0.5, 0.5)
            title.Position = UDim2.fromScale(0.5, 0.5)
            title.Size = UDim2.fromScale(0.8, 0.2)
            title.BackgroundTransparency = 1
            title.RichText = true
            title.TextScaled = true
            title.Text = ""
            title.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)
            title.Parent = bg

            local sizeLimit = Instance.new("UITextSizeConstraint")
            sizeLimit.MaxTextSize = 64
            sizeLimit.MinTextSize = 14
            sizeLimit.Parent = title

            local scale = Instance.new("UIScale")
            scale.Scale = 0.9
            scale.Parent = title

            local introTitle = "Synixia Hub"
            local neonRed = Color3.fromRGB(255, 40, 40)
            local darkRed = Color3.fromRGB(120, 0, 0)
            local letterDelay, letterFade, outFade, totalTime = 0.14, 0.3, 0.5, 4

            local chars = {}
            for _, cp in utf8.codes(introTitle) do
                table.insert(chars, utf8.char(cp))
            end

            local start = os.clock()
            while true do
                local t = os.clock() - start
                if t >= totalTime then break end
                local parts = {}
                for i, ch in ipairs(chars) do
                    local p = math.clamp((t - (i - 1) * letterDelay) / letterFade, 0, 1)
                    local wave = (math.sin(t * 4 - i * 0.7) + 1) / 2
                    local c = neonRed:Lerp(darkRed, wave)
                    parts[i] = string.format(
                        '<font color="rgb(%d,%d,%d)" transparency="%.2f">%s</font>',
                        math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255),
                        1 - (1 - (1 - p) ^ 3), ch
                    )
                end
                title.Text = table.concat(parts)
                local bgIn = math.clamp(t / 0.4, 0, 1)
                local outAlpha = math.clamp((t - (totalTime - outFade)) / outFade, 0, 1)
                title.TextTransparency = outAlpha
                bg.BackgroundTransparency = 1 - 0.85 * bgIn * (1 - outAlpha)
                scale.Scale = 0.9 + 0.1 * math.clamp(t / 1.6, 0, 1)
                task.wait()
            end
            gui:Destroy()
        end

        PlayIntro()

        local MacLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Wicikk/WMacLib/main/WMacLib.lua"))()

        u287 = MacLib:Window({
            Title = "Synixia Hub - [Block spin]",
            Subtitle = "you are a star shining on nights away",
            Size = UserInputService.TouchEnabled and fromOffset(550, 325) or fromOffset(850, 530),
            Theme = "Dark",
            AcrylicBlur = false,
            Keybind = Enum.KeyCode.LeftAlt
        })

        local ToggleButtonGui = Instance.new("ScreenGui")
        ToggleButtonGui.Name = "AexionToggleButton"
        ToggleButtonGui.ResetOnSpawn = false
        ToggleButtonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ToggleButtonGui.DisplayOrder = 2147483647
        ToggleButtonGui.IgnoreGuiInset = true
        ToggleButtonGui.Parent = gethui and gethui() or PlayerGui

        local ToggleButton = Instance.new("ImageButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Image = "rbxassetid://102698274674617"
        ToggleButton.Size = UDim2.fromOffset(48, 48)
        ToggleButton.Position = UDim2.new(0, 20, 0.5, -24)
        ToggleButton.BackgroundTransparency = 1
        ToggleButton.BorderSizePixel = 0
        ToggleButton.AutoButtonColor = false
        ToggleButton.Active = true
        ToggleButton.Draggable = false
        ToggleButton.Parent = ToggleButtonGui

        local ToggleButtonCorner = Instance.new("UICorner")
        ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
        ToggleButtonCorner.Parent = ToggleButton

        local ToggleButtonScale = Instance.new("UIScale")
        ToggleButtonScale.Scale = 1
        ToggleButtonScale.Parent = ToggleButton

        local draggingToggle = false
        local dragStartToggle = nil
        local startPosToggle = nil
        local dragMoved = false

        local function clampPosition(pos)
            local viewportSize = workspace.CurrentCamera.ViewportSize
            local btnSize = ToggleButton.AbsoluteSize
            if btnSize.X <= 0 then btnSize = Vector2.new(48, 48) end
            local xAbs = pos.X.Offset
            local yAbs = pos.Y.Offset
            local maxX = viewportSize.X - btnSize.X
            local maxY = viewportSize.Y - btnSize.Y
            if xAbs < 0 then xAbs = 0 end
            if yAbs < 0 then yAbs = 0 end
            if xAbs > maxX then xAbs = maxX end
            if yAbs > maxY then yAbs = maxY end
            return UDim2.new(0, xAbs, 0, yAbs)
        end

        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingToggle = true
                dragMoved = false
                dragStartToggle = input.Position
                startPosToggle = ToggleButton.Position
            end
        end)

        ToggleButton.InputChanged:Connect(function(input)
            if draggingToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStartToggle
                if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
                    dragMoved = true
                end
                local newX = startPosToggle.X.Offset + delta.X
                local newY = startPosToggle.Y.Offset + delta.Y
                ToggleButton.Position = clampPosition(UDim2.new(0, newX, 0, newY))
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if draggingToggle then
                    draggingToggle = false
                    if not dragMoved then
                        local currentState = u287:GetState()
                        u287:SetState(not currentState)
                    end
                    ToggleButton.Position = clampPosition(ToggleButton.Position)
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not draggingToggle then
                ToggleButton.Position = clampPosition(ToggleButton.Position)
            end
        end)

        ToggleButton.MouseEnter:Connect(function()
            local TS = game:GetService("TweenService")
            TS:Create(ToggleButtonScale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Scale = 1.12 }):Play()
        end)

        ToggleButton.MouseLeave:Connect(function()
            local TS = game:GetService("TweenService")
            TS:Create(ToggleButtonScale, TweenInfo.new(0.15, Enum.EasingStyle.Sine), { Scale = 1 }):Play()
        end)

        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            ToggleButton.Position = clampPosition(ToggleButton.Position)
        end)

        local tabGroups = {
            General = u287:TabGroup(),
            Combat = u287:TabGroup(),
            MarketPlace = u287:TabGroup(),
            Client = u287:TabGroup(),
            Vehicle = u287:TabGroup(),
            Configuration = u287:TabGroup()
        }

        t47 = {
            General = tabGroups.General:Tab({ Name = "General", Selected = true }),
            Aimbot = tabGroups.Combat:Tab({ Name = "Aimbot" }),
            Visual = tabGroups.Combat:Tab({ Name = "Visual" }),
            Marketplace = tabGroups.MarketPlace:Tab({ Name = "Marketplace" }),
            LocalPlayers = tabGroups.Client:Tab({ Name = "LocalPlayers" }),
            Vehicle = tabGroups.Vehicle:Tab({ Name = "Vehicle" }),
            Setting = tabGroups.Configuration:Tab({ Name = "Setting" })
        }

        u296 = function(section, title, subtitle)
            if title or subtitle then
                section:Paragraph({ Header = title or "", Body = subtitle or "" })
            end
            return section
        end

        v297 = function(tab, title, subtitle)
            local section = tab:Section({})
            if title or subtitle then
                section:Paragraph({ Header = title or "", Body = subtitle or "" })
            end
            return section
        end

        v298 = function(section, title, subtitle)
            local label = section:Label({ Text = title or "N/A" })
            return setmetatable({}, {
                __index = function(_, key)
                    if key == "Text" then return nil end
                    return label[key]
                end,
                __newindex = function(_, key, value)
                    if key == "Text" then
                        label:UpdateName(tostring(value))
                    else
                        rawset(_, key, value)
                    end
                end
            })
        end

        v299 = function(section, title, subtitle, flag, callback)
            local taskHandle = nil
            local defaultValue = u135[flag]
            if defaultValue == nil then defaultValue = false end
            local toggle = section:Toggle({
                Name = title,
                Default = defaultValue,
                Callback = function(value)
                    u135[flag] = value
                    if callback and typeof(callback) == "function" then callback(value) end
                    if not value and taskHandle then cancel(taskHandle) taskHandle = nil end
                    if value and t34[flag] then taskHandle = spawn(xpcall, t34[flag], warn) end
                end
            })
            return setmetatable({}, {
                __index = function(_, key)
                    if key == "Value" then return toggle:GetState() end
                    return toggle[key]
                end,
                __newindex = function(_, key, value)
                    if key == "Value" then
                        toggle:UpdateState(value)
                    else
                        rawset(_, key, value)
                    end
                end
            })
        end

        v300 = function(section, title, subtitle, options, flag)
            options = options or {}
            local index = 1
            local current = u135[flag]
            if current ~= nil then
                for i, value in ipairs(options) do
                    if value == current then index = i break end
                end
            end
            return section:Dropdown({
                Name = title,
                Options = options,
                Default = index,
                Callback = function(value)
                    u135[flag] = value
                    if t34[flag] then spawn(xpcall, t34[flag], warn) end
                end
            })
        end

        v301 = function(section, title, subtitle, flag, defaultValue)
            local value = u135[flag]
            if value == nil then value = defaultValue end
            return section:Input({
                Name = title,
                Placeholder = "...",
                Default = value and tostring(value) or "",
                AcceptedCharacters = "All",
                Callback = function(newValue)
                    u135[flag] = tostring(newValue)
                end
            })
        end

        v302 = function(section, title, subtitle)
            local buttons = {}
            buttons.Add = function(self, name, state, callback)
                section:Button({
                    Name = name or "Button",
                    Callback = callback or function() end
                })
                return self
            end
            return buttons
        end

        v303 = function(section, title, subtitle, minimum, maximum, defaultValue, flag, callback)
            minimum = minimum or 1
            maximum = maximum or 1
            defaultValue = u135[flag] or defaultValue or minimum
            return section:Slider({
                Name = title,
                Minimum = minimum,
                Maximum = maximum,
                Default = defaultValue,
                Round = 1,
                Callback = function(value)
                    u135[flag] = value
                    if callback and typeof(callback) == "function" then callback(value) end
                end
            })
        end

        v304 = function(section, title, subtitle, options, flag, multi)
            options = options or {}
            if multi then
                local defaults = u135[flag]
                if type(defaults) ~= "table" then defaults = {} end
                return section:Dropdown({
                    Name = title,
                    Options = options,
                    Default = defaults,
                    Multi = true,
                    Callback = function(value)
                        local selected = {}
                        if type(value) == "table" then
                            for option, enabled in pairs(value) do
                                if enabled then table.insert(selected, option) end
                            end
                        elseif value ~= nil then
                            table.insert(selected, value)
                        end
                        u135[flag] = selected
                    end
                })
            end
            local index = 1
            local current = u135[flag]
            if current ~= nil then
                for i, value in ipairs(options) do
                    if value == current then index = i break end
                end
            end
            return section:Dropdown({
                Name = title,
                Options = options,
                Default = index,
                Callback = function(value)
                    u135[flag] = value
                end
            })
        end

        local v305 = v297(t47.General, "User Networth", "Total cash: on hand & in your ATM.")
        u306 = v298(v305, "ATM Balance", "Total funds in your ATM.")
        u307 = v298(v305, "Hand Balance", "Total funds in your account.")

        spawn(function()
            while wait2(1) do
                local v1111 = t26.GetMoney()
                u306.Text = Util.comma_format_number(v1111.bank) .. "$"
                u307.Text = Util.comma_format_number(v1111.hand) .. "$"
            end
        end)

        local v308 = v297(t47.General, "Auto Rejoin", "Automatic to rejoin when time is enough.")
        v303(v308, "Rejoin Time", "Select Rejoin Time (Hour)", 1, 4, u135.RejoinTime or 1, "RejoinTime")
        v299(v308, "Auto Rejoin", "Enabled to Automatic Rejoin", "AutoRejoin")

        local v309 = v297(t47.General, "ATM Action", "You can do all action with atm when you near atm.")
        v301(v309, "Enter Money", "Money amount to action with atm.", "MoneyActionATM")
        v302(v309, "ATM Money", "You can withdraw and deposit but need to near atm."):Add("Deposit", "Primary", function()
            u187.get("transfer_funds", "hand", "bank", tonumber(u135.MoneyActionATM))
        end):Add("Withdraw", "Primary", function()
            u187.get("transfer_funds", "bank", "hand", tonumber(u135.MoneyActionATM))
        end)

        do
            local fakeMoneyAmount = nil
            local fakeMoneyActive = false
            local fakeMoneyOriginal = nil

            local function getFakeMoneyLabel()
                local hud = PlayerGui:FindFirstChild("TopRightHud")
                local holder = hud and hud:FindFirstChild("Holder")
                local frame = holder and holder:FindFirstChild("Frame")
                if not frame then return nil end
                local child = frame:GetChildren()[10]
                if child and (child:IsA("TextLabel") or child:IsA("TextButton")) then
                    return child
                end
                return nil
            end

            local function applyFakeMoney()
                local label = getFakeMoneyLabel()
                if not label or fakeMoneyAmount == nil then return end
                if fakeMoneyOriginal == nil then
                    fakeMoneyOriginal = label.Text
                end
                label.Text = tostring(fakeMoneyAmount)
            end

            local function restoreFakeMoney()
                local label = getFakeMoneyLabel()
                if label and fakeMoneyOriginal ~= nil then
                    label.Text = fakeMoneyOriginal
                end
                fakeMoneyOriginal = nil
            end

            spawn(function()
                while wait2(0.2) do
                    if fakeMoneyActive then
                        pcall(applyFakeMoney)
                    end
                end
            end)

            local fakeMoneySection = v297(t47.Visual, "Fake Money", "Change the cash shown on HUD (visual only).")
            fakeMoneySection:Input({
                Name = "Amount",
                Placeholder = "100000000",
                AcceptedCharacters = "All",
                Callback = function(value)
                    fakeMoneyAmount = tonumber(value)
                end
            })
            v302(fakeMoneySection, "Fake Money", "Confirm to apply, Reset to restore."):Add("Confirm", "Primary", function()
                if fakeMoneyAmount == nil then
                    u287:Notify({
                        Title = "Fake Money",
                        Description = "Please enter a valid number.",
                        Lifetime = 3
                    })
                    return
                end
                if not getFakeMoneyLabel() then
                    u287:Notify({
                        Title = "Fake Money",
                        Description = "HUD label not found.",
                        Lifetime = 3
                    })
                    return
                end
                fakeMoneyActive = true
                pcall(applyFakeMoney)
            end):Add("Reset", "Primary", function()
                fakeMoneyActive = false
                pcall(restoreFakeMoney)
            end)
        end

        local v310 = v297(t47.General, "Job Farm", "Automatic to Farm Job.")
        v300(v310, "Select Job", "Select Job to work.", { "Steak", "Shelf Stock", "Janitor" }, "SelectJob")
        v299(v310, "Auto Job", "Automatic to farm job you selected.", "AutoJob")
        v299(v310, "Auto Fish", "Auto throw and reel when fishing.", "AutoFish")

        local v311 = v297(t47.General, "Setting", "Setting Job Farm.")
        v301(v311, "Enter Money Amount", "Amount to deposit when farm Job.", "MoneyDespoit", 250)
        v303(v311, "Tween Speed", "Speed when your Character is tweening.", 1, 55, 1, "TweenSpeed")
        v303(v311, "Vehicle Speed", "Speed when your Vehicle is tweening.", 1, 150, 1, "VehicleSpeed")

        local v312 = v297(t47.Aimbot, "Aim assistant", "A smart aim assistant.")
        v299(v312, "Silent Aim", "Prediction target head for aim assist.", "AimAssist")
        v299(v312, "Wall Bang", "Can shoot when behind wall.", "WallBang")

        local v313 = v297(t47.Aimbot, "Setting", "Configuration settings.")
        v299(v313, "Ignore Friend", "Aimbot ignores your friend.", "IgnoreFriend")
        v299(v313, "MultiShot", "When you shoot you will lose x2 ammo.", "MultiShot")
        v300(v313, "Select Part", "Part when aim assist working.", { "Head", "UpperTorso", "HumanoidRootPart" }, "SelectPart")
        v300(v313, "Select Position", "Position of pov circle.", { "Cursor", "Screen" }, "SelectPositionFov")
        v303(v313, "FOV Radius", "FOV radius.", 200, 800, 200, "FOVRadius")

        local v314 = v297(t47.Aimbot, "Gun Modifier", "Modifies your gun.")
        v302(v314, "Customize Your Gun", "Personalize your weapon. (Need to Equip!)"):Add("Modify", "Primary", function()
            local v1114 = Char.get_tool()
            if v1114 and v1114:HasTag("Gun") then
                v1114:SetAttribute("fire_rate", u135.FireRateGun or v1114:GetAttribute("fire_rate"))
                v1114:SetAttribute("accuracy", u135.AccuracyGun or v1114:GetAttribute("accuracy"))
                v1114:SetAttribute("Recoil", u135.RecoilGun or v1114:GetAttribute("Recoil"))
                v1114:SetAttribute("Durability", u135.DurabilityGun or v1114:GetAttribute("Durability"))
                return
            end
        end)
        v303(v314, "Fire rate", "Fire rate when you shoot your gun.", 1, 3000, 1, "FireRateGun")
        v303(v314, "Recoil", "Recoil when you shoot.", 0, 10, 0, "RecoilGun")
        v303(v314, "Accuracy", "Accuracy of your gun.", 0.1, 1, 0.1, "AccuracyGun")
        v303(v314, "Durability", "Durability of your gun.", 1, 100, 1, "DurabilityGun")

        local v314_1 = v297(t47.Aimbot, "Auto Shot", "Automatically fires at the nearest target in a screen-space radius.")
        v299(v314_1, "Auto Shot", "เปิด/ปิดการยิงอัตโนมัติ", "AutoShot")
        v303(v314_1, "Detection Range", "รัศมีตรวจจับเป้าหมายรอบตัว (studs)", 10, 1000, 100, "AutoShotRange")
        v303(v314_1, "Fire Interval", "ช่วงเวลาระหว่างการยิงแต่ละรอบ (วินาที)", 0.05, 2, 0.15, "AutoShotInterval")
        do
            local rangePart = new("Part")
            rangePart.Name = "AutoShotRange"
            rangePart.Shape = Enum.PartType.Cylinder
            rangePart.Anchored = true
            rangePart.CanCollide = false
            rangePart.CanQuery = false
            rangePart.CanTouch = false
            rangePart.CastShadow = false
            rangePart.Material = Enum.Material.Neon
            rangePart.Color = Color3.fromRGB(255, 80, 80)
            rangePart.Transparency = 1
            rangePart.Size = Vector3.new(0.2, 2, 2)
            rangePart.Parent = workspace
            RunService2.RenderStepped:Connect(function()
                if not u135.AutoShot or not u190 then
                    if rangePart.Transparency ~= 1 then rangePart.Transparency = 1 end
                    return
                end
                local range = u135.AutoShotRange or 100
                local p = u190.Position
                rangePart.Transparency = 0.75
                rangePart.Size = Vector3.new(0.2, range * 2, range * 2)
                rangePart.CFrame = CFrame.new(p.X, p.Y - 3, p.Z) * CFrame.Angles(0, 0, math.rad(90))
            end)
        end

        local v315 = v297(t47.Visual, "Visual", "Customize visuals and ESP features.")
        v299(v315, "Box", "Draw 2D boxes around players.", "Box")
        v299(v315, "Hpbar", "Display health bars above players.", "Hpbar")
        v299(v315, "Name", "Show player names.", "Name")
        v299(v315, "Distance", "Show distance to players.", "Distance")
        v299(v315, "Inventory Viewer", "Look at all player's inventory.", "InventoryViewer")

        -- ESP Rarity Toggle
        v299(v315, "ESP Rarity", "Highlight items by rarity in character/backpack",
            "ESP_Rarity_Enable",
            function(state)
                if state then
                    getgenv().ESP_Rarity.Scan()
                else
                    getgenv().ESP_Rarity.ClearAll()
                end
            end
        )

        local v316 = v297(t47.Visual, "Dropped Item", "View All Dropped Items.")
        v299(v316, "Dropped Item", "View All Dropped Items in the world.", "DroppedItemVisual", nil)
        v299(v316, "Blacklist Visual Rarity", "Blacklist Rarity Item Selected.", "BlacklistItemRarity", nil)
        v304(v316, "Select Rarity", "Select rarity of dropped item to unshow.", { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Omega" }, "RarityVisualBlacklist", true)
        v299(v297(t47.Visual, "Miscellaneous", "Additional visual enhancements."), "ATM Viewer", "View ATM locations in the world.", "ATMViewer", nil)

        local GunShopTile = Tiles:WaitForChild("GunShopTile")
        local PrestigeDealerAndHousing = Tiles:WaitForChild("PrestigeDealerAndHousing")

        local v319 = v297(t47.Marketplace, "Weapon Crate", "Quickly purchase and roll for new firearms. (Must be near the shop)")
        v304(v319, "Select Weapon Crate", "Choose a weapon crate.", { "Basic", "Advanced", "Superior", "Elite", "Legendary" }, "WeaponCrateType", false)
        v302(v319, "Open Weapon Crate"):Add("Random", "Primary", function()
            local v1115 = GunShopTile:WaitForChild("PatriotWeapons").Interior.Crates["Weapon Crate"].CrateOptions:FindFirstChild(u135.WeaponCrateType or "Basic")
            u187.send("open_crate", v1115, "money")
        end)

        local v320 = v297(t47.Marketplace, "GunSmith Crate", "Acquire random weapon parts and upgrades. (Must be near the shop)")
        v304(v320, "Select GunSmith Crate", "Customize your arsenal.", { "Grips and Mags 1", "Sights 1", "Underbarrel and Barrel 1", "Wraps 1", "Wraps 2" }, "GunSmithCrateType", false)
        v302(v320, "Open GunSmith Crate"):Add("Random", "Primary", function()
            local v1116 = GunShopTile:WaitForChild("PatriotWeapons").Interior.Crates["Gunsmith Crate"].CrateOptions:FindFirstChild(u135.GunSmithCrateType or "Grips and Mags 1")
            u187.send("open_crate", v1116, "money")
        end)

        local v321 = v297(t47.Marketplace, "Ammo Crate", "Restock your ammunition supplies instantly. (Must be near the shop)")
        v304(v321, "Select Ammo Crate", "Ensure you never run dry.", { "Pistol", "Rifle", "Shotgun", "Special" }, "AmmoCrateType", false)
        v302(v321, "Open Ammo Crate"):Add("Random", "Primary", function()
            local v1117 = GunShopTile:WaitForChild("PatriotWeapons").Interior.Crates["Ammo Crate"].CrateOptions:FindFirstChild(u135.AmmoCrateType or "Pistol")
            u187.send("open_crate", v1117, "money")
        end)

        local v322 = v297(t47.Marketplace, "Car Crate", "Test your luck for a new ride. (Requires proximity to Prestige Dealer)")
        v304(v322, "Select Car Crate", "Unlock anything from daily drivers to supercars.", { "Basic", "Rare", "Elite", "Omega" }, "CarCrateType", false)
        v302(v322, "Open Car Crate"):Add("Random", "Primary", function()
            local v1118 = PrestigeDealerAndHousing.PrestigeCarDealer.Interior.Crates["Car Crate"].CrateOptions:FindFirstChild(u135.CarCrateType or "Basic")
            u187.send("open_crate", v1118, "money")
        end)

        local v323 = v297(t47.LocalPlayers, "Humanoid Modifies", "Modify your humanoid.")
        v299(v323, "Enabled Speed", "Customize your walkspeed.", "CustomSpeed")
        v303(v323, "Speed", "Customize walkspeed.", 0, 3.5, 0, "CustomSpeedValue")
        v299(v323, "Enabled JumpPower", "Customize your jumppower.", "CustomJumpPower")
        v303(v323, "Jump Power", "Customize JumpPower.", 1, 25, 1, "CustomJumpPowerValue")

        local v324 = v297(t47.LocalPlayers, "Snap", "Snap to underground.")
        local u325 = v299(v324, "Snap", "Snap to underground with y offset", "Snap", function(p217)
            if p217 then
                u177 = u190.Position
                n14 = u135.YOffsetSnap or 1
                return
            end
        end)
        v324:Keybind({
            Name = "Keybind Snap",
            Default = Enum.KeyCode.F,
            Callback = function(key)
                if key then u325.Value = not u325.Value end
            end
        })
        v303(v324, "Y Offset", "Y Offset to Snap down.", 1, 150, 1, "YOffsetSnap")
        v302(v324, "Instant Snap"):Add("Start", "Primary", function()
            if t24.SnapSuccess then t24.SnapSuccess = false end
            wait2(0.5)
            repeat
                local v1124 = t24.FindVehicle()
                if v1124 then
                    if v1124:GetAttribute("VehicleType") ~= "bike" then return end
                    for _, descendant in pairs(v1124:GetDescendants()) do
                        if descendant:IsA("BasePart") then descendant.AssemblyLinearVelocity = Vector3.zero end
                    end
                    v1124:PivotTo(u190.CFrame * new3(0, 5, 3))
                    repeat wait2() until t24.GetDistanceRoot(v1124.Chassis) < 7
                    wait2(0.4)
                    for _, descendant in pairs(v1124:GetDescendants()) do
                        if descendant.Name == "DrivePrompt" then fireproximityprompt(descendant) end
                    end
                    v1124:PivotTo(u190.CFrame * new3(0, 0, -3))
                    repeat wait2() until u191.Sit
                    wait2()
                    Tween.play_model(v1124, TweenInfo.new(0, Enum.EasingStyle.Linear), v1124.Chassis.CFrame * new3(0, -u135.YOffsetSnap, 0))
                    u190.Anchored = true
                    u191.Sit = false
                    wait2(0.55)
                    u190.Anchored = false
                    wait2()
                    Tween.play_model(v1124, TweenInfo.new(0, Enum.EasingStyle.Linear), u190.CFrame * new3(160, -u135.YOffsetSnap, 160))
                    t24.SnapSuccess = true
                else
                    local v1129 = t25.GetItemsByType("bike")
                    for _, v in next, v1129 do
                        for _, v1133 in v do
                            u187.get("toggle_equip_item", v1133.guid)
                        end
                    end
                end
                wait2()
            until t24.SnapSuccess or not u190 or not t24.IsAlive(u189)
        end)

        local v326 = v297(t47.LocalPlayers, "Dropped Item", "Auto to grab all dropped items.")
        v299(v326, "Auto Pick Item", "Automatic to pick all dropped items.", "AutoPickDroppedItem")
        v299(v326, "Blacklist Rarity", "Don't pick dropped item if rarity in blacklist.", "BlacklistPickDroppedItem")
        v304(v326, "Select Rarity", "Select rarity of dropped item to not pick.", { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Omega" }, "RarityPickBlacklist", true)

        local v327 = v297(t47.LocalPlayers, "Etc", "Other functions.")
        v299(v327, "Anti Ragdoll", "Anti ragdoll when you get ragdolled.", "AntiRagdoll")
        v299(v327, "Anti Kill", "Anti kill when you get downed.", "AntiKill")
        v299(v327, "Anti Aimbot", "Anti aimbot if you encounter a hacker.", "AntiAimbot")
        v299(v327, "Auto Respawn", "Auto Respawn when you die.", "AutoRespawn", function(p231)
            if p231 then
                local DeathScreenHolder2 = PlayerGui.DeathScreen.DeathScreenHolder
                if DeathScreenHolder2.Visible and DeathScreenHolder2.Frame.RespawnButtonFrame.RespawnButton.TextLabel.Text == "Respawn" then
                    u187.send("death_screen_request_respawn")
                end
            end
        end)
        v299(v327, "Fly Jump", "When you jump and jump again you will fly.", "FlyJump")
        v299(v327, "Infinite Stamina", "Stamina will not load.", "InfiniteStamina")
        v299(v327, "Hide Name (Client)", "Hide your name from screen (Client)", "HideName", function(p232)
            u190:FindFirstChild("CharacterBillboardGui").Enabled = not p232
        end)

        local MagicFOVRunning = false

        v302(v327, "Magic FOV"):Add("Start", "Primary", function()
            if MagicFOVRunning then return end
            MagicFOVRunning = true

            spawn(function()
                local screenSize = PlayerGui.AbsoluteSize
                local centerX = screenSize.X / 2
                local centerY = screenSize.Y / 2
                local maxRadius = math.sqrt(centerX * centerX + centerY * centerY)

                local fovContainer = new("Frame")
                fovContainer.Name = "MagicFOVContainer"
                fovContainer.Size = UDim2.fromScale(1, 1)
                fovContainer.BackgroundTransparency = 1
                fovContainer.Parent = PlayerGui

                local segments = 60
                local segmentWidth = 360 / segments
                local animationDuration = 2
                local waveDelay = 0.02

                for i = 0, segments - 1 do
                    local angle = math.rad(i * segmentWidth)
                    local segmentFrame = new("Frame")
                    segmentFrame.Name = "Segment_" .. i
                    segmentFrame.BackgroundColor3 = Color3.fromHSV(i / segments, 1, 1)
                    segmentFrame.BackgroundTransparency = 0.3
                    segmentFrame.BorderSizePixel = 0
                    segmentFrame.Size = UDim2.new(0, 2, 0, maxRadius * 2)
                    segmentFrame.Position = UDim2.fromOffset(centerX, centerY)
                    segmentFrame.AnchorPoint = new2(0.5, 0)
                    segmentFrame.Parent = fovContainer
                    segmentFrame.Rotation = math.deg(angle)

                    spawn(function()
                        wait2(i * waveDelay)
                        local startTime = tick()
                        while MagicFOVRunning and wait2(0.016) do
                            local elapsed = tick() - startTime
                            local progress = elapsed / animationDuration
                            if progress >= 1 then
                                segmentFrame.Size = UDim2.new(0, 2, 0, maxRadius * 2)
                                if MagicFOVRunning then wait2(0.1) else break end
                            else
                                segmentFrame.Size = UDim2.new(0, 2, 0, maxRadius * progress)
                            end
                        end
                    end)
                end

                wait2(animationDuration + segments * waveDelay + 0.5)

                if MagicFOVRunning then
                    local fadeStart = tick()
                    local fadeDuration = 0.4
                    while MagicFOVRunning and wait2(0.016) do
                        local fadeElapsed = tick() - fadeStart
                        local fadeProgress = fadeElapsed / fadeDuration
                        if fadeProgress >= 1 then
                            fovContainer:Destroy()
                            break
                        end
                        for _, segment in pairs(fovContainer:GetChildren()) do
                            segment.BackgroundTransparency = 0.3 + (fadeProgress * 0.7)
                        end
                    end
                end

                if fovContainer and fovContainer.Parent then
                    fovContainer:Destroy()
                end
                MagicFOVRunning = false
            end)
        end):Add("Stop", "Primary", function()
            MagicFOVRunning = false
            local container = PlayerGui:FindFirstChild("MagicFOVContainer")
            if container then container:Destroy() end
        end)

        local v328 = v297(t47.Vehicle, "General", "Additional Vehicle.")
        v299(v328, "Auto Lock", "Automatically lock car.", "AutoLock")
        v299(v328, "Bump Aura", "Automatically bump nearby players.", "BumpAura")
        v299(v328, "No Crash", "Block crash calls while driving.", "NoCrash")
        RunService2.Heartbeat:Connect(function()
            if not u135.NoCrash then
                u135.NoCrashActive = false
                return
            end
            if os.clock() - t24.Gate.nc < 0.2 then return end
            t24.Gate.nc = os.clock()
            pcall(function()
                u135.NoCrashActive = (u135.NoCrash and Vehicle.get_car_player_is_in()) and true or false
            end)
        end)
        v299(v328, "Vehicle Noclip", "Drive through walls and objects, not the floor.", "VehicleNoclip")
        v299(v328, "Noclip", "Vehicle and character pass through floor and walls.", "SnapNoclip")
        local function applyCarNoclip(model)
            local bbCF, bbSize = model:GetBoundingBox()
            local bottom = bbCF.Position.Y - bbSize.Y / 2
            for _, d in pairs(model:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.CanCollide = (d.Position.Y - d.Size.Y / 2) < bottom + 1.5
                end
            end
        end
        local function restoreParts(key)
            local saved = u135[key]
            if saved then
                for d, c in pairs(saved) do
                    if d.Parent then d.CanCollide = c end
                end
                u135[key] = nil
            end
        end
        local snapNoclipLastUpdate = 0
        RunService2.Heartbeat:Connect(function()
            if os.clock() - snapNoclipLastUpdate < 0.1 then return end
            snapNoclipLastUpdate = os.clock()
            pcall(function()
                if not u135.SnapNoclip then
                    restoreParts("CharNoclipParts")
                    return
                end
                local car = t24.FindVehicle()
                if car then applyCarNoclip(car) end
                if not u189 or not u190 or not u191 then return end
                local saved = u135.CharNoclipParts
                if not saved then
                    saved = {}
                    for _, d in pairs(u189:GetDescendants()) do
                        if d:IsA("BasePart") then saved[d] = d.CanCollide end
                    end
                    u135.CharNoclipParts = saved
                end
                for d in pairs(saved) do
                    if d.Parent then d.CanCollide = false end
                end
                if u191.Sit then return end
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = { u189 }
                local hit = workspace:Raycast(u190.Position + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), params)
                if hit then
                    local targetY = hit.Position.Y + u191.HipHeight + u190.Size.Y / 2
                    local delta = targetY - u190.Position.Y
                    if delta > 0 then
                        u189:PivotTo(u189:GetPivot() + Vector3.new(0, delta, 0))
                        local v = u190.AssemblyLinearVelocity
                        u190.AssemblyLinearVelocity = new4(v.X, math.max(v.Y, 0), v.Z)
                    end
                end
            end)
        end)
        v302(v328, "Vehicle Action"):Add("Bomb", "Primary", function()
            for _ = 1, 5 do
                u187.send("crashed_car", Vehicle.get_car_player_is_in(), 150)
            end
        end):Add("Bring", "Primary", function()
            if #Vehicles:GetChildren() ~= 0 then
                for _, v in next, Vehicles:GetChildren() do
                    if v:GetAttribute("OwnerUserId") == UserId then
                        v:PivotTo(u189:GetPivot() * new3(0, 0, 5))
                    end
                end
                return
            end
        end)

        local v328_1 = v297(t47.Vehicle, "Control Mode", "Choose your driving control scheme.")
        v300(v328_1, "Control Mode", "Mobile = มีจอยสติ๊ก | PC = ใช้ WASD ไม่มีจอย", { "Mobile", "PC" }, "VehicleControlMode")
        v299(v328_1, "Enable Joystick", "เปิด/ปิดจอย (Mobile mode เท่านั้น)", "VehicleJoystick")
        v303(v328_1, "Drive Speed", "ความเร็วรถเมื่อใช้จอย", 10, 200, 35, "VehicleJoystickSpeed")
        v303(v328_1, "Turn Speed", "ความเร็วการหมุนพวงมาลัย", 1, 50, 14, "VehicleJoystickTurn")
        v303(v328_1, "Joystick Radius", "ระยะห่างสูงสุดของ thumb", 20, 120, 55, "VehicleJoystickRadius")

        local v329 = v297(t47.Setting, "Graphic", "Reduce lag and improve your graphics.")
        v299(v329, "WhiteScreen", "Disable 3D Render to Reduce Lag.", "WhiteScreen", function(p233)
            RunService2:Set3dRenderingEnabled(not p233)
        end)
        v299(v329, "High Camera Position", "Change camera position to high place.", "HighCameraPosition", function(p234)
            Camera.CameraSubject = p234 and u227 or u191
        end)
        v302(v329, "Fps Booster"):Add("Start Boost", "Primary", function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 10000000000
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
            for _, child in pairs(Lighting:GetChildren()) do
                if child:IsA("Sky") or child:IsA("SunRaysEffect") or child:IsA("BlurEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect") or child:IsA("DepthOfFieldEffect") then
                    child:Destroy()
                end
            end
            if Terrain then
                Terrain.WaterWaveSize = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
                Terrain:SetMaterialColor(Enum.Material.Grass, Color3.fromRGB(150, 150, 150))
            end
            local descendants = workspace:GetDescendants()
            for index, descendant in ipairs(descendants) do
                if index % 250 == 0 then task.wait() end
                if descendant:IsA("BasePart") or descendant:IsA("MeshPart") then
                    descendant.Material = Enum.Material.SmoothPlastic
                    descendant.Color = Color3.fromRGB(170, 170, 170)
                    descendant.Reflectance = 0
                    descendant.CastShadow = false
                end
                if descendant:IsA("Decal") or descendant:IsA("Texture") or descendant:IsA("SurfaceAppearance") then
                    descendant:Destroy()
                end
                if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
                    descendant.Enabled = false
                end
                if descendant:IsA("Accessory") or descendant:IsA("Clothing") or descendant:IsA("Shirt") or descendant:IsA("Pants") then
                    descendant:Destroy()
                end
                if descendant:IsA("Sound") then
                    descendant.Volume = 0
                    descendant:Stop()
                end
            end
        end)

        v302(v297(t47.Setting, "Server Finder", "Scan and filter game servers."), "Server", "You can find all servers with types."):Add("High Server", "Primary", function()
            t24.HopServer(1)
        end):Add("Low Server", "Primary", function()
            t24.HopServer(2)
        end):Add("Rejoin Current Server", "Primary", function()
            TeleportService:TeleportToPlaceInstance(PlaceId2, JobId2)
        end)

        local v330 = v297(t47.Setting, "JobId", "You can join other server by jobid.")
        v301(v330, "Enter JobId", "Your JobId enter here to join.", "JobIdValue")
        v302(v330, "Action JobId", "You can do anything with Server id."):Add("Join JobId", "Primary", function()
            TeleportService:TeleportToPlaceInstance(PlaceId2, u135.JobIdValue)
        end):Add("Copy Server Id", "Primary", function()
            setclipboard(JobId2)
        end)

        spawn(function()
            local subtitleText = "you are a star shining on nights away"
            local offset = 0
            while wait2(0.2) do
                local okShown, shown = pcall(function() return u287:GetState() end)
                if okShown and shown == false then continue end
                local stops = {}
                for k = 0, 6 do
                    table.insert(stops, Color3.fromHSV((k / 6 + offset) % 1, 1, 1))
                end
                u287:SetSubtitle(MacLib:Gradient(subtitleText, stops))
                offset = (offset + 0.06) % 1
            end
        end)

        u287:Notify({
            Title = "Loaded successfully",
            Description = "If you encounter any issues, you can contact us via the Discord group.",
            Lifetime = 3
        })
        return
    end
end
