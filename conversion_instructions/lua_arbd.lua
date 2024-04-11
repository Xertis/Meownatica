local artd = require 'meownatica:artd'
local arbd = require 'meownatica:arbd_utils'
local meow_schem = require 'meownatica:schem_class'

local convert_base = {}

function convert_base:convert(path)
    local name_format = path:match(".+/(.+)")
    local name = name_format:gsub("%.lua$", "")
    local convert_meownatic = {}
    dofile(file.resolve(path))
    local meownatic = meownatic_schem
    for i = 1, #meownatic do
        local solid = nil
        local rotation = meownatic[i].state
        local replaceable = nil
        local id = meownatic[i].id
        local x, y, z = meownatic[i].x, meownatic[i].y, meownatic[i].z
        if id ~= 'core:air' then
            local name1 = id
            local pos = name1:find(':')
            local name_mode = name1:sub(1, pos - 1)
            local name_block = name1:sub(pos + 1)
            local config = ''
            config = file.read(name_mode .. ':' .. 'blocks' .. '/' .. name_block .. '.json')
            local config = string.lower(config)
            -- Делим конфиг на строки
            local lines = {}
            for line in config:gmatch("[^\n]+") do
                table.insert(lines, line)
            end
            for yyy, line in ipairs(lines) do
                --Проверяем на солидность
                if line:find('aabb') and line:find('model') then
                    solid = false
                elseif line:find('custom') and line:find('model') then
                    solid = false
                elseif line:find('block') and line:find('model') then
                    solid = true
                elseif line:find('x') and line:find('model') then
                    solid = false
                else
                    if solid == nil then
                        solid = true
                    end
                end

                --Проверяем на replaceable
                if line:find('replaceable') and line:find('true') then
                    replaceable = true
                else
                    if replaceable == nil then
                        replaceable = false
                    end
                end
            end
        else
            solid = false
            replaceable = true
        end

        convert_meownatic[#convert_meownatic + 1] = {x = x, y = y, z = z, id = id, state = {rotation = rotation, solid = solid, replaceable = replaceable}}
    end
    artd_table = arbd:convert_save(convert_meownatic)
    
    arbd:write(artd_table, "meownatica:meownatics/" .. name .. '.arbd')
    meow_schem:save_to_config(nil, nil, {name_format, name .. '.arbd'})
end

return convert_base