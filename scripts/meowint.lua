local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local save_u = require 'meownatica:tools/save_utils'
local lang = require 'meownatica:interface/lang'
local reader = require 'meownatica:tools/read_toml'
local num_file = 0

local function printStructures(tbl)
    if #tbl > 0 then
        num_file = num_file + 1
        while file.exists(reader.sys_get('savepath') .. 'save_meownatic_' .. num_file .. reader.sys_get('fileformat')) do
            num_file = num_file + 1
        end
        print(lang.get('Save Meownatic'))
        
        local save_table = save_u.convert_save(tbl)
        save_u.write(save_table, reader.sys_get('savepath') .. 'save_meownatic_' .. num_file .. reader.sys_get('fileformat'))
        meow_schem.save_to_config('save_meownatic_' .. num_file .. reader.sys_get('fileformat'))
    end
end
  
function on_use()
    local save_meowmatic = container.get()
    printStructures(save_meowmatic)
end