local true_rotate = load_script('meownatica:meow_classes/SmartRotate.lua')
local artd = require 'meownatica:artd'
local arbd = require 'meownatica:arbd_utils'
local instruction = load_script('meownatica:meow_classes/find_instruction_class.lua')
local meow_schem = {}
local reader = require 'meownatica:read_toml'
local toml = require 'core:toml'
function meow_schem:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--Поворот схемы
function meow_schem:rotate_standart(meownatic)
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

function meow_schem:rotate(meownatic, smart_rotate)
    for i = 1, #meownatic do
        if meownatic[i].state.solid == false or meownatic[i].state.solid == nil then
            local x = meownatic[i].x
            local y = meownatic[i].y
            local z = meownatic[i].z
            local state_true = nil
            if smart_rotate == true then
                state_true = true_rotate:rotate(x, y, z, meownatic[i].id, meownatic[i].state.rotation)
            end
            if state_true ~= nil then
                --Поворот на 90 градусов
                meownatic[i].state.rotation = state_true
                meownatic[i].x = -z
                meownatic[i].z = x
            else
                meownatic[i] = meow_schem:rotate_standart(meownatic[i])
            end
        else
            meownatic[i] = meow_schem:rotate_standart(meownatic[i])
        end
    end
    return meownatic
end

function meow_schem:min_y(meownatic)
    local minimal = 100000000000000000000000
    --Минимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y < minimal then
            minimal = meownatic[i].y
        end
    end
    return minimal
end

function meow_schem:max_y(meownatic)
    local maximum = -10000000000000000000000
    --Максимальный Y
    for i = 1, #meownatic do
        if meownatic[i].y > maximum then
            maximum = meownatic[i].y
        end
    end
    return maximum
end

function meow_schem:materials(meownatic)
    local count = {}
    for _, materials in ipairs(meownatic) do
        local id = materials.id
        count[id] = (count[id] or 0) + 1
    end
    --for id, value in pairs(count) do
        --print("Материал с id", id, "встречается", value, "раз(а)")
    --end

    --print('===' .. 'Блоков всего: ' .. #meownatic .. '===')
    return count
end

--Переворот схемы вверх дном
function meow_schem:upmeow(meownatic)

    local n = #meownatic
    --Сортируем таблицу
    for i = 1, n - 1 do
        local max_indx = i
        for j = i + 1, n do
            if meownatic[j].y > meownatic[max_indx].y then
                max_indx = j
            end
        end
        meownatic[i], meownatic[max_indx] = meownatic[max_indx], meownatic[i]
    end

    local Y_save = {}
    for i = 1, #meownatic do
        local max_y = meow_schem:max_y(meownatic)
        local min_y = meow_schem:min_y(meownatic)
        max_y = max_y - i + 1
        min_y = min_y + i - 1

        for _, block in ipairs(meownatic) do
            if block.y == max_y then
                table.insert(Y_save, min_y)
            end
        end
    end

    for i, block in ipairs(meownatic) do
        block.y = Y_save[i]
    end

    for i, block in ipairs(meownatic) do
        if block.state.rotation == 5 then
            block.state.rotation = 4
        elseif block.state.rotation == 4 then
            block.state.rotation = 5
        end
    end
    return meownatic
end

function meow_schem:save_to_config(name, expection, replace, config)
    local lines = toml.deserialize(file.read("meownatica:meow_config.toml"))
    local len = reader:len()
    if len == 0 then
        len = 1
    end
    if name ~= nil then
        local name_to_save = 'source' .. len
        if reader:indx_is_real(name_to_save) == false then
            print(value, idx, name_to_save)
            lines['meownatics'][name_to_save] = name
        else
            local i = len + 1
            while true do
                if reader:indx_is_real('source' .. i) == false then
                    lines['meownatics']['source' .. i] = name
                    break
                else
                    i = i + 1
                end
            end
        end     
    end
    if expection ~= nil then
        local find, idx = reader:find(expection)
        lines['meownatics'][idx] = nil
    end
    if replace ~= nil then
        if config == nil then
            local find, idx = reader:find(replace[1])
            lines['meownatics'][idx] = replace[2]
        else
            if reader:indx_is_real(replace[1], true) then
                lines[replace[1]] = replace[2]
            else
                return false
            end
        end
    end
    file.write('meownatica:meow_config.toml', toml.serialize(lines))
end

function meow_schem:convert(name_format, finish_format, source)
    local format = name_format:match("%.([^%.]+)$")
    local path = instruction:find(format, finish_format)
    if path ~= '' then
        instruction:convert("meownatica:meownatics/" .. source, path)
        return true
    else
        return false
    end
end


return meow_schem