local module = {}
local cont = require 'meownatica:container_class'
local svu = require 'meownatica:tools/save_utils'
local json = require 'meownatica:tools/json_reader'

function module.save(path)
    local schem = cont.load().global_schem
    schem = svu.convert_save(schem)
    schem = json.encode(schem)
    file.write(path, schem)
end

return module
