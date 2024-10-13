local true_rotate = require 'meownatica:tools/smart_rotate'
local instruction = require 'meownatica:logic/find_instruction'
local meow_schem = {}
local reader = require 'meownatica:tools/read_toml'
local PosManager = require 'meownatica:schematics_editors/PosManager'
local tblu = require 'meownatica:tools/table_utils'

--Поворот схемы
function meow_schem.rotate_standart(meownatic)
    local x = meownatic.x
    local z = meownatic.z

    -- Поворот на 90 градусов
    meownatic.x = -z
    meownatic.z = x

    local state = meownatic.state.rotation

    if state == 3 then
        state = 0
    elseif state == 0 then
        state = 1
    elseif state == 1 then
        state = 2
    elseif state == 2 then
        state = 3
    end
    meownatic.state.rotation = state
    return meownatic
end

function meow_schem.rotate(meownatic, smart_rotate)
    for i = 1, #meownatic do
        if meownatic[i].elem == 0 then
            if meownatic[i].state.solid == false or meownatic[i].state.solid == nil then
                local x = meownatic[i].x
                local z = meownatic[i].z
                local state_true = nil
                if smart_rotate == true then
                    state_true = true_rotate.rotate(meownatic[i].id, meownatic[i].state.rotation)
                end
                if state_true ~= nil then
                    --Поворот на 90 градусов
                    meownatic[i].state.rotation = state_true
                    meownatic[i].x = -z
                    meownatic[i].z = x
                else
                    meownatic[i] = meow_schem.rotate_standart(meownatic[i])
                end
            else
                meownatic[i] = meow_schem.rotate_standart(meownatic[i])
            end
        elseif meownatic[i].elem == 1 then
            local x = meownatic[i].x
            local z = meownatic[i].z
            meownatic[i].x = -z + 1
            meownatic[i].z = x
        end
    end
    return meownatic
end

function meow_schem.delete_air(meownatic, setair)
    local del = {}
    if setair == false then
        for i = 1, #meownatic do
            if meownatic[i].id == 'core:air' then
                table.insert(del, i)
            end
        end

        for i = 1, #del do
            table.remove(meownatic, del[i])
        end
        return meownatic
    else
        return meownatic
    end
end

function meow_schem.materials(meownatic)
    local count = {}
    for _, materials in pairs(meownatic) do
        local id = materials.id
        count[id] = (count[id] or 0) + 1
    end

    local sorted_count = {}
    for id, count_value in pairs(count) do
        table.insert(sorted_count, { id = id, count = count_value })
    end
    table.sort(sorted_count, function(a, b)
        if a.count == b.count then
            return a.id < b.id
        else
            return a.count > b.count
        end
    end)

    return sorted_count
end

--Переворот схемы вверх дном
function meow_schem.upmeow(meownatic)
    local max_y = PosManager.max_y(meownatic)

    local available_ids = {}
    local packs = block.defs_count()
    for i = 0, packs do
        available_ids[#available_ids + 1] = block.name(i)
    end

    for i = 1, #meownatic do
        local y = meownatic[i].y
        local sizeY = 1
        if meownatic[i].elem == 0 then
            local state = meownatic[i].state.rotation
            if tblu.find(available_ids, meownatic[i].id) then
                local id = block.index(meownatic[i].id)
                _, sizeY, _ = block.get_size(id)
            end
            if state == 5 then
                meownatic[i].state.rotation = 4
            elseif state == 4 then
                meownatic[i].state.rotation = 5
            end
        end
        meownatic[i].y = -y + max_y - (sizeY - 1)
    end
    return meownatic
end

function meow_schem.mirroring(meownatic)
    local max_x = PosManager.max_x(meownatic)
    local min_x = PosManager.min_x(meownatic)
    local max_z = PosManager.max_z(meownatic)
    local min_z = PosManager.min_z(meownatic)

    local dX = math.abs(max_x) + math.abs(min_x)
    local dZ = math.abs(max_z) + math.abs(min_z)
    if dX <= dZ then
        for i = 1, #meownatic do
            if meownatic[i].elem == 0 then
                local x = meownatic[i].x
                local state = meownatic[i].state.rotation
                meownatic[i].x = -x + max_x
                if state == 3 then
                    state = 1
                elseif state == 0 then
                    state = 2
                elseif state == 1 then
                    state = 3
                elseif state == 2 then
                    state = 0
                end
                meownatic[i].state.rotation = state

            elseif meownatic[i].elem == 1 then
                local x = meownatic[i].x
                meownatic[i].x = -x + max_x + 1
            end
        end
    else
        for i = 1, #meownatic do
            if meownatic[i].elem == 0 then
                local z = meownatic[i].z
                local state = meownatic[i].state.rotation
                meownatic[i].z = -z + max_z
                if state == 3 then
                    state = 1
                elseif state == 0 then
                    state = 2
                elseif state == 1 then
                    state = 3
                elseif state == 2 then
                    state = 0
                end
                meownatic[i].state.rotation = state

            elseif meownatic[i].elem == 1 then
                local z = meownatic[i].z
                meownatic[i].z = -z + max_z + 1
            end
        end
    end
    return meownatic
end

function meow_schem.save_to_config(name, expection, replace, config)
    local lines = toml.parse(file.read("meownatica:meow_config.toml"))
    local len = reader.len("meownatics")
    if len == 0 then
        len = 1
    end
    if name ~= nil then
        local name_to_save = 'source' .. len
        if not reader.get('meownatics')[name_to_save] then
            lines['meownatics'][name_to_save] = name
        else
            local i = len + 1
            while true do
                if not reader.get('meownatics')['source' .. i] then
                    lines['meownatics']['source' .. i] = name
                    break
                else
                    i = i + 1
                end
            end
        end
    end
    if expection ~= nil then
        local find, idx = reader.find(expection)
        local i = 1
        local res = {}
        lines['meownatics'][idx] = nil
        for id, value in pairs(lines['meownatics']) do
            res['source' .. i] = value
            i = i + 1
        end
        lines['meownatics'] = res
    end
    if replace ~= nil then
        if config == nil then
            local find, idx = reader.find(replace[1])
            lines['meownatics'][idx] = replace[2]
        else
            if reader.get(replace[1]) then
                lines[replace[1]] = replace[2]
            else
                return false
            end
        end
    end
    file.write('meownatica:meow_config.toml', toml.tostring(lines))
end

function meow_schem.convert(name_format, finish_format, source)
    local format = name_format:match("%.([^%.]+)$")
    local path = instruction.find(format, finish_format)
    if path ~= nil then
        return instruction.convert(reader.sys_get('savepath') .. source, path)
    else
        return false, 'Инструкция для конвертации не найдена'
    end
end

return meow_schem