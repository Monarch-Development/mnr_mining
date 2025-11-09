local config = require 'config.server'
local zones = require 'config.zones'

local InZone = {}
local cooldown = {}

local materials = config.rewards

local totalChance = 0
for i = 1, #materials do
    totalChance = totalChance + materials[i].chance
    materials[i].cumulative = totalChance
end

local function GetMiningReward()
    local roll = math.random(1, totalChance)

    for i = 1, #materials do
        if roll <= materials[i].cumulative then
            local item = materials[i]
            local amount = math.random(item.min, item.max)
            return item.name, amount
        end
    end
end

local function insideZone(playerCoords, zoneCoords, zoneRotation, zoneSize)
    if not playerCoords then
        return false
    end

    if not zoneCoords or not zoneRotation or not zoneSize then
        return false
    end

    local relative = playerCoords - zoneCoords
    local rad = math.rad(-zoneRotation)
    local cosH = math.cos(rad)
    local sinH = math.sin(rad)

    local localX = relative.x * cosH - relative.y * sinH
    local localY = relative.x * sinH + relative.y * cosH
    local localZ = relative.z

    local halfSize = zoneSize / 2

    return math.abs(localX) <= halfSize.x and math.abs(localY) <= halfSize.y and math.abs(localZ) <= halfSize.z
end

lib.callback.register('mnr_mining:server:RegisterEntry', function(source, name)
    local src = source

    if type(name) ~= 'string' then return end

    local zone = zones[name]
    if not zone then return end

    local playerPed = GetPlayerPed(src)
    local coords = GetEntityCoords(playerPed)

    local inside = insideZone(coords, zone.coords, zone.rotation, zone.size)

    if not inside and InZone[src] == name then
        InZone[src] = nil
        return false
    elseif inside and InZone[src] == nil then
        InZone[src] = name
        return true
    end
end)

lib.callback.register('mnr_mining:server:InZone', function(source, name)
    return InZone[source] == name
end)

lib.callback.register('mnr_mining:server:HasItem', function(source)
    local item = exports.ox_inventory:GetSlotWithItem(source, 'pickaxe')

    return item and item.metadata.durability > 0
end)

local function inZone(source)
    return InZone[source] ~= nil
end

RegisterNetEvent('mnr_mining:server:Mined', function()
    local src = source

    if cooldown[src] then
        return
    end

    if not inZone(src) then return end

    local item = exports.ox_inventory:GetSlotWithItem(src, 'pickaxe')

    if not item or item.metadata.durability < 1 then
        return
    end

    local degradeChance = config.tools['pickaxe'].degradeChance
    if math.random(1, 100) < degradeChance then
        exports.ox_inventory:SetDurability(src, item.slot, item.metadata.durability - 1)
    end

    local rewardName, rewardAmount = GetMiningReward()
    if rewardName and rewardAmount then
        exports.ox_inventory:AddItem(src, rewardName, rewardAmount)
    end

    lib.timer(config.cooldown, function()
        cooldown[src] = nil
    end)
end)