local m_api = {}
local mods_register = {}
local meow_schem = require 'meownatica:schem_class'
local reader = require 'meownatica:read_toml'

local function build_schem(x, y, z, read_meowmatic, copy_air)
    local point = 0
    while point <= #read_meowmatic do
        local index = (point - 1) % #read_meowmatic + 1 
        local structure = read_meowmatic[index]
            if block.get(structure.x + x, structure.y + y, structure.z + z) ~= block_index("meownatica:meowoad") then
                if (block.get(structure.x + x, structure.y + y, structure.z + z) ~= 0 and copy_air == false) or copy_air == true then
                    block.set(structure.x + x, structure.y + y, structure.z + z, block.index(structure.id), structure.state.rotation, false)
                end
            end
        point = point + 1
    end
end

local function table_shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
        t2[k] = v
    end
    return t2
end

function m_api.copyzone(x1, y1, z1, x2, y2, z2, x_p, y_p, z_p, copy_air)
    local save_meowmatic = {}
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if block.get(x, y, z) ~= 0 or copy_air == true then
                    save_meowmatic[#save_meowmatic + 1] = {x = x - x_p, y = y - y_p, z = z - z_p, id = block.name(block.get(x, y, z)), state = {rotation = block.get_states(x, y, z), solid = block.is_solid_at(x, y, z), replaceable = block.is_replaceable_at(x, y, z)}}
                else
                    if copy_air == false and block.get(x, y, z) ~= 0 then
                        save_meowmatic[#save_meowmatic + 1] = {x = x - x_p, y = y - y_p, z = z - z_p, id = block.name(block.get(x, y, z)), state = {rotation = block.get_states(x, y, z), solid = block.is_solid_at(x, y, z), replaceable = block.is_replaceable_at(x, y, z)}}
                    end
                end
            end
        end
    end
    return save_meowmatic
end

function m_api.pastezone(x, y, z, table)
    print(#table)
    build_schem(x, y, z, table, true)
end

function m_api.config_all()
    return reader:get_all()
end

function m_api.config_get(parameter)
    return reader:get(parameter)
end

return m_api

