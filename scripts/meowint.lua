local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local arbd = require 'meownatica:tools/save_utils'
local lang = require 'meownatica:interface/lang'
local reader = require 'meownatica:tools/read_toml'
local num_file = 0

local function printStructures(tbl)
    num_file = num_file + 1
    while file.exists(reader.sys_get('savepath') .. 'save_meownatic_' .. num_file .. reader.sys_get('fileformat')) do
        num_file = num_file + 1
    end
    print(lang.get('Save Meownatic'))

    arbd_table = arbd.convert_save(tbl)

    arbd.write(arbd_table, reader.sys_get('savepath') .. 'save_meownatic_' .. num_file .. reader.sys_get('fileformat'))
    meow_schem.save_to_config('save_meownatic_' .. num_file .. reader.sys_get('fileformat'))
end
  
function on_use_on_block(x, y, z, playerid)
    local save_meowmatic = container.get()
    printStructures(save_meowmatic)
end