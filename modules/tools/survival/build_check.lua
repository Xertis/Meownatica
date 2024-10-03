local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local tblu = require 'meownatica:tools/table_utils'
local module = {}
local available_ids = {}

local function init()
    local packs = item.defs_count()
    for i = 0, packs do
        available_ids[#available_ids + 1] = item.name(i)
    end
end

function module.get_full_inv(id_inv)
    local inv = {}
    for i=0, inventory.size(id_inv)-1 do
        local items, count = inventory.get(id_inv, i)
        items = item.name(items)
        if inv[items] == nil then
            inv[items] = count
        else
            inv[items] = inv[items] + count
        end
    end
    return inv
end

local function conv(materials)
    local res = {}
    for _, entry in ipairs(materials) do
        res[entry.id .. '.item'] = entry.count
    end
    return res
end

function module.check(schem)
    init()
    if type(schem) == 'table' then
        local inv = module.get_full_inv(player.get_inventory(1))

        local materials = conv(meow_schem.materials(schem))

        for elem, count in pairs(materials) do
            if inv[elem] == nil or (count > inv[elem]) and elem ~= "core:air.item" then
                return false
            end
        end
        return true
    end
    return false
end

function module.del(schem)
    local inv = player.get_inventory(1)
    local materials = conv(meow_schem.materials(schem))

    for i=0, inventory.size(inv)-1 do
        local elem, count = inventory.get(inv, i)
        elem = item.name(elem)
        if materials[elem] ~= nil then
            if materials[elem] - count <= 0 then
                inventory.set(inv, i, item.index(elem), count - materials[elem])
                materials[elem] = nil
            else
                inventory.set(inv, i, 0, 1)
                materials[elem] = materials[elem] - count
            end
        end
    end
end

return module