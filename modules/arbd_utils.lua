local arbd = require 'meownatica:arbd'
local data_buffer = require "core:data_buffer"
local artd = require 'meownatica:artd'
local arbd_u = {}
local table_utils = require 'meownatica:table_utils'

local zzlib = require 'meownatica:zlib/zzlib'

function arbd_u:write(array, path)
    local buf = data_buffer()
  
    arbd.serialize(array, buf)
    
    file.write_bytes(path, buf:get_bytes())
end

function arbd_u:read(path)
    if not file.exists(path) then
        return nil
    end
    return arbd.deserialize(data_buffer(file.read_bytes(path)))
end

function arbd_u:convert_save(array)
    local arbd_table = {}
    local temp_table_1 = {}
    local temp_table_2 = {}
    local blocks_id = {}
    local prefabs = {}
    local state = nil

    --Blocks_id
    for _, value in pairs(array) do
        if temp_table_1[value.id] == nil then
            table.insert(blocks_id, value.id)
            temp_table_1[value.id] = #blocks_id
        end
    end

    arbd_table[1] = 'MEOWNATIC_VERSION = 2'
    arbd_table[2] = {blocks_id}

    --Prefabs
    for _, value in pairs(array) do
        state = {value.state.rotation, value.state.solid, value.state.replaceable}
        if table_utils:tbl_in_tbl(prefabs, state) == nil then
            table.insert(prefabs, state)
            temp_table_2[table_utils:easy_concat(state)] = #prefabs
        end
    end

    arbd_table[3] = prefabs
    local i = 4
    for _, value in pairs(array) do
        state = table_utils:easy_concat({value.state.rotation, value.state.solid, value.state.replaceable})
        arbd_table[i] = {value.x, value.y, value.z, temp_table_1[value.id], temp_table_2[state]}
        i = i + 1
    end
    print(
        '[MEOWNATICA] Prefabs count: ' .. #arbd_table[3] .. '\n             ' ..
        'IDs count: ' .. #arbd_table[2][1] .. '\n             ' ..
        'Blocks count: ' .. #arbd_table - 3 .. '\n             ' ..
        arbd_table[1]
    )
    print('[MEOWNATICA] Meownatic is converted...')
    arbd_table[#arbd_table + 1] = false
    return arbd_table
end

function arbd_u:convert_read(tbl)
    local result = {}
    local blocks_id = tbl[2][1]
    local prefabs = tbl[3]

    for i = 4, #tbl-1 do
        local block_info = tbl[i]
        local block_id = blocks_id[block_info[4]]
        local state_idx = block_info[5]
        local state_info = prefabs[state_idx]
        
        if state_info then
            local state = {
                rotation = state_info[1],
                solid = state_info[2],
                replaceable = state_info[3]
            }

            table.insert(result, {
                x = block_info[1],
                y = block_info[2],
                z = block_info[3],
                id = block_id,
                state = state
            })
        end
    end

    return result
end

return arbd_u