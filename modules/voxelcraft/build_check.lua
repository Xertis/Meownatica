local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local tblu = require 'meownatica:tools/table_utils'
local module = {}
local available_ids = {}

local function init()
    local packs = block.defs_count()
    for i = 0, packs do
        available_ids[#available_ids + 1] = block.name(i)
    end
end

function module.get_full_inv(id_inv)
    local inv = {}
    for i=0, inventory.size(id_inv)-1 do
        local item, count = inventory.get(id_inv, i)
        if inv[item] == nil then
            inv[item] = count
        else
            inv[item] = inv[item] + count
        end
    end
    return inv
end

local function conv(materials)
    local res = {}
    for _, entry in ipairs(meow_schem.materials(materials)) do
        res[entry.id] = entry.count
    end
    return res
end

function module.check(schem)
    init()
    if type(schem) == 'table' then
        local inv = module.get_full_inv(player.get_inventory(1))
        local materials = conv(meow_schem.materials(schem))
        for item in pairs(materials) do
            if (item ~= "core:air" and tblu.find(available_ids, item)) and inv[block.index(item)] < materials[item] then
                return false
            end
        end
        return true
    end
end

function module.del(schem)
    local inv = player.get_inventory(1)
    local materials = conv(meow_schem.materials(schem))
    local size = inventory.size(inv)
    for i=0, size-1 do
        local item, count = inventory.get(inv, i)
        if item ~= "core:air" and materials[item] ~= nil and count-materials[item] >= 0 then
            inventory.set(inv, i, item, count-materials[item])
        end
    end
end

return module