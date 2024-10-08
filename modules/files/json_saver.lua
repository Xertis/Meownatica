local module = {}
local meow_change = require 'meownatica:schematics_editors/change_schem'
local svu = require 'meownatica:tools/save_utils'
local json = require 'meownatica:tools/json_reader'

function module.save(name, path)
    local schem, meta = meow_change.get_schem(name, true, false)
    if schem ~= nil then
        schem[#schem] = meta
        schem = json.encode(schem)
        file.write(path, schem)
        return true
    end
end

return module
