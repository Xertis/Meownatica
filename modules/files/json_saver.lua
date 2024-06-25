local module = {}
local meow_change = require 'meownatica:schematics_editors/change_schem'
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
