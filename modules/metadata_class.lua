local data_meow = { }
local metadata_meow = {}
function data_meow:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function data_meow:add(x1, y1, z1, data1_t, data2_t, data3_t)
    metadata_meow[#metadata_meow + 1] = {x = x1, y = y1, z = z1, data1 = data1_t, data2 = data2_t, data3 = data3_t}
end

function data_meow:remove(x, y, z)
    for key, value in ipairs(metadata_meow) do
        if value.x == x and value.y == y and value.z == z then
            table.remove(metadata_meow, key)
            data_meow:save_metadata()
        end
    end
end

function data_meow:read(x, y, z)
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

function data_meow:write(x, y, z, data1, data2, data3)
    data_meow:remove(x, y, z)
    data_meow:add(x, y, z, data1, data2, data3)
end

function data_meow:save_metadata()
    local function table_print(t)
        if type(t) ~= "table" then
            return 0
        end
    
        local s = {"{"}
        for i=1,#t do
            if type(t[i]) == "table" then
                s[#s + 1] = "{"
                for j = 1, #t[i] do
                    s[#s + 1] = t[i][j]
                    if j < #t[i] then
                        s[#s + 1] = ","
                    end
                end
                s[#s+1] = "}"
                if i < #t then
                    s[#s+1] = ","
                end
            else
                s[#s + 1] = tostring(t[i])
                if i < #t then
                    s[#s + 1] = ","
                end
            end
        end
        s[#s+1] = "}"
        s = table.concat(s)
        return s
    end
    local path = pack.data_file("meownatica", "meownatica_data.lua")
    if file.isfile(path) then
        local data = 'metadata_meow_cache = {'
        for key, value in ipairs(metadata_meow) do
            executer_file = true
            local data1 = table_print(value.data1)
            local data2 = table_print(value.data2)
            local data3 = table_print(value.data3)
            data = data .. '\n' .. "{x = " .. value.x .. ", y = " .. value.y .. ", z = " .. value.z .. ", data1 = " .. data1 .. ", data2 = " .. data2 .. ", data3 = " .. data3 .. "},"
        end
        data = data .. '\n' .. '}'
        file.write(path, data)
    else 
        print('[Meownatica] Invalid file') 
    end
end

function data_meow:open_metadata()
    local path = pack.data_file("meownatica", "meownatica_data.lua")
    if file.isfile(path) then
        if file.read(path) ~= '--WAIT...' then
            load_script(path)
            metadata_meow = metadata_meow_cache
        end
    else
        file.write(path, '--WAIT...')
    end
end

return data_meow