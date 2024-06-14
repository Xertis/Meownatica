local module = {}
local meow_change = load_script('meownatica:meow_classes/change_schem_class.lua')
local svu = require 'meownatica:tools/save_utils'
local json = require 'meownatica:tools/json_reader'

function module.save(name, path)
    local schem = meow_change.get_schem(name, true)
    schem = svu.convert_save(schem)
    schem[1] = 1
    schem = json.encode(schem)
    file.write(path, schem)
end

return module
