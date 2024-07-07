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

function on_open(invid, x1, y1, z1)
    x = x1
    y = y1
    z = z1
end

function rotate_g()
    meownatic_schem = container.load().global_schem
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.rotate(meownatic_schem, reader.get('SmartRotateOn'))
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

function up_down_g()
    meownatic_schem = container.load().global_schem
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.upmeow(meownatic_schem)
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

function mirroring_g()
    meownatic_schem = container.load().global_schem
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    if #meownatic_schem > 0 then
        meownatic_schem = meow_schem.mirroring(meownatic_schem)
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
    end
end

function change()
    meownatic_schem = container.load().global_schem
    meow_build.unbuild_reed(x, y, z, meownatic_schem)
    local conv = 0
    local name = nil
    meownatic_schem, conv, name = meow_change.change(meownatic_schem, true)
    if meownatic_schem ~= 'convert' then
        meow_build.build_reed(x, y, z, meownatic_schem)
        container.send_g(meownatic_schem)
        document.meowoad_console.text = lang.get('meownatic') .. ' ' .. name .. ' ' .. lang.get('installed')
    else
        document.meowoad_console.text = lang.get('meownatic') .. ' ' .. name .. ' \n' .. lang.get('needconv')
        local bol = true
        for _, elem in ipairs(convert_schem) do
            if elem.name == name then bol = false end
        end
        if bol == true then table.insert(convert_schem, {convert = conv, name = name}) end
    end
end

function convert()
    if #convert_schem > 0 then
        document.meowoad_console.text = lang.get('meownatic') .. ' ' .. convert_schem[1].name .. lang.get('in progress')
        local reason = nil
        meownatic_schem, reason = meow_change.convert_schem(convert_schem[1].convert)
        if meownatic_schem ~= 'not converted' then
            document.meowoad_console.text = lang.get('meownatic') .. ' ' .. convert_schem[1].name .. '\n' .. lang.get('converted')
        else
            document.meowoad_console.text = reason .. '\n' .. lang.get('convertError')
            container.get_g(meownatic_schem)
        end
        table.remove(convert_schem, 1)
    else
        document.meowoad_console.text = lang.get('ConvQueueClear')
    end
end