local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local arbd = require 'meownatica:tools/arbd_utils'
local lang = load_script('meownatica:meow_data/lang.lua')
local num_file = 0

local function printStructures(tbl)
    num_file = num_file + 1
    while file.exists('meownatica:meownatics/' .. 'save_meownatic_' .. num_file .. '.arbd') do
        num_file = num_file + 1
    end
    print(lang.get('Save Meownatic'))

    arbd_table = arbd.convert_save(tbl)

    arbd.write(arbd_table, 'meownatica:meownatics/' .. 'save_meownatic_' .. num_file .. '.arbd')
    meow_schem.save_to_config('save_meownatic_' .. num_file .. '.arbd')
end
  
function on_use_on_block(x, y, z, playerid)
    local save_meowmatic = container.get()
    printStructures(save_meowmatic)
end