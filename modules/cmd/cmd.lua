local stru = require 'meownatica:tools/string_utils'
local lang = load_script('meownatica:meow_data/lang.lua')
local reader = require 'meownatica:tools/read_toml'
local meow_change = load_script('meownatica:meow_classes/change_schem_class.lua')
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local json_saver = require 'meownatica:files/json_saver'

console.add_command(
    "m.schem.list",
    lang.get('schem_all_console'),
    function ()
        local res = lang.get('meownatics in the config') .. ' ' .. reader.len() .. '\n'
        res = res .. reader.all_schem()
        return res
    end
)

console.add_command(
    "m.schem.json meownatic:str path:str",
    lang.get('schemjson'),
    function (args)
        local path = args[2]
        local name = args[1]
        json_saver.save(name, reader.sys_get('savepath') .. path .. '.json')
    end
)

console.add_command(
    "m.schem.folder",
    lang.get('consolefolder'),
    function ()
        local schemes = file.list(reader.sys_get('savepath'))
        local res = lang.get('folder') .. '\n'
        for id, value in pairs(schemes) do
            res = res .. id .. ': ' .. file.resolve(value) .. '\n'
        end
        return res
    end
)

console.add_command(
    "m.config.list",
    lang.get('config_all_console'),
    function ()
        local res = lang.get('config parameters') .. '\n'
        res = res .. reader.all_parameters()
        return res
    end
)
console.add_command(
    "m.schem.materials meownatic:str",
    lang.get('materials_console'),
    function (meownatic)
        local parameter = meownatic[1]
        local materials = meow_change.get_schem(parameter)
        if materials ~= nil then
            local result = lang.get('materials') .. '\n'
            for _, entry in ipairs(meow_schem.materials(materials)) do
                result = result .. "ID: " .. entry.id .. ' ' .. lang.get('count') .. ' ' .. entry.count .. '\n'
            end

            return result
        else
            return parameter .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.schem.add meownatic:str",
    lang.get('addschem_console'),
    function (meownatic)
        local parameter = meownatic[1]
        if file.exists(reader.sys_get('savepath') .. parameter) then
            meow_schem.save_to_config(parameter, nil)
            return parameter .. ' ' .. lang.get('was added')
        else
            return parameter .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.schem.del meownatic:str",
    lang.get('delschem_console'),
    function (meownatic)
        local parameter = meownatic[1]
        if reader.find(parameter) ~= nil then 
            meow_schem.save_to_config(nil, parameter)
            return parameter .. ' ' .. lang.get('was deleted')
        else
            return 'Схемы ' .. parameter .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.config.set parameter:str value:str",
    lang.get('setconfig_console'),
    function (args)
        local parameter = args
        local result = false
        parameter[2] = stru.string2value(parameter[2])
        if parameter[2] ~= nil then
            if parameter[1] ~= 'meownatics' then
                result = meow_schem.save_to_config(nil, nil, parameter, true)
            end
            if result ~= false then
                return parameter[1] .. ': ' .. tostring(parameter[2])
            else
                return parameter[1] .. ' ' .. lang.get('not found')
            end
        end
    end
)