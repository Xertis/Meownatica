local artd = require 'meownatica:files/artd'
local arbd = require 'meownatica:tools/arbd_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'

local convert_base = {}
function convert_base:convert(path)
    print(path)
    local function arbd_convert(tbl)
        local result = {}
        for i = 1, #tbl do
            result[#result + 1] = {x = tbl[i][1], y = tbl[i][2], z = tbl[i][3], id = tbl[i][4], state = {rotation = tbl[i][5][1], solid = tbl[i][5][2], replaceable = tbl[i][5][3]}}
        end
        return result
    end
    local name_format = path:match(".+/(.+)")
    print(name_format, path)
    local name = name_format:gsub("%.artd$", "")
    local convert_meownatic = {}
    local file = file.read(path)
    local file_data = artd.deserialize(file)
    file_data = arbd_convert(file_data)
    --CONVERT
    artd_table = arbd:convert_save(file_data)

    arbd:write(artd_table, "meownatica:meownatics/" .. name .. '.arbd')
    meow_schem:save_to_config(nil, nil, {name_format, name .. '.arbd'})
end

return convert_base