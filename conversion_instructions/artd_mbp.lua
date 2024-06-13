local artd = require 'meownatica:files/artd'
local arbd = require 'meownatica:tools/save_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local posm = require 'meownatica:schematics_editors/PosManager'
local toml = require 'meownatica:tools/read_toml'

local convert_base = {}
function convert_base:convert(path)
    print(path)
    local function arbd_convert(tbl)
        local result = {}
        for i = 1, #tbl do
            result[#result + 1] = {x = tbl[i][1], y = tbl[i][2], z = tbl[i][3], id = tbl[i][4], state = {rotation = tonumber(tbl[i][5][1]), solid = tbl[i][5][2]}}
        end
        return result
    end
    local name_format = path:match(".+/(.+)")
    print(name_format, path)
    local name = name_format:gsub("%.artd$", "")
    local file = file.read(path)
    local file_data = artd.deserialize(file)
    file_data = arbd_convert(file_data)
    --CONVERT

    local max_pos = posm.max_position(file_data)
    local min_pos = posm.min_position(file_data)

    local x1, y1, z1, x2, y2, z2 = min_pos[1], min_pos[2], min_pos[3], max_pos[1], max_pos[2], max_pos[3]
    local result = {}
    local i = 1
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                if i <= #file_data then
                    if x == file_data[i].x and y == file_data[i].y and z == file_data[i].z then
                        table.insert(result, file_data[i])
                        i = i + 1
                    else
                        table.insert(result, {x = x, y = y, z = z, id = 'core:air', state = {rotation = 0, solid = false, replaceable = false}})
                    end
                end
            end
        end
    end
    local artd_table = arbd.convert_save(result)
    arbd.write(artd_table, toml.sys_get('savepath') .. name .. '.mbp')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.mbp'})
end

return convert_base