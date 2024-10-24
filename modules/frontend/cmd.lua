local stru = require 'meownatica:tools/string_utils'
local lang = require 'meownatica:frontend/lang'
local reader = require 'meownatica:tools/read_toml'
local meow_change = require 'meownatica:schematics_editors/change_schem'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local json_saver = require 'meownatica:files/json_saver'
local RLE = require 'meownatica:logic/RLEcompression'
local json_comber = require 'meownatica:tools/json_comber'
local fragment = require 'meownatica:files/fragment_saver'

console.add_command(
    "m.schem.list",
    lang.get('schem_all_console'),
    function ()
        local res = lang.get('meownatics in the config') .. ' ' .. reader.len("meownatics") .. '\n'
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
        if file.exists(reader.sys_get('savepath') .. name) ~= false then
            local result = json_saver.save(name, reader.sys_get('savepath') .. path .. '.json')
            if result == true then
                return name .. ' ' .. lang.get('converted')
            else
                return lang.get('convertError')
            end
        else
            return name .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.schem.fragment meownatic:str path:str struct_air:str",
    lang.get('schemfragment'),
    function (args)
        local path = args[2]
        local name = args[1]
        local struct_air = args[3]
        if file.exists(reader.sys_get('savepath') .. name) ~= false then
            local result = fragment.save(name, reader.sys_get('savepath') .. path .. '.vox', struct_air)
            if result == true then
                return name .. ' ' .. lang.get('converted')
            else
                return lang.get('convertError')
            end
        else
            return name .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.schem.info meownatic:str",
    lang.get('schemjson'),
    function (args)
        local name = args[1]
        local schem, meta = meow_change.get_schem(name, false, false)
        if schem ~= nil then
            local blocks = RLE.decode_table(schem[4])
            local sizeX, sizeY, sizeZ, binding = unpack(schem[3])

            meta = meta or 'Deprecated version'

            if type(meta) == "table"  then
                meta = json_comber(meta)
            end
            
            return
                'IDs count: ' .. #schem[2] .. '\n' ..
                'Blocks count: ' .. #blocks .. '\n' ..
                'Entities count: ' .. #schem[5] .. '\n' ..
                'Binding: ' .. binding .. '\n' ..
                'Version: ' .. schem[1] .. '\n' ..
                'Size (X, Y, Z): ' .. sizeX+1 .. ', ' .. sizeY+1 .. ', ' .. sizeZ+1 .. '\n' ..
                'Meta: ' .. meta
        else
            return name .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.schem.reload",
    lang.get('schemreload_help'),
    function ()
        local files = file.list(reader.sys_get("savepath"))
        local del_files = reader.get_all_schem()
        for i, file in pairs(del_files) do
            if reader.find(file) ~= nil then
                meow_schem.save_to_config(nil, file)
            end
        end

        local standart_format = reader.sys_get("fileformat")

        for i, file in pairs(files) do
            local format = string.match(file, "%.([^%.]+)$")
            if format ~= nil then
                local name = string.match(file, "([^/]+)$")
                if '.' .. format == standart_format then
                    meow_schem.save_to_config(name, nil)
                end
            end
        end
        return lang.get('schemreload_res')
    end
)

console.add_command(
    "m.schem.folder",
    lang.get('consolefolder'),
    function ()
        local schemes = file.list(reader.sys_get('savepath'))
        local res = lang.get('folder') .. '\n'
        for id, value in pairs(schemes) do
            res = res .. id .. '. ' .. file.resolve(value) .. '\n'
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
        local materials = meow_change.get_schem(parameter, false)
        if materials ~= nil then
            local result = lang.get('materials') .. '\n'
            for _, entry in ipairs(meow_schem.materials(materials)) do
                result = result .. "ID: " .. entry.id .. ' ' .. lang.get('count') .. ' ' .. entry.count .. '\n'
            end
            result = result .. lang.get('countmaterials') .. #materials
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
            return parameter .. ' ' .. lang.get('not found')
        end
    end
)

console.add_command(
    "m.config.set parameter:str value:str",
    lang.get('setconfig_console'),
    function (args)
        local parameter = args
        parameter[1] = string.lower(parameter[1])
        local result = false
        if type(parameter[2]) ~= "boolean" then parameter[2] = stru.string2value(string.lower(parameter[2])) end
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