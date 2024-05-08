local artd = require 'meownatica:files/artd'
local arbd = require 'meownatica:tools/arbd_utils'
local meow_schem = require 'meownatica:schematics_editors/SchemEditor'
local posm = require 'meownatica:schematics_editors/PosManager'

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
    local file = file.read(path)
    local file_data = artd.deserialize(file)
    file_data = arbd_convert(file_data)
    --CONVERT
    local cord1 = posm.min_position(file_data)
    local cord2 = posm.max_position(file_data)

    local x1, y1, z1, x2, y2, z2 = cord1[1], cord1[2], cord1[3], cord2[1], cord2[2], cord2[3]

    local i = 1
    for x = math.min(x1, x2), math.max(x1, x2) do
        for y = math.min(y1, y2), math.max(y1, y2) do
            for z = math.min(z1, z2), math.max(z1, z2) do
                print(file_data[i+1].x, file_data[i+1].y, file_data[i+1].z)
                if i ~= #file_data then
                    if posm.distance(x, y, z, file_data[i+1].x, file_data[i+1].y, file_data[i+1].z) > 0 then
                        for j = 1, posm.distance(x, y, z, file_data[i+1].x, file_data[i+1].y, file_data[i+1].z) do
                            table.insert(file_data, i, {id = 'core:air', x = x, y = y, z = z, state = {rotation = 0, solid = false, replaceable = false}})
                            i = i + 1
                        end
                    end
                end
                i = i + 1
            end
        end
    end
    local artd_table = arbd.convert_save(file_data)
    arbd.write(artd_table, "meownatica:meownatics/" .. name .. '.arbd')
    meow_schem.save_to_config(nil, nil, {name_format, name .. '.arbd'})
end

return convert_base