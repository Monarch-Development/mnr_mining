local blipClass = require '@mnr_blips.init'
local zones = require 'config.zones'

local currentZone = false
local busy = false
local targetIds = {}

local function mine()
    if busy then return end

    local inZone = lib.callback.await('mnr_mining:server:InZone', false, currentZone)

    if not inZone then
        return
    end

    local hasItem = lib.callback.await('mnr_mining:server:HasItem', false)

    if not hasItem then
        framework.Notify(locale('notify_no_pickaxe'), 'error')
        return
    end

    busy = true

    if lib.progressCircle({
        label = locale('progress_label'),
        duration = 10000,
        position = 'middle',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict = 'melee@large_wpn@streamed_core',
            clip = 'ground_attack_0',
        },
        prop = {
            bone = 28422,
            model = 'prop_tool_pickaxe',
            pos = vec3(0.09, -0.05, -0.02),
            rot = vec3(-78.0, 13.0, 28.0),
        },
    }) then
        TriggerServerEvent('mnr_mining:server:Mined')
    else
        framework.Notify(locale('notify_cancel'), 'error')
    end

    busy = false
end

local function toggleTargets(name, inside)
    local targets = zones[name].targets

    if inside then
        for _, data in ipairs(targets) do
            local id = exports.ox_target:addSphereZone({
                coords = data.coords,
                radius = data.radius,
                debug = data.debug,
                options = {
                    {
                        label = locale('target_label'),
                        icon = 'fa-solid fa-hill-rockslide',
                        canInteract = function()
                            return not busy
                        end,
                        onSelect = mine,
                    },
                },
            })
            targetIds[#targetIds + 1] = id
        end
    else
        for _, id in ipairs(targetIds) do
            exports.ox_target:removeZone(id)
        end
        targetIds = {}
    end
end

local function registerEntry(self)
    local inside = lib.callback.await('mnr_mining:server:RegisterEntry', false, self.name)
    toggleTargets(self.name, inside)
    if inside then
        currentZone = self.name
    else
        currentZone = false
    end
end

local function createZone(name, data)
    lib.zones.box({
        name = name,
        coords = data.coords,
        size = data.size,
        rotation = data.rotation,
        onEnter = registerEntry,
        onExit = registerEntry,
        debug = data.debug,
    })

    blipClass:new({
        coords = data.coords,
        sprite = 618,
        color = 5,
        scale = 0.8,
        label = locale('blip_name')
    })
end

for name, data in pairs(zones) do
    createZone(name, data)
end