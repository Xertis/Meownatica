local arbd = require 'meownatica:files/arbd'
local data_buffer = require "core:data_buffer"
local arbd_u = {}
local table_utils = require 'meownatica:tools/table_utils'
local lang = load_script('meownatica:meow_data/lang.lua')
local mdf = require 'meownatica:files/MDF'
local dtc = require 'meownatica:logic/DepthToCoords'
local meow_schem = require 'meownatica:schematics_editors/PosManager'
local RLE = require 'meownatica:logic/RLEcompression'
local reader = require 'meownatica:tools/read_toml'
local json = require 'meownatica:tools/json_reader'

function arbd_u.write(array, path)
    --local buf = data_buffer()

    --arbd.serialize(array, buf)

    --file.write_bytes(path, buf.get_bytes())
    file.write(path, json.encode(array))
end

function arbd_u.read(path)
    if not file.exists(path) then
        return nil
    end
    --return arbd.deserialize(data_buffer(file.read_bytes(path)))
    return json.decode(file.read(path))
end


function arbd_u.convert_save(array)
    --## ОБЪЯВЛЕНИЕ ПЕРЕМЕННЫХ ##
    local arbd_table = {}
    local temp_table_1 = {}
    local temp_table_2 = {}
    local blocks_id = {}
    local prefabs = {}
    local state = nil

    --## РАСЧЁТ ГЛУБИНЫ ##
    local max_pos = meow_schem.max_position(array)
    local min_pos = meow_schem.min_position(array)
    local depthX, depthY, depthZ = math.abs(min_pos[1] - max_pos[1]), math.abs(min_pos[2] - max_pos[2]), math.abs(min_pos[3] - max_pos[3])

    --## РАСЧЁТ АЙДИШНИКОВ БЛОКОВ ##
    for _, value in ipairs(array) do
        --print(value.x, value.y, value.Z, value.id)
        if temp_table_1[value.id] == nil then
            table.insert(blocks_id, value.id)
            temp_table_1[value.id] = #blocks_id
        end
    end

    --## РАСЧЁТ БЛОКОВ ##
    local i = 1

    for _, value in pairs(array) do
        temp_table_2[i] = {temp_table_1[value.id], value.state.rotation, value.state.solid}
        i = i + 1
    end

    --## ЗАПИСЬ ДАННЫХ ##
    arbd_table[1] = 3
    arbd_table[2] = blocks_id

    local binding = meow_schem.get_binding_block(array)
    arbd_table[3] = {depthX, depthY, depthZ, binding}

    arbd_table[4] = temp_table_2

    --## ВЫВОД ##
    print(
        '[MEOWNATICA] \n             ' ..
        'IDs count. ' .. #arbd_table[2] .. '\n             ' ..
        'Blocks count. ' .. #arbd_table[4] .. '\n             ' ..
        'Binding. ' .. arbd_table[3][4] .. '\n             ' ..
        'Version. ' .. arbd_table[1]
    )
    arbd_table[4] = RLE.encode_table(arbd_table[4])
    print(lang.get('is converted'))
    arbd_table[5] = false
    return arbd_table
end

local function create_cords(x1, y1, z1, x2, y2, z2, bind_block)
    local result = {}
    local i = 0
    local bind_cord = {}
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                i = i + 1
                if i == bind_block then
                    bind_cord = {x, y, z}
                end
            end
        end
    end
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                table.insert(result, {x - bind_cord[1], y - bind_cord[2], z - bind_cord[3]})
            end
        end
    end
    return result
end

function arbd_u.convert_read(tbl)
    local result = {}
    local cords = dtc.dtc(tbl[3])
    local correct_cords = create_cords(cords[1][1], cords[1][2], cords[1][3], cords[2][1], cords[2][2], cords[2][3], cords[2][4])
    local blocks_id = tbl[2]
    local setair = reader.get('SetAir')
    tbl[4] = RLE.decode_table(tbl[4])
    for i = 1, #tbl[4] do
        local block_info = tbl[4][i]
        local block_id = blocks_id[block_info[1]]
        local state_idx = block_info[2]
        if (block_id ~= 'core:air') or (block_id == 'core:air' and setair) then
            if correct_cords then
                local state = {
                    rotation = block_info[2],
                    solid = block_info[3],
                    replaceable = false
                }

                local cord = correct_cords[i]
                if block_id ~= nil then
                    table.insert(result, {
                        x = cord[1],
                        y = cord[2],
                        z = cord[3],
                        id = block_id,
                        state = state
                    })
                end
            end
        end
    end

    return result
end

return arbd_u