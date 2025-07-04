
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Networking = require(ReplicatedStorage.Library.Client.Network)
local Senv = getsenv(ReplicatedStorage.Library.Client.Network)

local remotes = getupvalues(Senv._remote)[1]
local nameCache = { [1] = {}, [2] = {}, [3] = {} }
local loggedRemotes = {}
local totalFound, totalReverted = 0, 0

local methodMap = { Fire = 1, Invoke = 2, UnreliableFire = 3 }
local methodCheck = {
    [1] = "RemoteEvent",
    [2] = "RemoteFunction",
    [3] = "RemoteEvent"
}

local function safeInsert(index, name)
    if not table.find(nameCache[index], name) then
        table.insert(nameCache[index], name)
    end
end

for _, func in next, getgc(true) do
    if typeof(func) == "function" and islclosure(func) then
        local constants = getconstants(func)
        for method, index in pairs(methodMap) do
            for i = 1, #constants do
                if constants[i] == method and typeof(constants[i + 1]) == "string" then
                    safeInsert(index, constants[i + 1])
                end
            end
        end

        for _, upv in pairs(getupvalues(func)) do
            if typeof(upv) == "string" and #upv <= 100 then
                for _, index in ipairs({1, 2, 3}) do
                    safeInsert(index, upv)
                end
            end
        end
    end
end

for index = 1, 3 do
    for realName, instance in pairs(remotes[index]) do
        if typeof(instance) == "Instance" and instance:IsA(methodCheck[index]) then
            safeInsert(index, instance.Name)
        end
    end
end

for index, names in pairs(nameCache) do
    loggedRemotes[index] = {}
    for _, fakeName in pairs(names) do
        local realName = Senv._getName(index, fakeName)
        if realName then
            local remote = remotes[index][realName]
            if typeof(remote) == "Instance" and remote:IsA(methodCheck[index]) then
                remote.Name = fakeName
                totalReverted += 1
                table.insert(loggedRemotes[index], { Original = realName, Reverted = fakeName })
            end
        end
        totalFound += 1
    end
end

for _, str in next, getgc(true) do
    if typeof(str) == "string" and #str >= 4 and #str <= 40 and str:match("^[%w_]+$") then
        for index = 1, 3 do
            local real = Senv._getName(index, str)
            local remote = real and remotes[index][real]
            if remote and typeof(remote) == "Instance" and remote:IsA(methodCheck[index]) then
                remote.Name = str
                totalReverted += 1
                safeInsert(index, str)
                table.insert(loggedRemotes[index], { Original = real, Reverted = str })
            end
        end
    end
end
