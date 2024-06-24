local data_meow = { }
local metadata_meow = {}
local json = require 'meownatica:tools/json_reader'

function data_meow.add(x1, y1, z1, data1_t, data2_t, data3_t)
    metadata_meow[#metadata_meow + 1] = {x = x1, y = y1, z = z1, data1 = data1_t, data2 = data2_t, data3 = data3_t}
end

function data_meow.remove(x, y, z)
    for key, value in ipairs(metadata_meow) do
        if value.x == x and value.y == y and value.z == z then
            table.remove(metadata_meow, key)
            data_meow.save_metadata()
        end
    end
end

function data_meow.read(x, y, z)
    if #metadata_meow > 0 then
        for key, value in ipairs(metadata_meow) do
            if value.x == x and value.y == y and value.z == z then
                return value.data1, value.data2, value.data3
            end
        end
    else
        return nil
    end
end

function data_meow.write(x, y, z, data1, data2, data3)
    data_meow.remove(x, y, z)
    data_meow.add(x, y, z, data1, data2, data3)
end

function data_meow.save_metadata()
    local path = pack.data_file("meownatica", "meownatica_data.json")
    if file.isfile(path) then
        file.write(path, json.encode(metadata_meow))
    else 
        print('[Meownatica] Invalid file') 
    end
end

function data_meow.open_metadata()
    local path = pack.data_file("meownatica", "meownatica_data.json")
    if file.isfile(path) then
        if file.read(path) ~= '//WAIT...' then
            metadata_meow = json.decode(file.read(path))
        end
    else
        file.write(path, '//WAIT...')
    end
end

return data_meow