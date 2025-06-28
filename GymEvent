-- open source script.
-- made by (bkmd_ytt) - Sub2BK

-- Wait until game is fully loaded
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
repeat task.wait() until not player.PlayerGui:FindFirstChild("__INTRO")

-- Require modules
local InstancingCmds = require(ReplicatedStorage.Library.Client.InstancingCmds)
local EggCmds = require(ReplicatedStorage.Library.Client.EggCmds)
local Network = require(ReplicatedStorage.Library.Client.Network)
local InstanceZoneCmds = require(ReplicatedStorage.Library.Client.InstanceZoneCmds)

-- Remotes
local TrainRemote = ReplicatedStorage.Network:WaitForChild("InfiniteGym_Train")
local StartRemote = ReplicatedStorage.Network:WaitForChild("InfiniteGym_Start")
local ZonePurchaseRemote = ReplicatedStorage.Network:WaitForChild("InstanceZones_RequestPurchase")
local GymRebirthRemote = ReplicatedStorage.Network:WaitForChild("Gym_Rebirth")
local TeleportRemote = ReplicatedStorage.Network:WaitForChild("Teleports_RequestInstanceTeleport")

-- Disable egg animation
local eggScript = player.PlayerScripts.Scripts.Game:WaitForChild("Egg Opening Frontend")
getsenv(eggScript).PlayEggAnimation = function() end

-- Enter GymEvent
local function enterGymEvent()
    setthreadidentity(2)
    pcall(function()
        InstancingCmds.Enter("GymEvent")
    end)
    setthreadidentity(7)
end

enterGymEvent()
task.wait(10)

-- Auto buy zones
task.spawn(function()
    while true do
        for zone = 1, 5 do
            pcall(function()
                ZonePurchaseRemote:InvokeServer("GymEvent", zone)
            end)
        end
        task.wait(1)
    end
end)

-- Auto rebirth
task.spawn(function()
    while true do
        pcall(function()
            GymRebirthRemote:InvokeServer()
        end)
        task.wait(1)
    end
end)

-- Auto start infinite gym - no needed to be in infinite zone anymore
task.spawn(function()
    while true do
        pcall(function()
            StartRemote:InvokeServer()
        end)
        task.wait()
    end
end)

-- Auto train infinite "Squat"
task.spawn(function()
    while true do
        pcall(function()
            TrainRemote:InvokeServer("Squat")
        end)
        task.wait()
    end
end)

-- Find nearest egg
local function findNearestEgg()
    local eggsFolder = workspace.__THINGS:FindFirstChild("CustomEggs")
    if not eggsFolder then return nil end

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearestEgg, nearestDistance = nil, math.huge
    for _, eggModel in ipairs(eggsFolder:GetChildren()) do
        if eggModel:IsA("Model") then
            local success, cframe = pcall(function()
                return eggModel:GetBoundingBox()
            end)
            if success and cframe then
                local dist = (hrp.Position - cframe.Position).Magnitude
                if dist < nearestDistance then
                    nearestEgg = eggModel.Name
                    nearestDistance = dist
                end
            end
        end
    end
    return nearestEgg
end

-- Auto hatch nearest egg
_G.AutoOpen = true
task.spawn(function()
    while task.wait() do
        if _G.AutoOpen then
            local eggName = findNearestEgg()
            if eggName then
                pcall(function()
                    Network.Invoke("CustomEggs_Hatch", eggName, EggCmds.GetMaxHatch())
                end)
            end
        end
    end
end)

-- TP to max owned zone once
task.spawn(function()
    pcall(function()
        local maxZone = InstanceZoneCmds.GetMaximumOwnedZoneNumber()
        if not maxZone then return end

        local teleportsFolder = Workspace.__THINGS.__INSTANCE_CONTAINER.Active.GymEvent.Teleports
        local zonePart = teleportsFolder:FindFirstChild(tostring(maxZone))
        if not zonePart or not zonePart:IsA("BasePart") then return end

        local zoneName = "__Zone_" .. tostring(maxZone)
        TeleportRemote:InvokeServer(zoneName)

        task.wait(5)

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = hrp.CFrame + Vector3.new(64, 0, -40)
        end
    end)
end)
