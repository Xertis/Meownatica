local container = require 'meownatica:container_class'
local meow_schem = require 'meownatica:schem_class'
local arbd = require 'meownatica:arbd_utils'
local num_file = 0

local function printStructures(tbl)
    num_file = num_file + 1
    while file.exists('meownatica:meownatics/' .. 'save_meownatic_' .. num_file .. '.arbd') do
        num_file = num_file + 1
    end
    print('[MEOWNATICA] Loading meownatic...')

    arbd_table = arbd:convert_save(tbl)

    arbd:write(arbd_table, 'meownatica:meownatics/' .. 'save_meownatic_' .. num_file .. '.arbd')
    meow_schem:save_to_config('save_meownatic_' .. num_file .. '.arbd')
end
  
function on_use_on_block(x, y, z, playerid)
    local save_meowmatic = container:get()
    printStructures(save_meowmatic)
end