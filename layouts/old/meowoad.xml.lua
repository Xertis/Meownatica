local meow_build = require 'meownatica:world/build_schem'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local container = require 'meownatica:container_class'
local meow_change = require 'meownatica:schematics_editors/change_schem'
local lang = require 'meownatica:interface/lang'
local meownatic_schem = meow_change.change(false, true)
local x = 0
local y = 0
local z = 0
local reader = require 'meownatica:tools/read_toml'
local convert_schem = {}

local function convert_string_to_value(str)
    if str == "true" then
        return true
    elseif str == "false" then
        return false
    elseif tonumber(str) ~= nil then
        return tonumber(str)
    else
        return str
    end
end

function on_open(invid, x1, y1, z1)
    x = x1
    y = y1
    z = z1
end

function rotate_g()
    meownatic_schem = container.get_g()
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.rotate(meownatic_schem, reader.get('SmartRotateOn'))
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

function up_down_g()
    meownatic_schem = container.get_g()
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.upmeow(meownatic_schem)
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

function mirroring_g()
    meownatic_schem = container.get_g()
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.mirroring(meownatic_schem)
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

local function split_string(input_string)
    local words = {}

    for word in input_string:gmatch("%S+") do
        --word = string.lower(word)
        table.insert(words, word)
    end

    return words
end

function console(text)
    text = split_string(text)
    local parameter = {text[2], text[4]}
    text[1] = string.lower(text[1])
    if text[1] == 'schem' then
        if parameter[2] == 'del' then
            if reader.find(parameter[1]) ~= nil then 
                meow_schem.save_to_config(nil, parameter[1])
                document.meowoad_console.text = parameter[1] .. lang.get('was deleted')
            else
                document.meowoad_console.text = 'Схемы ' .. parameter[1] .. ' ' .. lang.get('not found')
            end
        elseif parameter[2] == 'add' then
            if file.exists('meownatica:meownatics/' .. parameter[1]) then
                meow_schem.save_to_config(parameter[1], nil)
                document.meowoad_console.text = parameter[1] .. ' ' .. lang.get('was added')
            else
                document.meowoad_console.text = parameter[1] .. ' ' .. lang.get('not found')
            end
        elseif parameter[1] == 'all' then
            local res = lang.get('meownatics in the config') .. ' ' .. reader.len() .. '\n'
            res = res .. reader.all_schem()
            document.meowoad_console.text = res
        elseif parameter[2] == 'materials' then

            --schem police_station.arbd = materials
            local materials = meow_change.get_schem(parameter[1])
            if materials ~= nil then
                local result = ''
                for _, entry in ipairs(meow_schem.materials(materials)) do
                    result = result .. "ID: " .. entry.id .. ' ' .. lang.get('count') .. ' ' .. entry.count .. '\n'
                end

                document.meowoad_console.text = result
            else
                document.meowoad_console.text = parameter[1] .. ' ' .. lang.get('not found')
            end
        else
            if parameter[2] ~= nil then
                document.meowoad_console.text = 'Команда ' .. parameter[2] .. ' не существует'
            else
                document.meowoad_console.text = 'Нет второго аргумента, запрос не закончен\nили первый аргумент неверен'
            end
        end
    elseif text[1] == 'config' then
        local result = false
        parameter[2] = convert_string_to_value(parameter[2])
        if parameter[2] ~= nil then
            if parameter[1] ~= 'meownatics' then
                result = meow_schem.save_to_config(nil, nil, parameter, true)
            end
            if result ~= false then
                document.meowoad_console.text = 'Параметр ' .. parameter[1] .. ' теперь имеет значение: ' .. tostring(parameter[2])
            else
                document.meowoad_console.text = 'Параметра ' .. parameter[1] .. ' не существует'
            end
        else
            if parameter[1] == 'all' then
                local res = lang.get('config parameters') .. '\n'
                res = res .. reader.all_parameters()
                document.meowoad_console.text = res
            else
                document.meowoad_console.text = 'Недопустимое значение параметра'
            end
        end

    elseif text[1] == 'amogus' then
        document.meowoad_console.text = 'Sus'
    elseif text[1] == 'gaf' or text[1] == 'woof' then
        document.meowoad_console.text = '. _.'
    elseif text[1] == 'meow' then
        document.meowoad_console.text = 'MEEEEOOOOOOWWW!!'
    end
end

function get_console()
    console(document.meowoad_console.text)
end

function text_input(text)
    console(text)
end

function clear()
    document.meowoad_console.text = ''
end

function change()
    meownatic_schem = container.get_g()
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    local conv = 0
    meownatic_schem, conv, name = meow_change.change(meownatic_schem, true)
    if meownatic_schem ~= 'convert' then
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
        document.meowoad_console.text = 'Схема ' .. name .. ' загружена'
    else
        document.meowoad_console.text = 'Схема ' .. name .. ' \nнуждается в конвертации!'
        local bol = true
        for i=1, #convert_schem do
            if convert_schem[i].name == name then bol = false end
        end
        if bol == true then table.insert(convert_schem, {convert = conv, name = name}) end
    end
end

function convert()
    if #convert_schem > 0 then
        document.meowoad_console.text = 'Схема ' .. convert_schem[1].name .. ' конвертируется...'
        meownatic_schem = meow_change.convert_schem(convert_schem[1].convert)
        if meownatic_schem ~= 'not converted' then
            document.meowoad_console.text = 'Схема ' .. convert_schem[1].name .. ' \nсконвертирована!'
        else
            document.meowoad_console.text = 'Отсутствует нужная инструкция конвертации,\nфайл не сконвертирован'
            container.get_g(meownatic_schem)
        end
        table.remove(convert_schem, 1)
    else
        document.meowoad_console.text = 'Очередь на конвертацию пустая!'
    end
end