local data_buffer = require "files/buffer/deprecated/data_buffer"
local save_u = {}
local lang = require 'meownatica:frontend/lang'
local mbp = require 'meownatica:files/mbp_manager'
local dtc = require 'meownatica:logic/DepthToCoords'
local psm = require 'meownatica:schematics_editors/PosManager'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local RLE = require 'meownatica:logic/RLEcompression'
local reader = require 'meownatica:tools/read_toml'
local container = require 'meownatica:container_class'
local json_comber = require 'meownatica:tools/json_comber'

function save_u.save(tbl, meta, name)
    tbl = tbl or container.get()

    if #tbl > 0 then
        local num_file = 1

        if not name or file.exists(reader.sys_get('savepath') .. name .. reader.sys_get('fileformat')) then
            while file.exists(reader.sys_get('savepath') .. 'save_meownatic_' .. num_file .. reader.sys_get('fileformat')) do
                num_file = num_file + 1
            end
            name = 'save_meownatic_' .. num_file
        end

        print(lang.get('Save Meownatic'))
        local save_table = {}
        save_table, meta = save_u.convert_save(tbl, meta)

        save_u.write(save_table, meta, reader.sys_get('savepath') .. name .. reader.sys_get('fileformat'))
        meow_schem.save_to_config(name .. reader.sys_get('fileformat'))
    end
end

function save_u.write(array, meta, path)
    local buf = data_buffer()
    mbp.serialize(buf, array, meta)

    file.write_bytes(path, buf:get_bytes())
    --file.write(path, json.encode(array))
end

function save_u.read(path)
    if not file.exists(path) then
        return nil
    end
    return mbp.deserialize(data_buffer(file.read_bytes(path)))
    --return json.decode(file.read(path))
end


function save_u.convert_save(array, meta)
    --## ОБЪЯВЛЕНИЕ ПЕРЕМЕННЫХ ##
    local save_tbl = {}
    local temp_table_1 = {}
    local temp_table_2 = {}
    local temp_table_3 = {}
    local blocks_id = {}

    --## РАСЧЁТ ГЛУБИНЫ ##
    local max_pos, min_pos = psm.min_max_position(array)
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

    for _, value in pairs(array) do
        if value.elem == 0 then
            table.insert(temp_table_2, {temp_table_1[value.id], value.state.rotation, value.state.solid})
        elseif value.elem == 1 then
            table.insert(temp_table_3, {temp_table_1[value.id], value.rot, value.x, value.y, value.z})
        end
    end

    --## ЗАПИСЬ ДАННЫХ ##
    save_tbl[1] = 'MBP [1]'
    save_tbl[2] = blocks_id

    local binding = psm.get_binding_block(array)
    save_tbl[3] = {depthX, depthY, depthZ, binding}

    save_tbl[4] = temp_table_2
    save_tbl[5] = temp_table_3
    meta = meta or {description = ""}

    --## ВЫВОД ##
    print(
        '[MEOWNATICA] \n             ' ..
        'IDs count: ' .. #save_tbl[2] .. '\n             ' ..
        'Blocks count: ' .. #save_tbl[4] .. '\n             ' ..
        'Entities count: ' .. #save_tbl[5] .. '\n             ' ..
        'Binding: ' .. save_tbl[3][4] .. '\n             ' ..
        'Version: ' .. save_tbl[1] .. '\n             ' ..
        'Size (X, Y, Z): ' .. depthX + 1 .. ', ' .. depthY + 1 .. ', ' .. depthZ + 1 .. '\n             ' ..
        'Meta: ' .. json_comber(meta)
    )
    save_tbl[4] = RLE.encode_table(save_tbl[4])
    print(lang.get('is converted'))
    return save_tbl, meta
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

function save_u.convert_read(tbl, setair)
    local result = {}
    local blocks_id = tbl[2]
    local cords = dtc.dtc(tbl[3])
    local correct_cords = create_cords(cords[1][1], cords[1][2], cords[1][3], cords[2][1], cords[2][2], cords[2][3], cords[2][4])
    if setair == nil then
        setair = reader.get('SetAir')
    end
    tbl[4] = RLE.decode_table(tbl[4])
    for i = 1, #tbl[4] do
        local block_info = tbl[4][i]
        local block_id = blocks_id[block_info[1]]
        if (block_id ~= 'core:air') or (block_id == 'core:air' and setair) then
            if correct_cords then
                local state = {
                    rotation = block_info[2],
                    solid = block_info[3]
                }

                local cord = correct_cords[i]
                if block_id ~= nil then
                    table.insert(result, {
                        elem = 0,
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

    if reader.get('SetEntities') == true then
        for _, entity in ipairs(tbl[5]) do
            table.insert(result, {elem = 1, id = blocks_id[entity[1]], rot = entity[2], x = entity[3], y = entity[4], z = entity[5]})
        end
    end

    return result
end

return save_u