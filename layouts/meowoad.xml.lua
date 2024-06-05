local meow_build = load_script('meownatica:meow_classes/build_class.lua')
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local container = require 'meownatica:container_class'
local meow_change = load_script('meownatica:meow_classes/change_schem_class.lua')
local lang = load_script('meownatica:meow_data/lang.lua')
local meownatic_schem = meow_change.change(false, true)
local x = 0
local y = 0
local z = 0
local reader = require 'meownatica:tools/read_toml'
local convert_schem = {}



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